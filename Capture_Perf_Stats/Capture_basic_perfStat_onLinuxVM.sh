#!/bin/bash
mkdir /tmp/$1
top -b -d 1 >>/tmp/$1/topOut.log &
toppid=$!
 
sar -n DEV 1 >>/tmp/$1/sar.log &
sarPid=$!
iostat -x 1 >> /tmp/$1/iostat.log &
iostatPid=$!
vmstat 1 >> /tmp/$1/vmstat.log &
vmstatpid=$!
mpstat 1 >>/tmp/$1/mpstat.log &
mpstatpid=$!
xentop -b -d 1 >>/tmp/$1/xentop.log &
xentoppid=$!
xentop -n -x -f -b -d 1 >>/tmp/$1/xentop_detailed.log &
xentop2pid=$!
 
echo "$toppid $sarPid $iostatPid  $vmstatpid $mpstatpid $xentoppid $xentop2pid;"
echo "press space to stop this script"
read -n1 -r -p "Press space to continue..." key
 
 if [ "$key" = ' ' ]; then
        kill -9 $toppid $sarPid $iostatPid  $vmstatpid $mpstatpid $xentoppid $xentop2pid;
 else
         kill -9 $toppid $sarPid $iostatPid  $vmstatpid $mpstatpid $xentoppid $xentop2pid;
 fi
 echo "below process are still running"
 echo "$toppid $sarPid $iostatPid  $vmstatpid $mpstatpid $xentoppid $xentop2pid;"
