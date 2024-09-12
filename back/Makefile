compose = docker compose
exec_container = $(compose) exec -T app

init:
	@$(MAKE) _generate-env
	@$(MAKE) _generate-key
	@$(MAKE) _generate-cert

up:
	$(compose) kill
	$(compose) build
	$(compose) up -d

stop:
	$(compose) stop

down:
	$(compose) down -v

_generate-key:
	chmod +x ./generate_key.sh
	./generate_key.sh

_generate-env:
	@if [ -f .env ]; then \
		echo ".env file already exists, skipping generation"; \
	else \
		cp .env.example .env; \
		echo "Copied .env.example to .env"; \
	fi

_generate-cert:
	@if [ ! -d certs ]; then \
		mkdir certs; \
	fi
	@if [ ! -f certs/nginx.crt ]; then \
		openssl req -x509 -newkey rsa:2048 -keyout certs/nginx.key -out certs/nginx.crt -days 365 -nodes -subj "/C=FR/ST=Île-de-France/L=Paris/O=Internet Widgits Pty Ltd/OU=IW3/CN=Kiwi Collective/emailAddress=nbarbarisi@myges.fr"; \
		echo "Generated certs/nginx.crt"; \
	else \
		echo "certs/nginx.crt already exists, skipping generation"; \
	fi

logs:
	$(compose) logs -f

exec:
	$(exec_container) $(cmd)

test:
	$(exec_container) go test -v ./...

ssh:
	$(exec_container) /bin/sh

test-coverage:
	$(exec_container) go test -v -coverprofile=tmp/coverage.out ./...
	$(exec_container) go tool cover -html=tmp/coverage.out -o tmp/coverage.html
