# thanks for https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

compose-build:     ## Build the Docker Image of the environment needed to run the code.
	docker-compose build --no-cache
	
compose-up: compose-build     ## Start the Docker Container with a Jupyter Lab for code execution.
	docker-compose up

compose: compose-up     ## Build the Docker Image and start it for code execution on a Jupyter Lab environment.
