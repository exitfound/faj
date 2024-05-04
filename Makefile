# Команда для первоначальной инициализации Jenkins:
build: prepare compose-build post

prepare:
	mkdir -p backup/ data/ \
	&& sudo chown -R 1000:1000 backup/ data/
compose-build:
	docker compose -f jenkins-docker-compose.yaml up -d --build
post:
	mv jcasc inactive-jcasc

# Команда для запуска Jenkins в обычном режиме:
start: compose-start

compose-start:
	docker compose -f jenkins-docker-compose.yaml start

# Команда для остановки Jenkins в обычном режиме:
stop: compose-stop

compose-stop:
	docker compose -f jenkins-docker-compose.yaml stop

# Команда для полного удаления и очистки Jenkins:
down: compose-down delete

compose-down:
	docker compose -f jenkins-docker-compose.yaml down \
	&& docker container prune --force \
	&& docker image prune --force --all \
	&& sudo chown -R 1000:1000 inactive-jcasc \
	&& mv inactive-jcasc jcasc
delete:
	rm -rf ./data
