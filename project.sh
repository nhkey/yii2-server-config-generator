#!/bin/bash

while [[ ($type -ne 1) && ($type -ne 2) ]]
do
    echo "Change type of config";
    echo "1: Yii2 Advanced (nginx)";
    echo "2: Yii2 Basic (nginx)";
    read type;
done


# START GENERATE CONFIG FILE

case $type in
1)
   bash $PWD"/projects/yii2_advanced_nginx.sh";
   exit 0;
;;
2)
   bash $PWD"/projects/yii2_basic_nginx.sh";
   exit 0;
;;
esac

exit 0;