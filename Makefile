build:
	gcc -o bin/mongodb-docker main.c
push:
	git add .
	git commit -m "Update"
	git push
