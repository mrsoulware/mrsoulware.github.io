#!/bin/sh

if [ "$1" = "h" ]; then
	bundle exec jekyll serve -H 192.168.56.31
else
	bundle exec jekyll serve
fi
