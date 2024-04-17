
OUT =		libxslt
TEXT =		text
BANNER =	banner
ZIP =		gzip
NGINX_ORG =	/data/www/nginx.org
SHELL =		tools/umasked.sh

XSLS ?=		tools/xslscript.pl
RSYNC =		rsync -v -rpc
CHMOD =		/bin/chmod -R g=u


define	XSLScript
	$(XSLS) -o $(2) $(1)
endef

define	XSLT
	xmllint --noout --valid $2
	xsltproc -o $3							\
		$(shell ff="$(strip $2)"; f=$${ff#xml/*/};		\
		if [ "$$f" != "$$ff" ]; then				\
		[ -f xml/en/$$f ] && echo --stringparam ORIGIN "en/$$f";\
		t=; for l in $(LANGS); do				\
		[ -f "xml/$$l/$$f" ] && t="$$t$$l "; done;		\
		echo --stringparam TRANS "\"$$t\"";			\
		fi)							\
		$(if $4,--stringparam $4 $5)				\
		$1 $2
endef

define 	JPEGNORM
	jpegtopnm $1							\
		| pamscale -width=150					\
		| pnmtojpeg -quality=95 -optimize -dct=float		\
		> $2
endef


COMMON_DEPS =								\
		xml/menu.xml						\
		xml/i18n.xml						\
		dtd/content.dtd						\
		xslt/dirname.xslt					\
		xslt/link.xslt						\
		xslt/style.xslt						\
		xslt/body.xslt						\
		xslt/menu.xslt						\
		xslt/banner.xslt					\
		xslt/content.xslt					\

ARTICLE_DEPS =								\
		$(COMMON_DEPS)						\
		xml/versions.xml					\
		dtd/article.dtd						\
		dtd/module.dtd						\
		xslt/article.xslt					\
		xslt/books.xslt						\
		xslt/directive.xslt					\
		xslt/donate.xslt					\
		xslt/download.xslt					\
		xslt/security.xslt					\
		xslt/versions.xslt					\

NEWS_DEPS =								\
		$(COMMON_DEPS)						\
		dtd/news.dtd						\
		xslt/news.xslt						\

LANGS =		en ru

YEARS = 								\
		2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019	\
		2020 2021 2022 2023

all:		news arx 404 $(LANGS)

news:		$(OUT)/index.html $(OUT)/index.rss
arx:		$(foreach year,$(YEARS),$(OUT)/$(year).html)
404:		$(OUT)/404.html


DIRIND_DEPS =
VARIND_DEPS =

define lang-specific

TOP=
DOCS=
REFS=
FAQ=
include xml/$(lang)/GNUmakefile

$(lang):								\
		$$(foreach f,index $$(TOP),$(OUT)/$(lang)/$$(f).html)	\
		$$(foreach f,index $$(DOCS) $$(REFS) $$(FAQ),		\
		$(OUT)/$(lang)/docs/$$(f).html)

$(OUT)/$(lang)/docs/index.html:						\
		$$(foreach f,$$(DOCS) $$(REFS),				\
		$(OUT)/$(lang)/docs/$$(f).html)

$(OUT)/$(lang)/docs/faq.html:						\
		$$(foreach f,$$(FAQ),$(OUT)/$(lang)/docs/$$(f).html)

ifneq (,$$(filter dirindex,$$(DOCS)))
DIRIND_DEPS +=	xml/$(lang)/docs/dirindex.xml
xml/$(lang)/docs/dirindex.xml:						\
		$$(foreach f,$$(REFS),xml/$(lang)/docs/$$(f).xml)	\
		xslt/dirindex.xslt
	echo "<modules>$$(patsubst %,					\
	<module name=\"%\"/>, $$(filter %.xml,$$^))</modules>" |	\
	xsltproc -o - --stringparam LANG $(lang)			\
	xslt/dirindex.xslt - |						\
	sed 's;xml/[^/]*/docs/;;g' > $$@
endif

ifneq (,$$(filter varindex,$$(DOCS)))
VARIND_DEPS +=	xml/$(lang)/docs/varindex.xml
xml/$(lang)/docs/varindex.xml:						\
		$$(foreach f,$$(REFS),xml/$(lang)/docs/$$(f).xml)	\
		xslt/varindex.xslt
	echo "<modules>$$(patsubst %,					\
	<module name=\"%\"/>, $$(filter %.xml,$$^))</modules>" |	\
	xsltproc -o - --stringparam LANG $(lang)			\
	xslt/varindex.xslt - |						\
	sed 's;xml/[^/]*/docs/;;g' > $$@
endif

endef

$(foreach lang, $(LANGS), $(eval $(call lang-specific)))

$(foreach lang, $(LANGS), $(OUT)/$(lang)/docs/dirindex.html): $(DIRIND_DEPS)

$(foreach lang, $(LANGS), $(OUT)/$(lang)/docs/varindex.html): $(VARIND_DEPS)

$(OUT)/index.html:							\
		xml/index.xml						\
		$(NEWS_DEPS)
	$(call XSLT, xslt/news.xslt, $<, $@)

$(OUT)/index.rss:							\
		xml/index.xml						\
		$(NEWS_DEPS)						\
		xslt/rss.xslt
	$(call XSLT, xslt/rss.xslt, $<, $@)


$(foreach year,$(YEARS),$(OUT)/$(year).html):				\
		xml/index.xml						\
		$(NEWS_DEPS)
	$(call XSLT, xslt/news.xslt, $<, $@, YEAR, $(basename $(notdir $@)))

$(OUT)/404.html:							\
		xml/404.xml						\
		$(COMMON_DEPS)						\
		dtd/error.dtd						\
		xslt/error.xslt
	$(call XSLT, xslt/error.xslt, $<, $@)

$(OUT)/%.html:	xml/%.xml						\
		$(ARTICLE_DEPS)
	$(call XSLT, xslt/article.xslt, $<, $@)


# Prevent intermediate .xslt files from being removed.
$(patsubst xsls/%.xsls,xslt/%.xslt,$(wildcard xsls/*.xsls)):

xslt/%.xslt:	xsls/%.xsls
	mkdir -p $(dir $@)
	$(call XSLScript, $<, $@)


genapi:
	$(MAKE) -C yaml


images:									\
		binary/books/complete_nginx_cookbook_2019.jpg		\
		binary/books/deploying_nginx_as_api_gateway.jpg		\
		binary/books/high_performance_caching.jpg		\
		binary/books/loadbalancing_cloud.jpg			\
		binary/books/f5_to_nginx_migration.jpg			\
		binary/books/cisco_ace_to_nginx.jpg			\
		binary/books/modsec3_and_nginx.jpg			\
		binary/books/nginx_cookbook.jpg				\
		binary/books/nginx_http_server_3rd_ed.jpg		\
		binary/books/nginx_troubleshooting.jpg			\
		binary/books/nginx_richtig_konfigurieren.jpg		\
		binary/books/practical_nginx_guide_jp.jpg		\
		binary/books/nginx_pocket_reference_jp.jpg		\
		binary/books/nginx_http_server_jp.jpg			\
		binary/books/nginx_1_web_server.jpg			\
		binary/books/nginx_http_server.jpg			\
		binary/books/nginx_in_practice.jpg			\
		binary/books/mastering_nginx.jpg			\
		binary/books/nginx_http_server_2nd_ed.jpg		\
		binary/books/instant_nginx_starter.jpg			\
		binary/books/nginx_module_extension.jpg			\
		binary/books/nginx_high_performance.jpg			\
		binary/books/nginx_essentials.jpg			\
		binary/books/nginx_http_server_4th_ed.jpg

binary/books/complete_nginx_cookbook_2019.jpg:				\
		sources/ebk-ORM-NGINX-Cookbook-mega-2019-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/deploying_nginx_as_api_gateway.jpg:			\
		sources/ebk-Deploying-NGINX-Plus-as-API-Gateway-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/high_performance_caching.jpg:				\
		sources/ebk-High-Performance-Caching-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/loadbalancing_cloud.jpg:					\
		sources/ebk-ORM-Load-Balancing-in-the-Cloud-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/f5_to_nginx_migration.jpg:				\
		sources/ebk-F5-BIG-IP-to-NGINX-Plus-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/cisco_ace_to_nginx.jpg:					\
		sources/ebk-Cisco-ACE-to-NGINX-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/modsec3_and_nginx.jpg:					\
		sources/ebk-ModSecurity-3.0-and-NGINX-150x185.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_cookbook.jpg:	sources/B05431_0.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_http_server_3rd_ed.jpg:				\
		sources/0337OS_4846_Nginx.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_troubleshooting.jpg:					\
		sources/51T7ds6JdBL._SX404_BO1,204,203,200_.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_richtig_konfigurieren.jpg:	sources/5106%2B0b2pbL.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/practical_nginx_guide_jp.jpg:	sources/9784774178660.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_pocket_reference_jp.jpg:				\
		sources/51JYTdy8jrL._SX335_BO1,204,203,200_.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_http_server_jp.jpg:	sources/1106030720.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_1_web_server.jpg:					\
		sources/Nginx\ 1\ Web\ Server\ Implementation\ Cookbook.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, "$<", $@)

binary/books/nginx_http_server.jpg:	sources/0868OS_MockupCover.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_in_practice.jpg:	sources/20807089-1_o.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/mastering_nginx.jpg:	sources/3311OS_4851_Mastering\ NGINX_0.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, "$<", $@)

binary/books/nginx_http_server_2nd_ed.jpg:	sources/2322OS_cov.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/instant_nginx_starter.jpg:	sources/5125OS_cov.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_module_extension.jpg:	sources/3046OS_cover.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_high_performance.jpg:	sources/1839OS.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_essentials.jpg:	sources/B04282_MockupCover_Normal.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

binary/books/nginx_http_server_4th_ed.jpg:	sources/9781788623551.jpg
	mkdir -p $(dir $@)
	$(call JPEGNORM, $<, $@)

.PHONY:	gzip
gzip:	rsync_gzip
	$(MAKE) do_gzip

rsync_gzip:
	$(CHMOD) $(OUT) $(TEXT) $(BANNER)
	$(RSYNC) --delete --exclude='*.gz' $(OUT)/ $(TEXT)/ $(BANNER) $(ZIP)/

do_gzip:	$(addsuffix .gz, $(wildcard $(ZIP)/*.html))		\
		$(addsuffix .gz,					\
			$(foreach lang, $(LANGS),			\
			$(foreach dir, . docs docs/dev docs/faq docs/http docs/mail docs/njs docs/stream, \
			$(wildcard $(ZIP)/$(lang)/$(dir)/*.html))))	\
		$(addsuffix .gz, $(wildcard $(ZIP)/$(BANNER)/*.html))	\
		$(ZIP)/index.rss.gz					\
		$(ZIP)/LICENSE.gz					\
		$(ZIP)/en/CHANGES.gz					\
		$(addsuffix .gz, $(wildcard $(ZIP)/en/CHANGES-?.?))	\
		$(addsuffix .gz, $(wildcard $(ZIP)/en/CHANGES-?.??))	\
		$(ZIP)/ru/CHANGES.ru.gz					\
		$(addsuffix .gz, $(wildcard $(ZIP)/ru/CHANGES.ru-?.?))	\
		$(addsuffix .gz, $(wildcard $(ZIP)/ru/CHANGES.ru-?.??))	\
		$(addsuffix .gz, $(wildcard $(ZIP)/keys/*.key))		\

	find $(ZIP) -type f ! -name '*.gz' -exec test \! -e {}.gz \; -print

	find $(ZIP) -type f -name '*.gz' | \
		while read f ; do test -e "$${f%.gz}" || rm -fv "$$f" ; done

$(ZIP)/%.gz:		$(ZIP)/%
		rm -f $<.gz
		gzip -9cn $< > $<.gz
		touch -r $< $<.gz

draft:	all
	$(CHMOD) $(OUT)
	$(RSYNC) --delete $(OUT)/ $(NGINX_ORG)/$(OUT)/

.PHONY:	binary
binary:
	$(CHMOD) binary
	$(RSYNC) binary/ $(NGINX_ORG)/

copy:
	$(CHMOD) $(ZIP) binary
	$(RSYNC) $(ZIP)/ binary/ $(NGINX_ORG)/
	$(RSYNC) --delete $(foreach lang, $(LANGS), $(ZIP)/$(lang))	\
		$(NGINX_ORG)/

dev:	xslt/version.xslt sign
dev:	NGINX:=$(shell xsltproc xslt/version.xslt xml/versions.xml)

stable:	xslt/version.xslt sign
stable:	NGINX:=$(shell xsltproc --stringparam VERSION stable		\
	xslt/version.xslt xml/versions.xml)

legacy:	xslt/version.xslt sign
legacy:	NGINX:=$(shell xsltproc --stringparam VERSION legacy		\
	xslt/version.xslt xml/versions.xml)

any:	sign
any:	NGINX=0.7.69


sign:
	@echo sign nginx-$(NGINX)

	gpg -sab binary/download/nginx-$(NGINX).tar.gz
	gpg -sab binary/download/nginx-$(NGINX).zip


dir.map:	xslt/dirmap.xslt xml/en/docs/dirindex.xml		\
		xml/en/docs/varindex.xml
	@xsltproc -o - xslt/dirmap.xslt xml/en/docs/dirindex.xml	\
	xml/en/docs/varindex.xml > $@

ifeq ($(patsubst %.nginx.com,YES,$(shell hostname)), YES)
all:	images

ifeq ($(NGINX_ORG), /data/www/nginx.org)
all:	dir.map
copy:	copy_dirmap
.PHONY:	copy_dirmap
copy_dirmap:
	/usr/local/bin/copy_dirmap.sh dir.map $(NGINX_ORG)
endif

draft:	copy_draft
.PHONY:	copy_draft
copy_draft:
	/usr/local/bin/copy_draft.sh $(NGINX_ORG)
endif

clean:
	rm -rf $(ZIP) $(OUT) xml/*/docs/dirindex.xml dir.map 		\
	xml/*/docs/varindex.xml

.DELETE_ON_ERROR:
