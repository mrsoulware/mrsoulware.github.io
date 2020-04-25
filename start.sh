#!/bin/sh

if [ "$1" = "l" ]; then
	bundle exec jekyll serve
else
	bundle exec jekyll serve -H 192.168.56.31
fi
