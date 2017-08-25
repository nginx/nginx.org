#!/usr/bin/env python

# Copyright (C) Nginx, Inc.

import sys, re, datetime

from yaml import load, dump
from collections import OrderedDict

try:
    from yaml import CLoader as Loader, CDumper as Dumper, resolver as resolver

except ImportError:
    from yaml import Loader, Dumper, resolver


# primitive markdown parser and utf encoding for output
def node_description(node):

    text = node.get('description')
    if text == None:
        return ""

    #
    t = re.sub('\<code\>', r'<literal>', text)
    t = re.sub('\</code\>', r'</literal>', t)

    t = re.sub('\<i\>', r'<value>', t)
    t = re.sub('\</i\>', r'</value>', t)

    t = re.sub('\<a href=\"(.*)\"\>(.*)\</a\>', r'<link url="\1">\2</link>', t)

    # [desc](url)
    t = re.sub('\[(.*)\]\((.*)\)', r'<link url="\2">\1</link>', t)

    # ** foo ** is value
    t = re.sub('[*?][*?](\w+)[*?][*?]', r'<value>\1</value>', t)

    # * foo * is literal
    t = re.sub('[*?](\w+)[*?]', r'<literal>\1</literal>', t)


    return t.encode('utf-8').rstrip()


def pretty_endpoint(ep):
    return ep.replace('/',' ').replace('_',' ')


# human-readable html element id based on path
def path_to_id(path):
    if path == '/':
        return 'root'

    str = path.replace('/', '_')
    str = str.replace('{', '')
    str = str.replace('}','')

    return uncamelcase(str[1:])


def multiple(str):
    fin2 = str[-2:]
    fin = str[-1:]

    if fin2 == 's' or fin2 == 'sh' or fin2 == 'ch':
        last = 'es'
    elif fin == 'x' or fin == 'z':
        last = 'es'
    else:
        last = 's'

    return str + last

