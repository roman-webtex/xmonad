#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

feh --no-xinerama --bg-center /home/roman/wall/269413-4096x1743.jpg

