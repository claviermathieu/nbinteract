.PHONY: help serve build publish html install

NOTEBOOK_OPTS = --port 8889 --no-browser --NotebookApp.allow_origin="*" --NotebookApp.disable_check_xsrf=True --NotebookApp.token='' --MappingKernelManager.cull_idle_timeout=300

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

serve: start_notebook start_webpack ## Start Python and webpack watch (must run with make -j2)
	@echo "Serving..."

build: build_py build_js ## Build python package and JS bundle
	@echo "Built python package and JS bundle"

publish: publish_py publish_js ## Build python package and JS bundle
	@echo "Published python package and JS bundle"

install: ## Installs Python package locally
	pip install -e .

html: ## Convert notebooks to interactive HTML
	cd notebooks/textbook && jupyter nbconvert --to interact *.ipynb
	git add notebooks/textbook
	git commit -m "Convert notebooks"

start_notebook:
	python -m notebook $(NOTEBOOK_OPTS)

start_webpack:
	# yarn run watch
	yarn run serve

build_py: ## Build python package
	python setup.py bdist_wheel

build_js: ## Build Javascript bundle
	yarn run build

publish_py: build_py ## Publish nbinteract to PyPi
	twine upload dist/*

publish_js: build_js ## Publish nbinteract to npm
	yarn publish
