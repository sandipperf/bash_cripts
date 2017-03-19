#!/bin/bash
#Run DD test to measure pefromance of read/write on disk
#
runTest()
{
  for((i=1; i<=$threads; i++))
  do

     inFile=${inputDir}/file_$i
     outFile=${outputDir}/file_$i
     echo "Input/Output files are ${inFile} ${outFile}"
     dd if=${inFile} of=${outFile} bs=$blockSize count=$count > ${logDir}/testio_$i 2>&1 &
#use oflag=direct (to avoid the buffer cache to test disk performance)     
     pid=$!
     echo $pid >> $logDir/pid_list
  done

  c=2
  while [ $c -gt 1 ];
  do
     c=`ps -ef | grep "bs=${blockSize}" | wc -l`
     sleep 2
  done
}

threads=16
blockSize=8192
#filesize in GB
fileSize=2
diskVol=nas46_400
dateTag=$(date +%Y%m%d-%H%M%S)
fscache="false"

echo "HELP: ./ddTest.sh -t|--threads, -bs|--blocksize (bytes), -fs|--filesize (gb), -vol|--volume -dt|--dateTag -fscache"
echo "Example/Defaults: ./ddTest.sh -t 16 -bs 8192 -fs 2 -vol nas46_400 -dt $dateTag -fscache true"

while [[ $# > 1 ]]
do
key="$1"

case $key in

    -t|--threads)
    threads="$2"
    shift # past argument
    ;;
    -bs|--blocksize)
    blockSize="$2"
    shift # past argument
    ;;
    -fs|--filesize)
    fileSize="$2"
    shift # past argument
    ;;
    -vol|--volume)
    diskVol="$2"
    shift # past argument
    ;;
    -dt|--dateTag)
    dateTag="$2"
    shift # past argument
    ;;
    -fscache|--fscache)
    fscache="$2"
    shift # past argument
    ;;

    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

workVol=/$diskVol/work



scriptDir=$HOME/scripts

masterLogDir=$scriptDir/logs/$dateTag

srcInput=$workVol/src-input
workDir=$workVol/$dateTag
logDir=${workDir}/logs
inputDir=${workDir}/input
outputDir=${workDir}/output

mkdir -p $srcInput $workDir $logDir $inputDir $outputDir $masterLogDir

echo $workDir $logDir $inputDir $outputDir

ln -s $logDir $masterLogDir/${diskVol}_link

paramFile=$logDir/testParams.txt

echo "Test Parameters are ..." >> $paramFile
echo "File size = $fileSize <gb>" >> $paramFile
echo "Block Size = $blockSize <bytes>" >> $paramFile
echo "Threads = $threads <count>" >> $paramFile
echo "Work Volume = $workVol <i/o directory>" >> $paramFile

more $logDir/testParams.txt

#read -n1 -r -p "Press space to continue..." key

count=$(( $fileSize * 1024 * 1024 * 1024 / $blockSize ))

echo `date`
echo "Checking input file..."
inputFile=$srcInput/file_${fileSize}gb
#creating input files if not available from /dev/zero
if [ -f $inputFile ]
then
   echo "$inputFile is available"
else
   echo "$inputFile is not available, creating it"
   dd if=/dev/zero of=${inputFile} bs=$blockSize count=$count > ${logDir}/filegen
fi

echo `date`
#copying n times (thread count) the input file to input log directory
echo "Setting up input files..."

for((i=1; i<=$threads; i++))
do

   file=${inputDir}/file_$i
   echo "Copying file ${file}"
   cp $inputFile $file
done
echo "Logs available in dir - [$logDir]"

echo "Setup Complete.."

echo "Waiting for sync..."
sync

sleep 120

echo "Starting test..."

#read -n1 -r -p "Press space to continue..." key

echo `date`

iostat -xtcm 2 > ${logDir}/iostat.txt &
pid_iostat=$!

START=$(date +%s)

runTest

#if readCache is needed, enable the below line:
if [ "$fscache" = "true" ]; then
   runTest
fi

echo `date`

echo "Test Completed"

END=$(date +%s)
# ps -ef | grep -i `cat $$logDir/pid_list | tr "\n" " "`

kill -9 $pid_iostat

echo "iostat pid is [$pid_iostat]"


$scriptDir/parse.sh $logDir

DIFF=$(( $END - $START ))

dataSize=$(( $fileSize * 1024 * $threads * 2 ))

echo "Total Test duration is $DIFF seconds" >> ${logDir}/testSummary.txt
echo "Data volume read/written $dataSize MB" >> ${logDir}/testSummary.txt

TPS=$(( $dataSize / $DIFF ))

echo "TPS = $TPS" 
echo "TPS = $TPS" >> ${logDir}/testSummary.txt

cat $logDir/parse.txt >> ${logDir}/testSummary.txt

echo "$diskVol" >> $masterLogDir/Summary.txt
echo "#####################################################################" >> $masterLogDir/Summary.txt 
cat ${logDir}/testParams.txt >> $masterLogDir/Summary.txt
cat ${logDir}/testSummary.txt >> $masterLogDir/Summary.txt
echo "#####################################################################" >> $masterLogDir/Summary.txt
#cleanup

echo "Cleaning up test files ..."
rm ${inputDir}/file_* ${outputDir}/file_*

echo "Done!"
