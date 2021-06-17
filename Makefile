# help: @ Lists available make tasks
help:
	@egrep -oh '[0-9a-zA-Z_\.\-]+:.*?@ .*' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

# clean: @ Cleans the build output directories
.PHONY: clean
clean:
	rm -Rf ./build/site
	rm -Rf ./build/cache
	
# install: @ Installs asciidoctor extensions
install:
	docker-compose run antora npm install asciidoctor asciidoctor-kroki

# build: @ Builds documentation production output (to build/site)
build: clean 
	docker-compose run -u $$(id -u) antora antora generate antora-playbook.yml

# preview: @ Serves documentation output (on port 8051)
preview: build
	docker-compose run --service-ports antora http-server build/site -c-1

# shell: @ Opens bash shell in antora container
shell: CMD ?= /bin/sh
shell:
	docker-compose run -u $$(id -u) antora $(CMD)

# shell: @ Pull the latest ui-bundle.zip
prompt_for_token = echo Enter Github access token:; read GITHUB_AUTH_TOKEN
ui: GITHUB_AUTH_TOKEN ?= 
ui:
	$(if $(GITHUB_AUTH_TOKEN),GITHUB_AUTH_TOKEN=$(GITHUB_AUTH_TOKEN),$(prompt_for_token))
	CURL="curl -H 'Authorization: token $$GITHUB_AUTH_TOKEN' \
	      https://api.github.com/repos/wethinkcode/antora-docs-ui/releases"; \
	ASSET_ID=$$(eval "$$CURL/latest" | jq .assets[0].id); \
	eval "$$CURL/assets/$$ASSET_ID -o tmp/ui-bundle.zip -LJH 'Accept: application/octet-stream'"

