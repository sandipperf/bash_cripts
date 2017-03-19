while getopts d:s o
do	case "$o" in
	d)	seplist="$OPTARG";;
	s)	paste=hpaste;;
	[?])	print >&2 "Usage: $0 [-s] [-d seplist] file ..."
	exit 1;;
esac
	done
shift $OPTIND-1
