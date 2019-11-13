#!/bin/bash

#############################################################################
# This script logs the ssh connections and authentifications and saves them #
#############################################################################

#Time for saving logfiles
CURTIME=$(date +"%Y%m%d_%H-%M-%S")

#Logfiles source and destination
LOG_SOURCE=/var/log/auth.log
LOGS_DEST=/home/work/logs

#SSH LOG DEST
SSH_DEST=$LOGS_DEST/ssh
#SSH LOGFILE DEST
SSH_LOGFILE=$SSH_DEST/connections_$CURTIME.log

#Scriptlogs
SCRIPT_DEST=$LOGS_DEST/script_logs
SCRIPT_LOGFILE=$SCRIPT_DEST/script_$CURTIME.log

#Authentications logfile (full auth.log)
AUTH_DEST=$LOGS_DEST/auth
AUTH_LOGFILE=$AUTH_DEST/authentications_$CURTIME.log

#Lastlogin logs
LAST_DEST=$LOGS_DEST/last
LAST_LOGFILE=$LAST_DEST/last_$CURTIME.log

#Last lines of log files
TAIL_NR=100


########### EXIT  Codes ###############
#                                     #
#  EXIT=0 --> No errors               #
#  EXIT=1 --> No errors, invalid exec #
#  EXIT=2 --> Critical Error          #
#                                     #
#######################################
EXIT=0


if [ $EUID != 0 ]
then
	echo "This script has to be executed as root or with root permissions (sudo)!"
	EXIT=2
	exit $EXIT
fi

#Uncomment for custom tail lines
if [ $1 ]
then
   TAIL_NR=$1
fi

fnLog()
{
  echo $1 >> $SCRIPT_LOGFILE
}

#Init of logile
echo "This script logs the ss connections and authentifications and saves them to another folder." > $SCRIPT_LOGFILE
fnLog " "
fnLog "#################       EXIT Codes        #############################"
fnLog "#                                                                     #"
fnLog "#    EXIT=0 --> No errors                                             #"
fnLog "#    EXIT=1 --> No errors, but script could not execute completely    #"
fnLog "#    EXIT=2 --> Critical Error                                        #"
fnLog "#######################################################################"
fnLog " "
fnLog "Script started by $USER at $CURTIME"
fnLog " "
fnLog "-----------------------------------------------------------------------"
fnLog " "

#Error checking
fnLog "Checking if source log file [$(echo $LOG_SOURCE)] exists and is not empty ..."
if [ -f $LOG_SOURCE ]
then
	#File exists
	if [ ! -s $LOG_SOURCE ]
	then
		EXIT=1
		fnLog "The ssh log file exists, but is empty!"
		fnLog "Exit code: $EXIT"
		fnLog "Exiting script ... "
		exit $EXIT
	fi
	fnLog "The ssh_log file exists and is not empty!"
else #No ssh log file exists
	EXIT=2
	fnLog "The ssh log file does not exists!"
	fnLog "Exit code: $EXIT"
	fnLog "Exiting script ... "
	exit $EXIT
fi

fnLog "Checking if ssh_logs folder exists ..."

#Creates Log folders
fnCreateFolder()
{

FOLDER=$1

fnLog "Checking if $FOLDER exitst"
if [ ! -d $FOLDER ]
then
	mkdir $FOLDER -p
	chown work:work $FOLDER -R
	fnLog "$FOLDER folder exists now!"
else
 	fnLog "$FOLDER does exist!"
fi
}

fnCreateFolder $LOGS_DEST
fnCreateFolder $SSH_DEST
fnCreateFolder $AUTH_DEST
fnCreateFolder $LAST_DEST

#Copying content of sshlog file to logfiles
AUTH_OUTPUT=$(tail -n $TAIL_NR $SSHLOGS_SOURCE)
CONNECTIONS_OUTPUT=$(SSHLOG_OUTPUT | grep sshd)

tail -n $TAIL_NR -f $SSHLOGS_SOURCE > $AUTHLOGFILE & #Saves all authentications
tail -n $TAIL_NR -f $SSHLOGS_SOURCE | grep sshd > $SSHLOGFILE & #Saves ssh auth
last > $LAST_LOGFILE &

fnLog "All requirements met. Starting to copy ssh logs..."
fnLog "Output of the sshlog file:"
fnLog "$(echo CONNECTIONS_OUTPUT)"

#Script done
fnLog "Script done!"
fnLog "Exit code: $EXIT"
fnLog "Exiting script ... "
exit $EXIT
