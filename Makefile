.PHONY: build run stop

build:
	docker-compose build --pull

run:
	docker-compose run --rm ppmi

stop:
	docker-compose stop