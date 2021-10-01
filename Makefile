compose-build:
	docker-compose build --no-cache
	
compose-up:
	docker-compose up

compose: compose-build compose-up
