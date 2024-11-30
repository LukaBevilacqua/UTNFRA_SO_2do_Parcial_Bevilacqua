#!/bin/bash

# Corremos el contenedor background
docker run -d -p 8080:80 --name web1-container web1-bevilacqua
