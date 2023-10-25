# Variables
IMAGE_NAME = bookapp
ECR_REGISTRY = 731117654744.dkr.ecr.eu-central-1.amazonaws.com
ECR_REPOSITORY = my-ello-ecs-repository
FULL_IMAGE_NAME = $(ECR_REGISTRY)/$(ECR_REPOSITORY):latest

# Phony target to ensure that 'make build' always runs
.PHONY: build
build:
	@echo "Building Docker image..."
	docker build -t $(FULL_IMAGE_NAME) .

# Phony target to ensure that 'make push' always runs
.PHONY: push
push: build
	@echo "Logging in to Amazon ECR..."
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $(ECR_REGISTRY)
	@echo "Pushing Docker image to ECR..."
	docker push $(FULL_IMAGE_NAME)