def uncamelcase(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def make_defid(str):
    return 'def_' + uncamelcase(str)

# returns name of a referenced object
def get_refname(obj):
    return obj['$ref'][14:] # remove '#/definitions/'


# returns referenced object itself from global definitions table
def node_from_ref(doc, obj):
    return doc['definitions'][get_refname(obj)]


def render_doc(doc):

    out = "<section id=\"endpoints\" name=\"Endpoints\">\n"
    out += render_paths(doc)
    out += "</section>\n"

    # dry run, perform refcount
    render_defs(doc)

    out += "<section id=\"definitions\" name=\"Response Objects\">\n"
    out += render_defs(doc)
    out += "</section>\n"

    return out


def render_paths(doc):

    global curr_endpoint

    paths = doc['paths']

    out = "<para>\n"
    out += "<list type=\"tag\">\n"

    for path_key in paths:
        path_id = path_to_id(path_key)
        curr_endpoint = path_key
        out += render_path(doc, path_key, paths[path_key], path_id)

    curr_endpoint = None

    out += "</list>\n"
    out += "</para>\n"

    return out


def render_defs(doc):

    out = "<para>\n"
    out += "<list type=\"bullet\">\n"

    for d in doc['definitions']:

        if refs.get(d) == None:
            continue

        node = doc['definitions'][d]

        out += "<listitem id=\"%s\">\n" % make_defid(d)
        title = node.get('title', '')

        out += "<para>%s:</para>\n" % title

        out += render_node(doc, d, node, True)

        out += "</listitem>\n"

    out += "</list>\n"
    out += "</para>\n"

    return out


def render_path(doc, path_key, path, path_id):

    out = "<tag-name id=\"%s\" name=\"%s\">\n" % (path_id, path_key)
    out += "<literal>%s</literal>\n" % path_key
    out += "</tag-name>\n"

    out += "<tag-desc>\n"

    # List of common method parameters
    for method_key in path:
        if method_key != 'parameters':
            continue

        out += "Parameters common for all methods:\n"
        out += render_parameters(doc, path[method_key])


    # List of methods for this path
    out += '<para>Supported methods:</para>\n'
    out += '<list type="bullet" compact="yes">\n'


    for method_key in ['get', 'post', 'patch', 'delete']:

        if path.get(method_key) == None:
            continue

        method = path[method_key]

        id = method['operationId']
        summ = method['summary']
        desc = node_description(method)
        name = method_key.upper()

        out += "<listitem id=\"%s\">\n" % id
        out += "<literal>%s</literal> - %s\n" % (name, summ)
        out += "<para>%s</para>\n" % desc

        out += render_method(doc, name, method)

        out += "</listitem>\n"

    out += "</list>\n"
    out += "</tag-desc>\n"

    return out


def render_method(doc, method_name, method):

    out = ""

    if method.get('parameters'):
        out += "<para>\n"
        out += "Request parameters:\n"
        out += render_parameters(doc, method['parameters'])
        out += "</para>\n"

    out += "<para>\n"
    out += "Possible responses:\n"
    out += "</para>\n"

    out += "<list type=\"bullet\">\n"

    for response_key in method['responses']:
        out += "<listitem>"
        out += render_response(doc, response_key, method['responses'][response_key])
        out += "</listitem>\n"

    out += "</list>\n"

    return out


def render_parameters(doc, params):

    out = '<list type="tag">\n'

    for p in params:

        out += "<tag-name><literal>%s</literal>\n" % p['name']
        out += "("

        out += render_node(doc, None, p, True)

        if p.get("required"):

            if p["required"] == True:
                out += ", required"
            else:
                out += ", optional"
        else:
            out += ", optional"

        out += ")"

        out += "</tag-name>\n"
        out += "<tag-desc>\n"

        desc = node_description(p)
        out += desc

        out += "</tag-desc>\n"

    out += "</list>\n"

    return out


def render_response(doc, response_key, response):

    out = ""

    desc = node_description(response)

    out += response_key + " - " + desc

    if response.get('schema'):
        out += ", returns "
        out += render_node(doc, None, response)

    return out



def render_reference(doc, nodename, node):

    global in_array, refs

    out = ""

    ref = get_refname(node)

    refnode = node_from_ref(doc, node)

    if refnode.get('additionalProperties'):
        # in entries

        out += "a collection of "
        ref = get_refname(refnode['additionalProperties'])
        target = node_from_ref(doc, refnode['additionalProperties'])
        label = target.get('title', ref)
        out += "\"<link id=\"%s\">%s</link>\"" % (make_defid(ref), label)
        out += " objects"
        refs[ref] = 1
        if curr_endpoint != None:
            out += " for all %s" % pretty_endpoint(curr_endpoint)

        return out

    # arrays and primitive types are printed immediately
    nt = refnode.get('type', 'object')
    title = refnode.get('title', ref)
    if nt == 'object':
        if in_array == True:
            title = multiple(title)

        out += "<link id=\"%s\">%s</link>" % (make_defid(ref), title)
        refs[ref] = 1

    elif nt  == 'array':

        if nodename == 'peers':
            ref = get_refname(refnode['items'])
            out += "An array of:"
            refnode = node_from_ref(doc, refnode['items'])
            out += render_node(doc, ref, refnode, True)
            return out

        out += "an array of "

        in_array = True
        out += render_node(doc, nodename, refnode['items'], True)
        in_array = False
    else:
        # dead code actually
        out += "<literal>%s</literal>\n" % nt

    return out


# displays object recursively if described inline, or generates links
def render_node(doc, nodename, node, show_type=False):

    if node.get('$ref'):
        return render_reference(doc, nodename, node)

    elif node.get('schema'):
        return render_reference(doc, nodename, node['schema'])

    out = ""

    if node.get('additionalProperties'):
        # in definitions
        ref = get_refname(node['additionalProperties'])
        target = node_from_ref(doc, node['additionalProperties'])
        label = target.get('title', ref)
        desc = node_description(node)
        out += "<para>%s</para><para>A collection of " % desc
        out += "\"<link id=\"%s\">%s</link>\"" % (make_defid(ref), label)
        refs[ref] = 1
        out += " objects</para>\n"

        return out

    nt = node.get('type', 'object')

    if nt == 'object':
        out += render_object(doc, node)

    elif nt == 'array':
        desc = node_description(node)
        out += "<para>%s</para>\n" % desc
        out += "array element type:\n"
        out += render_node(doc, nodename, node['items'], True)

    else:
        if show_type:
            if in_array == True:
                out += "%s" % multiple(node['type'])
            else:
                out += "<literal>%s</literal>" % node['type']

    if node.get('example'):
        out += render_example(node['example'])

    return out

def json_simple_type(obj):

    if isinstance(obj, bool):
        if obj == True:
            return 'true'
        else:
            return 'false'

    elif isinstance(obj, str):
        return '"' + obj + '"'

    elif isinstance(obj,datetime.datetime):
        t = obj.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
        z = obj.strftime("Z%Z")
        return '"' + t + z + '"'

    else:
        return str(obj)

def render_example(obj, level = 0):

    out = ""

    if level == 0:
        if isinstance(obj, dict) or isinstance(obj, list):
            out += "<para>Example:</para>\n"
        else:
            out += "Example: <literal>%s</literal>\n" % json_simple_type(obj)
            return out

        out += "<example>\n"

    indent = '  ' * level
    next_indent = '  ' * (level + 1)

    if isinstance(obj, dict):
        out += '{\n'
        i = 0
        last = len(obj)
        for key in obj:
            out += next_indent + '"' + str(key) + '" : '
            out += render_example(obj[key], level + 1)
            if i != last - 1:
                out += ','
            out += '\n'
            i = i + 1
        out += indent + "}"

    elif isinstance(obj, list):
        out += '[\n'
        i = 0
        last = len(obj)
        for item in obj:
            out += next_indent
            out += render_example(item, level + 1)
            if i != last - 1:
                out += ','
            out += '\n'
            i = i + 1
        out += indent + "]"
    else:
        out += json_simple_type(obj)

    if level == 0:
        out += "</example>\n"


    return out


def render_object(doc, obj):

    out = ""

    if obj.get('description'):
        desc = node_description(obj)
        out += desc

    if obj.get('properties') == None:
        return out

    out += '<list type="tag">\n'
    for p in obj['properties']:

        prop = obj['properties'][p]

        out += "<tag-name>\n"
        out += "<literal>%s</literal>" % p

        if prop.get('properties') or prop.get('type') == 'object':
            obj_type = None             # there is nested object
        else:
            if prop.get('type'):
                obj_type = prop['type'] # basic type
            else:
                obj_type = None         # there is a reference

        if obj_type != None:
            out += " (<literal>%s</literal>)\n" % obj_type

        out += "</tag-name>\n"
        out += "<tag-desc>\n"

        if prop.get('description') and obj_type != None:
            desc = node_description(prop)
            out += desc + '\n'

        out += render_node(doc, p, prop)

        out += "</tag-desc>\n"
    out += "</list>\n"

    return out


###############################################################################

if len(sys.argv) < 2:
    print("Usage: %s <nginx_api.yaml>" % sys.argv[0])
    sys.exit(1)

refs = dict()
curr_endpoint = None
in_array = False

def ordered_load(stream, Loader=Loader, object_pairs_hook=OrderedDict):
    class OrderedLoader(Loader):
        pass
    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        resolver.BaseResolver.DEFAULT_MAPPING_TAG,construct_mapping)
    return load(stream, OrderedLoader)

with open(sys.argv[1], 'r') as src:
    content = src.read()
    doc = ordered_load(content, Loader=Loader)
    print(render_doc(doc))
