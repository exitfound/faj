# Ряд команд для первоначальной инициализации Jenkins в системе:
build: build-prepare build-compose build-post

build-prepare:
	mkdir -p backup/ data/ \
	&& sudo chown -R 1000:1000 backup/ data/
build-compose:
	docker compose -f jenkins-docker-compose.yaml up -d --build --force-recreate
build-post:
	mv jcasc inactive-jcasc \
	&& sudo chown -R 1000:1000 inactive-jcasc


# Ряд команд для запуска Jenkins в стандартном режиме (без повторной сборки):
start: start-compose

start-compose:
	docker compose -f jenkins-docker-compose.yaml start \
	&& sudo rm -rf jcasc/


# Команды для остановки Jenkins в стандартном режиме (без удаления данных):
stop: stop-compose

stop-compose:
	docker compose -f jenkins-docker-compose.yaml stop


# Команда для повторной сборки Jenkins на базе текущего Dockerfile:
rebuild: rebuild-compose

rebuild-compose:
	docker compose -f jenkins-docker-compose.yaml build --no-cache


# Команды для полного удаления и очистки системы от Jenkins:
down: down-compose down-clean

down-compose:
	docker compose -f jenkins-docker-compose.yaml down \
	&& docker container prune --force \
	&& docker image prune --force --all \
	&& sudo rm -rf jcasc \
	&& mv inactive-jcasc jcasc
down-clean:
	rm -rf ./data ./backup
