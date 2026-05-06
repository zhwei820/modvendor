build_and_install:
	@echo "Building and installing the project..."
	# Add your build and install commands here
	go build .
	chmod +x modvendor
	mv modvendor ~/go/bin/
	@echo "Build and installation complete."