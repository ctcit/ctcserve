docker-compose start -d
${WD}=$P{WD}
docker run --rm -it --name certbot -v "${WD}/../letsencrypt/etc:/etc/letsencrypt" -v "${WD}/../letsencrypt/lib:/var/lib/letsencrypt" -v "${WD}/www:/var/www" -v "${WD}/../letsencrypt/log:/var/log/letsencrypt" certbot/certbot certonly --webroot  -m nickedwrds@gmail.com  --agree-tos --webroot-path=/var/www --staging -d ctc.05081986.xyz
docker-compose stop
