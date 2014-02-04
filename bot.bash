#!/bin/bash

mkfifo .botfile
chan=$1
if [ $2 != '' ] && [ -f $2 ] ; then
  key=`cat $2`
fi

tail -f .botfile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true; do
  if [[ -z $started ]] ; then
    echo "USER calcportal-- calcportal-- calcportal-- :calcportal--" >> .botfile
    echo "NICK calcportal" >> .botfile
    echo "JOIN #$chan $key" >> .botfile
    started="yes"
  fi
  read irc
  echo $irc
  if `echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null` ; then
    echo "PONG" >> .botfile
    elif `echo $irc | grep PRIVMSG | grep "calcportal---" > /dev/null` ; then
   nick="${irc%%!*}"; nick="${nick#:}"
   if [[ $nick != 'calcportal' ]] ; then
      chan=`echo $irc | cut -d ' ' -f 3`
      for i in {1..10}; do
       echo "PRIVMSG $chan :calcportal--" >> .botfile
      done
   fi
  elif `echo $irc | grep PRIVMSG | grep calcportal > /dev/null` ; then
    nick="${irc%%!*}"; nick="${nick#:}"
    if [[ $nick != 'calcportal' ]] ; then
      chan=`echo $irc | cut -d ' ' -f 3`
      echo "PRIVMSG $chan :calcportal--" >> .botfile
    fi
  fi
done
