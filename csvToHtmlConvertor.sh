#!/bin/bash
inputFileName=$1
orgName=$2
configName=$3

echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
echo "<html>"
echo "<body style=\"margin: 10px; padding: 10px 50px 0px; font-family:Arial, Helvetica, sans-serif;\">"
echo "<h3 style=\"text-align:left\"><a id=\"top\"> Your environment details : ${orgName}</a></h3>"
echo "</p>"
echo "<hr"

function createHTML() {
    isheader="true";
 fileName=$1
echo "<table border=2>" ;
    while read INPUT ; do
	if [[ "$isheader" == "true" ]];then
        isheader=false;
      	echo "<tr><th align=center bgcolor=#5499C7>${INPUT//,/</th><th bgcolor=#5499C7>}</th></tr>" ;
      	continue;
    	fi
	val=`echo $INPUT|awk '{print $NF}'`
	if [[ "${val}" == "false" ]] || [[ "${val}" == "False" ]]; then
	echo "<tr><td >${INPUT//,/</td><td align=center bgcolor=#ff6666>}</td></tr>" ;
	else
	echo "<tr><td>${INPUT//,/</td><td align=center >}</td></tr>" ;
	fi

    done < $1;
 echo "</table>"
 echo "<br></br>"
}
echo "<br></br>"
echo "<h4 style=\"text-align:left\"><a id=\"top\"> <u>${configName}</u></a></h3>"
createHTML $inputFileName
echo "</body> </HTML>"
