#!/bin/sh
#set -x
#
# init script for a Java application
#

# Check the application status
#
# This function checks if the application is running
FILE=$1
CMD=$2
LOGFILE="`basename $1 ".jar"`.log"
#echo $FILE, $CMD, $LOGFILE
check_status() {

  # Running ps with some arguments to check if the PID exists
  # -C : specifies the command name
  # -o : determines how columns must be displayed
  # h : hides the data header
  cmd="pgrep -f 'java -jar $FILE'"
  s=`eval $cmd`
  # If something was returned by the ps command, this function returns the PID
  if [ $s ] ; then
    echo Java PID is $s
    ps -uep $s -uef --ppid $s
    return $s
  fi

  # In any another case, return 0
  return 0

}

# Starts the application
start() {

  # At first checks if the application is already started calling the check_status
  # function
  check_status

  # $? is a special variable that hold the "exit status of the most recently executed
  # foreground pipeline"
  pid=$?

  if [ $pid -ne 0 ] ; then
    echo "The application is already started"
    exit 1
  fi

  # If the application isn't running, starts it
  echo -n "Starting application: "

  # Redirects default and error output to a log file
  java -jar $FILE >> logs/$LOGFILE 2>&1 &

  check_status
  echo "OK"
}

# Stops the application
stop() {

  # Like as the start function, checks the application status
  check_status

  pid=$?

  if [ $pid -eq 0 ] ; then
    echo "Application is already stopped"
    exit 1
  fi

  # Kills the application process
  echo -n "Stopping application: "
  pkill -9 -P $pid

  while [ $pid -gt 0 ]
  do
    check_status
    pid=$?
    sleep 1
  done

  echo "OK"
}

# Show the application status
status() {

  # The check_status function, again...
  check_status

  # If the PID was returned means the application is running
  if [ $? -ne 0 ] ; then
    echo "Application is started"
  else
    echo "Application is stopped"
  fi

}

# Main logic, a simple case to call functions
#echo Value is $0, $1, $2
case "$2" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart|reload)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|reload|status}"
    exit 1
esac

exit 0
