#!/bin/sh

if [ -n "$1" ]; then
	lex new-standard-pascal.l && yacc new-standard-pascal.y && gcc y.tab.c -o $1;
	echo "Success!";
else
	echo "Usage : ./make.sh [output file name]";
fi
