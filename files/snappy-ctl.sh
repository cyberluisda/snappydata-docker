#!/bin/sh
set -e

# Common configuration

use() {
    echo "snappy-ctl [--no-starts-aio|--no-starts-leader] "
    echo "    [ "
    echo "      snappy-shell | "
    echo "      bash | "
    echo "      inspect-logs |"
    echo "      spark-shell [option_1 .. option_n]"
    echo "    ]"
    echo ""
    echo "  --no-starts-aio : prevent starts snappy services"
    echo "  snappy-shell : runs snappy shell"
    echo "  spark-shell : runs spark shell with options"
    echo "  bash : runs bash shell script"
    echo "  inspect-logs : run 'tail -f' over snappy log files. Has sense only"
    echo "    if startis-aio is active"
}

starts_aio() {
  # Ensuer sshd server is up
  /etc/init.d/ssh start

  snappy-start-all.sh $1 -client-bind-address=0.0.0.0
}

snappy_shell() {
  snappy-shell
}

run_bash(){
  /bin/bash
}

inspect_logs(){
  tail -f /usr/lib/snappydata/work/*/snappyleader.log \
  /usr/lib/snappydata/work/*/snappyserver.log \
  /usr/lib/snappydata/work/*/snappylocator.log
}

spark_shell(){
  spark-shell $@
}

# Parse commands
AIO=""
COMMAND=""
while test "$1" != ""
do
  case $1 in
    --no-starts-aio)
      AIO="false"
      ;;
    --no-starts-leader)
      AIO="rowstore"
      ;;
    snappy-shell)
      COMMAND="snappy_shell"
      ;;
    bash)
      COMMAND="run_bash"
      ;;
    inspect-logs)
      COMMAND="inspect_logs"
      ;;
    spark-shell)
      COMMAND="spark_shell"
      shift
      break
      ;;
    *)
      use
      exit 1
      ;;
  esac
  shift
done

# Select command
if [ "$AIO" != "false" ]
then
  starts_aio $AIO
fi

$COMMAND $@
