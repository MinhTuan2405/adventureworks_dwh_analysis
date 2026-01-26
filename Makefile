# # --- CONFIGURATION ---
# ifneq (,$(wildcard ./.env))
#     include .env
#     export
# endif

# # Configure SeaweedFS S3
# S3_PORT ?= 8333
# S3_HOST ?= localhost
# # Define the list of data layers
# LAYERS := lakehouse

# # --- TARGETS ---
# .PHONY: init-layers check-layers clean-layers

# # 1. Create all 3 buckets: bronze, silver, gold
# init-layers:
# 	@echo "Initial Medallion Architecture on SeaweedFS..."
# 	@for layer in $(LAYERS); do \
# 		echo "  Create bucket '$$layer'..."; \
# 		curl -s -X PUT "http://$(S3_HOST):$(S3_PORT)/$$layer" > /dev/null; \
# 	done
# 	@echo "Initialization complete!"

# # 2. Check if the buckets already exist
# check-layers:
# 	@echo "List of Buckets currently on SeaweedFS:"
# 	@curl -s "http://$(S3_HOST):$(S3_PORT)/"
# 	@echo ""

# # 3. Delete all 3 buckets (Use with caution when you want to reset)
# clean-layers:
# 	@echo "WARNING: Deleting all Medallion data..."
# 	@for layer in $(LAYERS); do \
# 		echo "   Deleting bucket '$$layer'..."; \
# 		curl -s -X DELETE "http://$(S3_HOST):$(S3_PORT)/$$layer" > /dev/null; \
# 	done
# 	@echo "Cleanup complete."

# --- CONFIGURATION ---
ifneq (,$(wildcard ./.env))
include .env
export
endif

# Configure SeaweedFS S3
S3_PORT ?= 8333
S3_HOST ?= localhost

# Define the list of buckets
BUCKETS := lakehouse

# --- TARGETS ---
.PHONY: init-buckets check-buckets clean-buckets

# 1. Create bucket
init-buckets:
	@echo "Initializing buckets on SeaweedFS..."
	@for bucket in $(BUCKETS); do \
		echo "  Creating bucket '$$bucket'..."; \
		curl -s -X PUT "http://$(S3_HOST):$(S3_PORT)/$$bucket" > /dev/null; \
	done
	@echo "Initialization complete!"

# 2. Check if buckets exist
check-buckets:
	@echo "List of Buckets currently on SeaweedFS:"
	@curl -s "http://$(S3_HOST):$(S3_PORT)/"
	@echo ""

# 3. Delete all buckets (Use with caution)
clean-buckets:
	@echo "WARNING: Deleting all buckets..."
	@for bucket in $(BUCKETS); do \
		echo "   Deleting bucket '$$bucket'..."; \
		curl -s -X DELETE "http://$(S3_HOST):$(S3_PORT)/$$bucket" > /dev/null; \
	done
	@echo "Cleanup complete."