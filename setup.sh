#!/bin/sh

docker build -t quest_lambda_app .

docker run -d -p 3000:3000 quest_lambda_app

docker ps --format '{{.Names}}' | grep -w "^quest_lambda_app$" 
