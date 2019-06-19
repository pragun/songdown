#!/bin/bash

source ~/.bashrc
echo ""
echo "This is the SongShell"
echo "You can use " -NoNewLine
echo " writesong <input-file> "
echo "to generate PDF files"

SD_PATH=$PWD
alias writesong='perl "${SD_PATH}/writesong"'
cd ..
