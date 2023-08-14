DIR=`find . -name bin -print`

if [ "$1" == "start" ]; then
  $DIR/unet $DIR/../../../2-node-network.groovy &
  sleep 1
  PID=`ps -o pid,command | grep unet | grep -v grep | cut -d' ' -f1`
  echo "Started unet with PID $PID"
fi

if [ "$1" == "stop" ]; then
  PID=`ps -o pid,command | grep unet | grep -v grep | cut -d' ' -f1`
  kill $PID
fi
