
wait()
{
  logDir=$1
  c=0;
  while [ $c -lt 2 ];
  do
    c=`grep "Done!" $logDir/test_*.log | wc -l` 
    sleep 2
    echo -n "."
  done
}




#Test#1

fs=5 #file size gb
threads=8 #threads

for bs in 8
do
  
   bs=$(( $bs * 1024 ))  #block size bytes

   dateTag=$(date +%Y%m%d-%H%M%S)
   logDir=logs/$dateTag
   mkdir -p $logDir

   rm logs/latest
   ln -s $dateTag logs/latest

   echo "LogDir - $logDir"

   ./ddTest.sh -t $threads -bs $bs -fs $fs -vol nas46_400 -dt $dateTag > $logDir/test_1.log 2>&1 &
   ./ddTest.sh -t $threads -bs $bs -fs $fs -vol nas45_400 -dt $dateTag > $logDir/test_2.log 2>&1 &

   echo "Test Started.. waiting for it to complete.."

   wait $logDir

   echo "Test Completed!"

done
