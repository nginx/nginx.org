#!/usr/bin/perl

# (C) Maxim Dounin
# (C) Nginx, Inc.

# Convert from XSLScript to XSLT.
# 
# Originally XSLScript was written by Paul Tchistopolskii.  It is believed
# to be mostly identical to XSLT, but uses shorter syntax.  Original
# implementation has major Java dependency, no longer supported and hard
# to find.
# 
# This code doesn't pretend to be a full replacement, but rather an attempt
# to provide functionality needed for nginx documentation.

###############################################################################

use warnings;
use strict;

use Parse::RecDescent;
use Getopt::Long;
use Data::Dumper qw/Dumper/;

###############################################################################

my $dump = 0;
my $output;

GetOptions(
	"output|o=s" => \$output,
	"trace!" => \$::RD_TRACE,
	"hint!" => \$::RD_HINT,
	"dump!" => \$dump,
)
	or die "oops\n";

###############################################################################

my $grammar = <<'EOF';

# XSLScript grammar, reconstructed

startrule	: <skip:""> item(s) eofile
	{ $return = $item{'item(s)'}; 1 }

item		: "<!--" <commit> comment
		| "!!" <commit> exclam_double
		| "!{" <commit> exclam_xpath
		| "!" name <commit> params
	{ $return = [
		"X:call-template", "name", $item{name}, [],
		$item{params}
	]; 1 }
		| "<%" <commit> space instruction space "%>"
	{ $return = $item{instruction}; 1 }
		| "<" name attrs space ">" <commit> item(s?) "</" name ">"
	{ $return = [ "tag", $item{name}, $item{attrs}, $item{'item(s?)'} ]; 1 }
		| "<" <commit> name attrs space "/>"
	{ $return = [ "tag", $item{name}, $item{attrs} ]; 1 }
		| "X:variable" space <commit> xvariable
		| "X:var" space <commit> xvariable
		| "X:template" space <commit> xtemplate
		| "X:if" space <commit> xif
		| "X:param" space <commit> xparam
		| "X:for-each" space <commit> xforeach
		| "X:sort" space <commit> xsort
		| "X:when" space <commit> xwhen
		| "X:attribute" space <commit> xattribute
		| "X:output" space <commit> xoutput
		| "X:copy-of" space <commit> xcopyof
		| instruction space <commit> attrs body
	{ $return = [ $item{instruction}, $item{attrs}, $item{body} ]; 1 }
		| space_notempty
		| text
		| <error>

# list of simple instructions

instruction	: "X:stylesheet"
		| "X:transform"
		| "X:attribute-set"
		| "X:element"
		| "X:apply-templates"
		| "X:choose"
		| "X:otherwise"
		| "X:value-of"
		| "X:apply-imports"
		| "X:number"
		| "X:include"
		| "X:import"
		| "X:strip-space"
		| "X:preserve-space"
		| "X:copy"
		| "X:text"
		| "X:comment"
		| "X:processing-instruction"
		| "X:decimal-format"
		| "X:namespace-alias"
		| "X:key"
		| "X:fallback"
		| "X:message"

# comments, <!-- ... -->
# not sure if it's something to be interpreted specially
# likely an artifact of our dump process

comment		: /((?!-->).)*/ms "-->"
	{ $return = "<!--" . $item[1] . "-->"; 1 }

# special chars: ', ", {, }, \
# if used in text, they needs to be escaped with backslash

text		: quoted | unreserved | "'" | "\"" | "{"
quoted		: "\\" special
	{ $return = $item{special}; 1; }
