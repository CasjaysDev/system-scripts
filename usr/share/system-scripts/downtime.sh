#!/usr/bin/env bash
PROG=downtime
PROGPID=$(echo $$)
source /etc/sysconfig/system-scripts.sh
#

if [ ! -d "$BASEDIR/$PROG" ]; then mkdir -p "$BASEDIR/$PROG"; fi

if [ -f "$PIDFILE" ]; then
  echo -e "$PROG is Already Runnning on $HOSTNAME with $PROGPID" | mail -r "$MAILRECIP" -s "$MAILSUB" "$MAILFROM"
  echo "exit 2" >"$LOGFILE" 2>"$ERRORLOG"
  exit 2
fi

echo "$PROGPID" >"$PIDFILE"

echo -e "$PROG started on $STARTDATE at $STARTTIME" >"$LOGFILE" 2>"$ERRORLOG"

echo "This system was last started on $DOWNDATE at $DOWNTIME" >"$BASEDIR/$PROG/downtime"
echo "This system was last started on $DOWNDATE at $DOWNTIME" >>"$LOGFILE" 2>>"$ERRORLOG"

ENDDATE=$(date +"%m-%d-%Y")
ENDTIME=$(date +"%r")
if [ ! -s "$ERRORLOG" ]; then
  if [ "$SENDMAIL" = "yes" ] && [ "$EMAILdowntime" = "yes" ]; then
    echo -e "
$MAILHEADER\n
$PROG started on $STARTDATE at $STARTTIME\n
$MAILMESS1
$MAILMESS2
$MAILMESS3
$PROG completed on $ENDDATE at $ENDTIME\n
$MAILFOOTER\n" | mail -r "$MAILFROM" -s "$MAILSUB" "$MAILRECIP"
  fi

else
  if [ -s "$ERRORLOG" ] && [ -f "$ERRORLOG" ] && [ "$SENDMAILONERROR" == "yes" ]; then
    MAILMESS3="$(echo -e "Errors were reported and they are as follows:\n""$(cat $ERRORLOG)")"
    echo -e "
$MAILHEADER\n
$PROG started on $STARTDATE at $STARTTIME\n
$MAILMESS1
$MAILMESS2
$MAILMESS3
$PROG completed on $ENDDATE at $ENDTIME\n
$MAILFOOTER\n" | mail -r "$MAILFROM" -s "$MAILSUB" "$MAILRECIP"
  fi

  rm -f "$PIDFILE"
fi

if [ -s "$ERRORLOG" ]; then
  echo "Any errors from the error log are reported below" >>"$LOGFILE"
  cat "$ERRORLOG" >>"$LOGFILE"
  echo "End of error log file" >>"$LOGFILE"
fi
ENDDATE=$(date +"%m-%d-%Y")
ENDTIME=$(date +"%r")
echo -e "$PROG completed on $ENDDATE at $ENDTIME" >>"$LOGFILE" 2>>"$ERRORLOG"
echo -e "Total log Size is $(ls -lh $LOGFILE | awk '{print $5}')" >>"$LOGFILE" 2>>"$ERRORLOG"

rm -f "$ERRORLOG"
rm -f "$PIDFILE"
echo "exit = $?" >>"$LOGFILE"
exit $?

