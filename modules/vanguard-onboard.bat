:: This script starts Docker Compose services for the TCP platform development environment.
:: You only need to run this once since eagle-recording-dev-compose only needs one round of bootstrapping.

@echo off

docker system prune -a

cd C:/ROOT_DEV_TODO/Vanguard/TCP/platform-dev-environment-compose
docker-compose up -d --remove-orphans

cd C:/ROOT_DEV_TODO/Vanguard/TCP/eagle-recording-dev-compose
git fetch
git checkout no-sql
git pull
docker-compose up -d --remove-orphans
git checkout master

cd C:/ROOT_DEV_TODO/Vanguard/Auto/eagle-vanguard-tools/suites/developing/docker
docker-compose up -d --remove-orphans
