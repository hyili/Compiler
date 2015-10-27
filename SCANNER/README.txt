Readme.txt for a sample parser, 20100430


This directory contains a tiny, but complete parser (together with
a scanner). The file lextest.l is a scanner specification for lex.
The file yacctest.y is a parser specification for yacc. The file
abc.def is a sample correct input. The file abc.def2 is a sample
incorrect input.  To build the parser, use the following three
commands:

    lex lextest.l
    yacc yacctest.l
    cc y.tab.c -ly -ll

to run this program, use (on Unix systems)

    a.out abc.def
    a.out abc.def2

--
