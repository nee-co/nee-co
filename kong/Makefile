REVISION=`git rev-parse HEAD`

build:
	docker build --no-cache --tag kong-application --build-arg REVISION=$(REVISION) .

dev-build:
	docker build --tag kong-application --build-arg REVISION=$(REVISION) .
