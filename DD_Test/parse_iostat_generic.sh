
logDir=$1

if [ -z $logDir ];
then
        echo "Log directory [$logDir] is not available ..."
	        exit
else
        echo "Log directory [$logDir] is available..."
fi
#logDir=/nas45/work/20160527-02:35:31/logs

		echo "Parsing iostat results ..."

		disk=`cat ${logDir}/iostat.txt |  grep xvd | awk '{print $1}' | sort | uniq | tr "\n" " "`
		echo "Disks are [$disk] .."

		diskArray=($disk)

	for disk in ${diskArray[@]}
	do
		#echo $disk
		file=${logDir}/disk-stat-avg_$disk.txt
		#echo ${logDir}/iostat.txt

		  out=` grep $disk ${logDir}/iostat.txt  | awk '{print $4 " " $5 " "  $6 " " $7}' | tail -n +4 | head -n -3 | awk 'NR>=1{for (i=1;i<=NF;i++){a[i]+=$i}}END{for (i=1;i<=NF;i++){printf a[i]/(NR)" "};printf "\n"}'`
		  echo "r/s     w/s    rMB/s    wMB/s" > ${file}
		  echo $out >> ${file}
	  done

		  echo "Summarizing results .."

		  out=`cat ${logDir}/disk-stat* | grep -v "r/s" | awk 'NR>=1{for (i=1;i<=NF;i++){a[i]+=$i}}END{for (i=1;i<=NF;i=i+2){printf a[i] + a [i+1] " "};printf "\n"}'`
		  file=${logDir}/parse.txt
		  echo "IOPS   MB/s" > ${file}
		  echo $out >> ${file}
  more $file

