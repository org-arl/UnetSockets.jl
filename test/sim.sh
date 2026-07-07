#!/bin/bash
# usage: sim.sh start <unet-home>
#        sim.sh stop

DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$DIR/unet.pid"

if [ "$1" == "start" ]; then
  UNET_HOME="$2"
  if [ ! -x "$UNET_HOME/bin/unet" ]; then
    echo "unet launcher not found at $UNET_HOME/bin/unet"
    exit 1
  fi
  cd "$DIR" || exit 1
  mkdir -p logs
  "$UNET_HOME/bin/unet" "$DIR/2-node-network.groovy" > logs/stdout.txt 2>&1 &
  echo $! > "$PIDFILE"
  echo "Started unet with PID $(cat "$PIDFILE")"
fi

if [ "$1" == "stop" ]; then
  if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
  fi
fi