special		: "'" | "\"" | "\\" | "{" | "}"
unreserved	: /[^'"\\{}<\s]+\s*/ms

# whitespace

space		: /\s*/ms
space_notempty	: /\s+/ms

# shortcuts:
#
# !! for X:apply-templates
# !{xpath-expression} for X:value-of select="xpath-expression";
# !foo() for X:call-template name="foo"

# !root (path = { !{ substring($DIRNAME, 2) } })
# !root (path = "substring-after($path, '/')")

exclam_double	: space value(?) params(?) attrs space ";"
	{ $return = [
		"X:apply-templates", "select", $item{'value(?)'}[0],
		$item{attrs}, $item{'params(?)'}[0]
	]; 1 }

exclam_xpath	: xpath "}"
	{ $return = [
		"X:value-of", "select", $item{xpath}, []
	]; 1 }
xpath		: /("[^"]*"|'[^']*'|[^}'"])*/ms

# instruction attributes
# name="value"

attrs		: attr(s?)
attr		: space name space "=" space value
	{ $return = $item{name} . "=" . $item{value}; }
name		: /[a-z0-9_:-]+/i
value		: /"[^"]*"/

# template parameters
# ( bar="init", baz={markup} )

params		: space "(" param(s? /\s*,\s*/) ")" space
	{ $return = $item[3]; 1 }
param		: space name space "=" space value space
	{ $return = [
		"X:with-param",
		"select", $item{value},
		"name", $item{name},
		[]
	]; 1 }
		| space name space "=" <commit> space "{" item(s) "}"
	{ $return = [
		"X:with-param", "name", $item{name}, [],
		$item{'item(s)'}
	]; 1 }
		| space name
	{ $return = [
		"X:param", "name", $item{name}, []
	]; 1 }

# instruction body
# ";" for empty body, "{ ... }" otherwise

body		: space ";"
	{ $return = ""; }
		| space "{" <commit> item(s?) "}" (space ";")(?)
	{ $return = $item{'item(s?)'}; 1 }

# special handling of some instructions
# X:if attribute is test=

xif		: value body space "else" <commit> body
	{ $return = [
		"X:choose", [], [
			[ "X:when", "test", $item[1], [], $item[2] ],
			[ "X:otherwise", [], $item[6] ]
		]
	]; 1 }
		| value attrs body
	{ $return = [
		"X:if", "test", $item{value}, $item{attrs}, $item{body},
	]; 1 }
		| attrs body
	{ $return = [
		"X:if", $item{attrs}, $item{body},
	]; 1 }
		| <error>

# X:template name(params) = "match" {
# X:template name( bar="init", baz={markup} ) = "match" mode="some" {

xtemplate	: name(?) params(?) space
                  (space "=" space value)(?) attrs body
	{ $return = [
		"X:template",
		"name", $item{'name(?)'}[0],
		"match", $item[4][0],
		$item{attrs},
		[ ($item[2][0] ? @{$item[2][0]} : ()), @{$item{body}} ]
	]; 1 }

# X:var LINK = "/article/@link";
# X:var year = { ... }
# semicolon is optional

xvariable	: name space "=" space value attrs body
	{ $return = [
		"X:variable",
		"select", $item{value},
		"name", $item{name},
		$item{attrs}, $item{body}
	]; 1 }
		| name space "=" space attrs body
	{ $return = [
		"X:variable",
		"name", $item{name},
		$item{attrs}, $item{body}
	]; 1 }
		| name space "=" space value
	{ $return = [
		"X:variable",
		"select", $item{value},
		"name", $item{name},
		[]
	]; 1 }
		| name space "=" 
	{ $return = [
		"X:variable",
		"name", $item{name},
		[]
	]; 1 }
		| <error>

# X:param XML = "'../xml'";
# X:param YEAR;

xparam		: name space "=" space value attrs body
	{ $return = [
		"X:param",
		"select", $item{value},
		"name", $item{name},
		$item{attrs}, $item{body}
	]; 1 }
		| name attrs body
	{ $return = [
		"X:param", "name", $item{name},
		$item{attrs}, $item{body}
	]; 1 }

# X:for-each "section[@id and @name]" { ... }
# X:for-each "link", X:sort "@id" {

