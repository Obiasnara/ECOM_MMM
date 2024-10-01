# List of commands to build and run the application

## Build the application

./gradlew -Pprod clean bootJar

## Build the Docker image (from Dockerfile)

docker build . -t obiasnara/mmm_repo

## Push the Docker image to Docker Hub

docker push obiasnara/mmm_repo:latest

## Run the Docker container (anywhere)

docker-compose -f ./src/main/docker/app.yml up -d
