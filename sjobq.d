#!/bin/bash
############################################################################
#    Copyright (C) 2010-2015 by Nestor Aguirre                             #
#    nfaguirrec@gmail.com                                                  #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

DATA_DIR="/var/tmp/$USER/sjobq.data"
COUNTER_FILE="$DATA_DIR/counter"
STOP_FILE="$DATA_DIR/stop"
REFRESH_INTERVAL="2"
CURRENT_JOB_HOME="$DATA_DIR/current"

##
# @brief
##
diffTime()
{
	local time0=`echo $1 | sed 's/@/ /g'`
	local time1=`echo $2 | sed 's/@/ /g'`
	
	local DAYS=""
	local HOURS=""
	local MINUTES=""
	local SECONDS=""
	
	# %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.
	
	DAYS=$(( $(printf '%s' $(( $(date -u -d"$time0" +%s) - $(date -u -d"$time1" +%s)))) / 60 / 60 / 24 ))
	time1=$(date -d"$time1 +$DAYS days" '+%F %T.%N %Z')
	HOURS=$(( $(printf '%s' $(( $(date -u -d"$time0" +%s) - $(date -u -d"$time1" +%s)))) / 60 / 60 ))
	time1=$(date -d"$time1 +$HOURS hours" '+%F %T.%N %Z')
	MINUTES=$(( $(printf '%s' $(( $(date -u -d"$time0" +%s) - $(date -u -d"$time1" +%s)))) / 60 ))
	time1=$(date -d"$time1 +$MINUTES minutes" '+%F %T.%N %Z')
	SECONDS=$(printf '%s' $(( $(date -u -d"$time0" +%s) - $(date -u -d"$time1" +%s))))

	printf "%02d-%02d:%02d:%02d\n" "$DAYS" "$HOURS" "$MINUTES" "$SECONDS"
}

##
# @brief
##
function update()
{
	local lastID="`cat $CURRENT_JOB_HOME/pid 2> /dev/null`"
	local currentPID=""
	
	if [ -z "`ps -A | awk -v id=$lastID '($1==id){print "1"}'`" ]
	then
		pushd . &> /dev/null
		cd $DATA_DIR
		IDL="`ls *.bid  2> /dev/null | sed '{s/[.].*//g}' | sort -n | head -n1`"
		popd &> /dev/null
		
		# Saves the command to the history file
		# exactly after that this has finished
		if [ "`cat $CURRENT_JOB_HOME/alive`" -eq "1" ]
		then
			beginTime=`date -u '+%F %T.%N %Z' | sed 's/ /@/g'`
			endTime=$(cat $CURRENT_JOB_HOME/beginTime)
			
			echo "command      = `cat $CURRENT_JOB_HOME/com`" >> $DATA_DIR/history
			echo "dir          = `cat $CURRENT_JOB_HOME/pwd`" >> $DATA_DIR/history
			echo "time spent   = `diffTime $beginTime $endTime`" >> $DATA_DIR/history
			echo "" >> $DATA_DIR/history
		fi
		
		# Flag that indicate the end of the job
		echo "0" > $CURRENT_JOB_HOME/alive
		
		# If the previous job has finished, it will run the next command in the queue
		if [ -n "$IDL" ]
		then
			# Register the begin time
			echo $(date -u '+%F %T.%N %Z' | sed 's/ /@/g') > $CURRENT_JOB_HOME/beginTime
			
			# this will go to the appropriate directory
			# where the command should be to executed
			pushd . &> /dev/null
			cd `cat $DATA_DIR/$IDL.pwd`
			
			# this builds a litle script that run the command using nohup
			# and updates the files necesary files for register it
			echo "#!/bin/bash" > .tmp2156456
			cat $DATA_DIR/$IDL.com | sed '{s/^/nohup /g;s/$/ \&/g}' >> .tmp2156456
			echo "echo \$! > $CURRENT_JOB_HOME/pid" >> .tmp2156456
			
			chmod +x .tmp2156456
			./.tmp2156456
			rm .tmp2156456
			
			rm -f $DATA_DIR/$IDL.bid
			mv $DATA_DIR/$IDL.com $CURRENT_JOB_HOME/com
			mv $DATA_DIR/$IDL.pwd $CURRENT_JOB_HOME/pwd
			
			# this will return to the original directory
			popd &> /dev/null
			
			sleep 2
			
			currentPID="`cat $CURRENT_JOB_HOME/pid`"
			pstree -p $currentPID > $CURRENT_JOB_HOME/tree
			pstree -p $currentPID | awk 'BEGIN{RS="[()]"}($0~/^[[:digit:]]+$/){printf $0" "}' | sed 's/$/\n/' > $CURRENT_JOB_HOME/pids
			
			# Flag that indicate the begin of the job
			echo "1" > $CURRENT_JOB_HOME/alive
		fi
	fi
	
	if [ -d "$CURRENT_JOB_HOME" ]
	then
		echo -n "Saving data for process $CURRENT_JOB_HOME ... "
	else
		echo -n "Making data directory for process in $CURRENT_JOB_HOME ... "
		mkdir $CURRENT_JOB_HOME && echo "OK"
	fi
}