xforeach	: value attrs body
	{ $return = [
		"X:for-each", "select", $item{value}, $item{attrs}, $item{body}
	]; 1 }
		| value attrs space
		  "," space "X:sort" <commit> space value attrs body
	{ $return = [
		"X:for-each", "select", $item[1], $item[2], [
			[ "X:sort", "select", $item[9], $item[10] ],
			@{$item{body}}
		]
	]; 1 }

# X:sort select
# X:sort "@id"

xsort		: value attrs body
	{ $return = [
		"X:sort", "select", $item{value}, $item{attrs}, $item{body}
	]; 1 }

# X:when "position() = 1" { ... }

xwhen		: value attrs body
	{ $return = [
		"X:when", "test", $item{value}, $item{attrs}, $item{body}
	]; 1 }

# X:attribute "href" { ... }

xattribute	: value attrs body
	{ $return = [
		"X:attribute", "name", $item{value}, $item{attrs}, $item{body}
	]; 1 }

# X:output
# semicolon is optional

xoutput		: attrs body(?)
	{ $return = [
		"X:output", undef, undef, $item{attrs}, $item{body}
	]; 1 }

# "X:copy-of"
# semicolon is optional

xcopyof		: value attrs body(?)
	{ $return = [
		"X:copy-of", "select", $item{value}, $item{attrs}, $item{body}
	]; 1 }

# eof

eofile		: /^\Z/

EOF

###############################################################################

sub format_tree {
	my ($tree, $indent) = @_;
	my $s = '';

	if (!defined $indent) {
		$indent = 0;
		$s .= '<?xml version="1.0" encoding="utf-8"?>' . "\n";
	}

	my $space = "   " x $indent;

	foreach my $el (@{$tree}) {
		if (!defined $el) {
			warn "Undefined element in output.\n";
			$s .= $space . "(undef)" . "\n";
			next;
		}

		if (not ref($el) && defined $el) {
			if ($el =~ /^<!--(.*)-->$/s) {
				my $comment = $1;
				$comment =~ s/--/../sg;
				$el = "<!--" . $comment . "-->";
			}

			$s .= $el;
			next;
		}

		die if ref($el) ne 'ARRAY';

		my $tag = $el->[0];

		if ($tag eq 'tag') {
			my (undef, $name, $attrs, $body) = @{$el};

			$s .= "<" . join(" ", $name, @{$attrs});
			if ($body) {
				$s .= ">" . format_tree($body, $indent + 1)
					. "</$name>";
			} else {
				$s .= "/>";
			}

			next;
		}

		if ($tag =~ m/^X:(.*)/) {
			my $name = "xsl:" . $1;
			my (undef, @a) = @{$el};
			my @attrs;

			while (@a) {
				last if ref($a[0]) eq 'ARRAY';
				my $name = shift @a;
				my $value = shift @a;
				next unless defined $value;
				$value = '"' . $value . '"'
					unless $value =~ /^"/;
				push @attrs, "$name=$value";
			}

			if ($name eq "xsl:stylesheet") {
				push @attrs, 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"';
				push @attrs, 'version="1.0"';
			}

			my ($attrs, $body) = @a;
			$attrs = [ @{$attrs}, @attrs ];

			$s .= "<" . join(" ", $name, @{$attrs});
			
			if ($body && scalar @{$body} > 0) {
				$s .= ">" . format_tree($body, $indent + 1)
					. "</$name>";
			} else {
				$s .= "/>";
			}

			next;
		}

		$s .= format_tree($el, $indent + 1);
	}

	return $s;
}

###############################################################################

my $parser = Parse::RecDescent->new($grammar)
	or die "Failed to create parser.\n";

my $lines;

{
	local $/;
	$lines = <>;
}

my $tree = $parser->startrule($lines)
	or die "Failed to parse $ARGV.\n";
my $formatted = format_tree($tree);

if (defined $output) {
	open STDOUT, ">", $output
		or die "Can't open $output: $!\n";
}

if ($dump) {
	print Dumper($tree);
	exit(0);
}

print $formatted;

###############################################################################
