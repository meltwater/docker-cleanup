all: build

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make              - build the image"
	@echo "   2. make run          - run docker-cleanup"
	@echo "   3. make rm           - destroy docker-cleanup container"
	@echo "   4. make rebuild      - rebuild docker-cleanup container"
	@echo "   5. make restart      - restart docker-cleanup container"
	@echo "   6. make int          - enter the docker-cleanup container on with a bash prompt"

default: build

build:
	docker build --rm -t meltwater/docker-cleanup .

run:
	docker run --env-file ./env.list --name docker-cleanup -v /var/run/docker.sock:/var/run/docker.sock:rw -v /var/lib/docker:/var/lib/docker:rw -d meltwater/docker-cleanup

int:
	docker exec -it docker-cleanup bash

rm:
	docker stop docker-cleanup
	docker rm -f docker-cleanup

rebuild: rm build run

restart: rm run