##
# @brief
##
function start()
{
	while [ 1 ]
	do
		if [ -f $STOP_FILE ]
		then
			rm $STOP_FILE
			exit
		fi
			
		sleep $REFRESH_INTERVAL
		update  > /dev/null
	done
}

##
# @brief
##
function stop()
{
	echo "" > $STOP_FILE
	sleep 3
	rm -rf $DATA_DIR
}

##
# @brief
##
function pause()
{
	pushd . &> /dev/null
	cd $DATA_DIR
	ID_LIST=`ls *.bid 2> /dev/null | sed '{s/[.].*//g}'`
	popd &> /dev/null
	
	PID_LIST=`cat $CURRENT_JOB_HOME/pids`
	PID_FIRST=`echo $PID_LIST | awk '{print $1}'`
	
	if [ -n "`ps -A | awk '{print $1}' | grep "$PID_FIRST"`" ]
	then
		kill -STOP $PID_LIST
	fi
		
	echo "Job with id=current has been paused !!"
}

##
# @brief
##
function cont()
{
	pushd . &> /dev/null
	cd $DATA_DIR
	ID_LIST=`ls *.bid 2> /dev/null | sed '{s/[.].*//g}'`
	popd &> /dev/null
	
	PID_LIST=`cat $CURRENT_JOB_HOME/pids`
	PID_FIRST=`echo $PID_LIST | awk '{print $1}'`
	
	if [ -n "`ps -A | awk '{print $1}' | grep "$PID_FIRST"`" ]
	then
		kill -CONT $PID_LIST
	fi
		
	echo "Job with id=current has been continued !!"
}

##
# @brief
##
function main()
{
	case $1 in
		start)
			#------------------------------------
			# Thanks to john0312 (Dec 1, 2014)
			#------------------------------------
			isRunning="`ps -u $USER | grep "sjobq.d$" | awk '{a[NR]=$1}END{ if(a[2]==(a[1]+1)) print 0; else print 1}'`"
			if [ $isRunning -eq "1" ]
			then
				# It's already running.
				echo "### Error ### The daemon sjobq.d is already running"
				echo "              stop it using \"sjobq.d stop\""
				exit 1
			fi
			#------------------------------------
				
			if [ ! -d "$DATA_DIR" ]
			then
				mkdir -p $DATA_DIR
			fi
			
			nohup $0 __start > $DATA_DIR/log 2> $DATA_DIR/err &
			
			echo "=============================="
			echo " SJobQ daemon has been started"
			echo "=============================="
			;;
		stop)
			isRunning="`ps -u $USER | grep "sjobq.d$" | awk '{a[NR]=$1}END{ if(a[2]==(a[1]+1)) print 0; else print 1}'`"
			if [ $isRunning -eq "0" ]
			then
				echo "### Error ### The daemon sjobq.d is not running"
				echo "              run it using \"sjobq.d start\""
				exit 1
			else
				echo "=============================="
				echo " SJobQ daemon has been stopped"
				echo "=============================="
				stop
			fi
			
			;;
		pause)
			pause
			;;
		cont)
			cont
			;;
		restart)
			stop
			
			if [ ! -d "$DATA_DIR" ]
			then
				mkdir -p $DATA_DIR
			fi
			
			nohup $0 __start > $DATA_DIR/log 2> $DATA_DIR/err &
			
			echo "================================"
			echo " SJobQ daemon has been restarted"
			echo "================================"
			;;
		__start)
			start
			;;
		*)
			echo "Usage: sjobq.d {start|stop|restart}"
			;;
	esac
}

main $*
