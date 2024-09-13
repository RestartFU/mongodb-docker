build:
	v . -o ./bin/mongodb-docker
push:
	git add .
	git commit -m "Update"
	git push
