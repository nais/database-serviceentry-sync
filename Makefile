image=docker.pkg.github.com/nais/database-serviceentry-sync/database-serviceentry-sync:0.4

build:
	docker build -t ${image} .

push:
	docker push ${image}

release: build push
