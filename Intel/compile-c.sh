#!/usr/bin/env bash 
nasm -f elf64 -F dwarf $1.asm -o $1.o -l $1.lst
#yasm -f elf64  $1.asm -o $1.o -l $1.lst
gcc  -no-pie $2.c $1.o -o $2
