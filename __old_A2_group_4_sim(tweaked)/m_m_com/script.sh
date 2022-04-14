#!/usr/bin/env bash
bison -d -y parser_4.y
echo 'step 1: bison -d -y parser_4.y ..... completed'
g++ -w -c -o y.o y.tab.c
echo 'step 2: g++ -w -c -o y.o y.tab.c ...... completed'
flex scanner_4.l
echo 'step 3: flex scanner_4.l ....... completed'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'step 4: g++ -w -c -o l.o lex.yy.c ....... completed'
g++ -o a.out y.o l.o -lfl -ly
echo 'step 5: g++ -o a.out y.o l.o -lfl -ly ....... completed'
./a.out MIPScode.in
echo 'step 6: ./a.out MIPScode.in ........ completed'
