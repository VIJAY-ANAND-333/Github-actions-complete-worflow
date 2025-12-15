.PHONY: all 
# Variables
APP_NAME = vijay_car_mod
COMPOSE_FILE = docker-compose.yml
LATEST_TAG = latest
PREVIOUS_TAG = previous

# Check for required files
check-files:
	@if [ ! -f $(COMPOSE_FILE) ]; then echo "Error: $(COMPOSE_FILE) not found"; exit 1; fi
	@if [ ! -f Dockerfile ]; then echo "Error: Dockerfile not found"; exit 1; fi

# Tag the current image as previous
tag-previous:
	docker tag $(APP_NAME):$(LATEST_TAG) $(APP_NAME):$(PREVIOUS_TAG) || true

down: check-files tag-previous
	docker compose -f $(COMPOSE_FILE) down

# Build and run the container
build: check-files tag-previous
	TAG=$(LATEST_TAG) docker compose -f $(COMPOSE_FILE) up -d --build --no-deps
	@echo "Built and ran $(APP_NAME):$(LATEST_TAG) at $(shell date)" >> deploy.log

# Rebuild: Stop, build, and start containers
rebuild: check-files tag-previous
	TAG=$(LATEST_TAG) docker compose -f $(COMPOSE_FILE) down
	TAG=$(LATEST_TAG) docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "Rebuilt and ran $(APP_NAME):$(LATEST_TAG) at $(shell date)" >> deploy.log

# Rollback to the previous image
rollback: check-files
	TAG=$(PREVIOUS_TAG) docker compose -f $(COMPOSE_FILE) down
	TAG=$(PREVIOUS_TAG) docker compose -f $(COMPOSE_FILE) up -d
	@echo "Rolled back to $(APP_NAME):$(PREVIOUS_TAG) at $(shell date)" >> deploy.log

# Clean up unused images
clean:
	docker system prune -a --volumes -f

logs:
	docker compose logs --follow