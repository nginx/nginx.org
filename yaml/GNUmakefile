API_HEAD=../xml/en/docs/http/ngx_http_api_module_head.xml

../xml/en/docs/http/ngx_http_api_module.xml:				\
		nginx_api.yaml						\
		yaml2xml.py						\
		$(API_HEAD)
	cat $(API_HEAD) > $@
	./yaml2xml.py nginx_api.yaml >> $@
	echo "</module>" >> $@

.DELETE_ON_ERROR:
