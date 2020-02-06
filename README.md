# ctcserve
Webserver docker configuration for CTC

## Installation and Setup

## Usage

To start the server, from the top-level directory of `ctcserve` (the one containing the `docker-compose.yaml` file), run:
    
    docker-compose up -d
    
To stop the server, run

    docker-compose down
    
To view logs:

    docker logs -f --details ctcserve_webserver_1
    
Get a shell terminal on the webserver:

    docker-compose exec webserver /bin/bash
