.DEFAULT_GOAL := run

.PHONY: build
build:
	docker build . -t demo

.PHONY: run
run:
	docker run -d --rm -p 4000:4000 --name demo -t demo

.PHONY: stop
stop:
	docker stop demo

.PHONY: connect
connect:
	docker exec -it demo bash
