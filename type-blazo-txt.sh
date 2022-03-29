#!/bin/bash

echo "HOME ="
echo $HOME >> >> $HOME/test-script-log.txt
HOME=~
echo $HOME >> >> $HOME/test-script-log.txt
cd ~
echo "id = " >> $HOME/test-script-log.txt
id >> $HOME/test-script-log.txt
echo "whoami" >> $HOME/test-script-log.txt
echo "pwd" >> $HOME/test-script-log.txt
pwd >> $HOME/test-script-log.txt
echo "uname -a" >> $HOME/test-script-log.txt
uname -a >> $HOME/test-script-log.txt
echo "hostname" >> $HOME/test-script-log.txt
hostname >> $HOME/test-script-log.txt
echo " "
echo "Tony Halik: Tu bylem!" >> $HOME/test-script-log.txt
