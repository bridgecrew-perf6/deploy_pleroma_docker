INSTALLER = "Scripts/run.sh"

# Build a Pleroma image.
build:
	@$(INSTALLER) prepare
	@$(INSTALLER) install_docker
	@$(INSTALLER) build_image
	@$(INSTALLER) setup_firewall
	@$(INSTALLER) get_cert

# Launch a Pleroma instace(with a PostgreSQL and an Nginx).
run:
	@$(INSTALLER) run

# Use old PostgreSQL data.
importdb:
	@$(INSTALLER) import_database

# Backup custom data.
backup:
	@$(INSTALLER) export_data

# Upgrade Pleroma to lastest version.
update:
	@$(INSTALLER) update

# Show expire date of the SSL certificate.
cert:
	@$(INSTALLER) check_cert


.PHONY: build
