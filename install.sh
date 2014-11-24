#!/bin/sh

SCRIPT=`pwd`/hackon.sh
SOURCE="\n# Support for hackon\nsource $SCRIPT"

if [ ! -e $SCRIPT ];
then
    echo "You must run this from the location of hackon.sh"
    exit -1
fi

if [[ -e ~/.bashrc ]];
then
    echo "Added to bashrc: $SOURCE"
    echo $SOURCE >> ~/.bashrc
fi

if [[ -e ~/.zshrc ]];
then
    echo "Added to zshrc: $SOURCE"
    echo $SOURCE >> ~/.zshrc;
fi
