# DuckDNS-Vaultwarden

Fork of [DuckDNS-wg-easy-proxy](https://github.com/ad84/DuckDNS-wg-easy-proxy) replacing wg-easy with vaultwarden

Scripts for [DuckDNS](http://www.duckdns.org/) domain to automate nginx reverse proxy for [vaultwarden](https://github.com/dani-garcia/vaultwarden). Uses [acme.sh](https://github.com/acmesh-official/acme.sh) (for certificate generation and automatic renewal) and docker compose. 

## How to use:


1. clone this repo
 ```
 git clone https://github.com/Alexzander-Hurd/DuckDNS-vaultwarden-setup
 ```

2. `cd` into the project directory, rename `example.env` to `.env` and change the default values & others as required.

3. run the initial install script to bring the containers up and install ssl certificates 
```
sudo ./setup.sh
```
4. the vaultwarden page will now be available at https://vault.yourduckdomain.duckdns.org, everything else will return 404. The ssl certificates will auto-renew every 60 days. 



