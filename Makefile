# Define variables
PACKER = packer
BUILD = build
SECRETS = secrets/secrets.enc

# Default target - builds all templates

# Build Ubuntu
build-ubuntu:
	PACKER_LOG=0 $(PACKER) build --var-file=packer/credentials.pkr.hcl packer/ubuntu/

# Clean up temporary files
clean:
	rm -rf .packer_cache

