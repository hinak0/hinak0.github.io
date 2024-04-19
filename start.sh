#!/bin/sh

nginx &

while true; do
	git -C /usr/share/nginx/html pull
	sleep 600
done
