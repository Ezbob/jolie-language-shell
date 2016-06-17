#!/bin/bash

echo "Building stuff..."

echo "Compiling jolie lang stuff.."
cd ace/tool/
node tmlanguage.js ../../highlight/Jolie.tmLanguage
echo "done."

echo "Packageing ace into ace-builds" 
cd ..
node Makefile.dryice.js full --target ../../ace-builds
echo "done."


echo "done."

