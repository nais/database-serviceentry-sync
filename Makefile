image=navikt/db-se-sync:0.2

build:
	docker build -t ${image} .

push:
	docker push ${image}

release: build push
