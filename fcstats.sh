#!/bin/bash
#
# Produces a formatted summary of FC statistics from the
# /sys/class/fc_host/ special files.
#

BANNER="-----------  "
HOSTS=()
FILES=""
let hosts=0

show_each_stat_per_host()
{
    file=$1
    n="unknown"
    let j=0

	case "$1" in
                dumped_frames)			n="Dropped     ";;
		error_frames )			n="Frame error ";;
		fcp_control_requests )  	n="FC Ctl Rq   ";;
		fcp_input_megabytes)		n="FC input MB ";;
		fcp_input_requests)		n="FC input Rq ";;
		fcp_output_megabytes)		n="FC output MB";;
		fcp_output_requests)		n="FC output Rq";;
		invalid_crc_count)		n="CRC errors  ";;
		invalid_tx_word_count) 		n="Invalid tx  ";;
		link_failure_count)		n="Link errors ";;
		lip_count )			n="LIP count   ";;
		loss_of_signal_count )		n="Signal loss ";;
		loss_of_sync_count )		n="Sync loss   ";;
		nos_count )			n="NOS count   ";;
		prim_seq_protocol_err_count)	n="Proto error ";;
		reset_statistics)		n="Reset stats ";;
		rx_frames )			n="RX frames   ";;
		rx_words )			n="RX words    ";;
		tx_frames )			n="TX frames   ";;
		tx_words )			n="TX words    ";;
		seconds_since_last_reset)	n="Reset secs  ";;
	esac

        LINE=`echo -n -e "$n:\t" `

	while [ ${HOSTS[j]} ] ; do

            if [ ! "reset_statistics" = "$file" ]; then
		v=`cat /sys/class/fc_host/${HOSTS[j]}/statistics/$file `
	    else
		v="0"
            fi
            let j=j+1
	    R=`printf "%-10d" $v `
	    LINE=`echo -n -e "$LINE $R "`
        done
	echo "$LINE"
}

long_list()
{

	let i=0
	for d in  `find  /sys/class/fc_host/ -name "host*" ` ; do
		HOSTS[hosts]=`basename $d`
		let hosts=hosts+1
	done

	while [ $i != $hosts ] ; do
		echo "$BANNER ${HOSTS[i]}"

		for f in `find /sys/class/fc_host/${HOSTS[$i]}/statistics/* -type f | sort` ; do
			F=`basename $f | sed -s 's/ //g'`
                    if [ ! "reset_statistics" = "$F" ]; then
                        v=`cat /sys/class/fc_host/${HOSTS[$i]}/statistics/$F `
		    else
		        v="0"
		    fi
		    R=`printf "%s: %-10d" $F $v `
		    echo "$R"
                done
		let i=$i+1
	done
}

short_list()
{

	let i=0

	for d in  `find  /sys/class/fc_host/ -name "host*" ` ; do
		HOSTS[hosts]=`basename $d`
		let hosts=hosts+1
	done
	L=""
	while [ $i != $hosts ] ; do
		L=`echo "$L${HOSTS[$i]}     "`
		let i=i+1
	done
	echo "$BANNER $L"

	for f in `find /sys/class/fc_host/${HOSTS[0]}/statistics/* -type f | sort | uniq` ; do
		F=`basename $f | sed -s 's/ //g'`
		show_each_stat_per_host $F
	done
}

usage()
{
	echo "$0: display FC stats. [-l long]"
	exit
}
#  main

	if [ ! -d   /sys/class/fc_host/ ] ; then
		echo "No FC hosts found: /sys/class/fc_host/"
		exit 1
	fi

        while getopts "lh" OPTION
        do
                case "${OPTION}" in
                l) long_list ; exit 0;;
                ?) usage ;;
                h) usage ;;
                esac
        done

	short_list
        exit 0
