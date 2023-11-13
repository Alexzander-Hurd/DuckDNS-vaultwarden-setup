#!/usr/bin/env bash
#set up some colours 
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e  "${GREEN}Setting up WireGuard server..."
docker compose up -d --build

export $(grep -v '^#' .env | xargs -d '\n') # import .env variables



echo -e  "${NC}"
echo -e "Getting, and installing certificates (and setting auto-renewals) for ${GREEN}$SERVER_HOST, .$SERVER_HOST & *.$SERVER_HOST"
echo -e  "${NC}This may take a little time ."
sleep 5

#vault.yourdomain.duckdns.org
docker exec acme.sh --issue --dns dns_duckdns --insecure -d vault.$SERVER_HOST -k ec-256 --server letsencrypt

docker exec -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=$SERVER_HOST -e DEPLOY_DOCKER_CONTAINER_KEY_FILE="/etc/nginx/ssl/vault.$SERVER_HOST/key.pem" -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="/etc/nginx/ssl/vault.$SERVER_HOST/full.pem" -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="nginx -s reload" acme.sh --deploy -d vault.$SERVER_HOST --ecc --deploy-hook docker

# main domain for verification - duckdns has same txt record for all subdomains, this way domain is already verified when we make the wildcard later 
docker exec acme.sh --issue --dns dns_duckdns --insecure -d $SERVER_HOST -k ec-256  --server  letsencrypt
docker exec -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=$SERVER_HOST -e DEPLOY_DOCKER_CONTAINER_KEY_FILE="/etc/nginx/ssl/$SERVER_HOST/key.pem" -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="/etc/nginx/ssl/$SERVER_HOST/full.pem" -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="nginx -s reload" acme.sh --deploy -d $SERVER_HOST --ecc --deploy-hook docker

# wild card cert 
docker exec acme.sh --issue --dns dns_duckdns --insecure -d *.$SERVER_HOST -d $SERVER_HOST -k ec-256  --server  letsencrypt
docker exec -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=$SERVER_HOST -e DEPLOY_DOCKER_CONTAINER_KEY_FILE="/etc/nginx/ssl/wildcard.$SERVER_HOST/key.pem" -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="/etc/nginx/ssl/wildcard.$SERVER_HOST/full.pem" -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="nginx -s reload" acme.sh --deploy -d *.$SERVER_HOST --ecc --deploy-hook docker
echo -e ""
docker exec nginx sh -c 'mv /etc/nginx/conf.d/default-server.conf.bak /etc/nginx/conf.d/default-server.conf'
docker exec nginx sh -c 'mv /etc/nginx/conf.d/vw.conf.bak /etc/nginx/conf.d/vw.conf'
docker exec nginx sh -c 'nginx -s reload'

echo -e "${GREEN}All done."
echo -e "${NC}The vaultwarden web interface is avaible at https://vault.${SERVER_HOST} "



unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
