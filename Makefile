ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
IMAGE_NAME := fscrawler
TAG := :latest

# Run Options
RUN_PORTS := -p 5545:80

PLATFORMS := linux/amd64,linux/arm64,linux/arm/v7

all: build

build:
	$$env:DOCKER_BUILDKIT = 1;docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --target buildArtifact --output type=tar,dest=dist.tar .

build_multiarch:
	docker buildx build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --platform $(PLATFORMS) .

test:
	docker 
run: build
	docker run -d $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

package:
	$$PackageFileName = "$$("$(IMAGE_NAME)" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $$PackageFileName

size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

publish:
	docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG); docker logout