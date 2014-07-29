#!/bin/bash
#
# clamav-cron v. 0.6 - Copyright 2009, Stefano Stagnaro
# clamav-cron.sh v. 0.7 - Modified by Mark Parraway
# This is Free Software released under the GNU GPL license version 3

#============================================#
#        User configuration section          #
#============================================#

# Log file name and its path:
#CV_LOGFILE="$HOME/clamav-cron.log"
CV_LOGFILE="/var/log/clamav/clamav-cron.log"

# Notification e-mail sender:
CV_MAILFROM="clamav@yourserver.net"

# Notification e-mail recipient:
CV_MAILTO="user@yourdomain.com"

# Notification e-mail secondary recipients:
CV_MAILTO_CC="user2@yourdomain.com; user3@otherdomain.org"

# Notification e-mail subject:
CV_SUBJECT="Your Organization - ClamAV scan report"

#============================================#

CV_TARGET="$1"
CV_VERSION_ORIG="0.6"
CV_VERSION_FORK="0.7"

if [ -e $CV_LOGFILE ]
then
        /bin/rm $CV_LOGFILE
fi

if [ -z "$1" ]
then
        CV_TARGET="$HOME"
fi

#To be read on stdout (and root mail):
echo -e `basename $0` v. $CV_VERSION_ORIG - Copyright 2009, Stefano Stagnaro '\n'
echo -e `basename $0` v. $CV_VERSION_FORK - Modified by Mark Parraway '\n'

#To be read on logfile (sent via sendmail):
echo -e $CV_SUBJECT - $(date) '\n' >> $CV_LOGFILE
echo -e Script: `basename $0` v. $CV_VERSION_ORIG - Copyright 2009, Stefano Stagnaro  >> $CV_LOGFILE
echo -e Script: `basename $0` v. $CV_VERSION_FORK - Modified by Mark Parraway  >> $CV_LOGFILE
echo -e Scanned: $CV_TARGET on $HOSTNAME'\n' >> $CV_LOGFILE

/usr/bin/freshclam --log=$CV_LOGFILE --user $USER --verbose

#To be read on stdout (and root mail):
echo -e '------------------------------------\n'

/usr/bin/clamscan --infected --log=$CV_LOGFILE --recursive $CV_TARGET --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/media --exclude=/mnt
CLAMSCAN=$?

if [ "$CLAMSCAN" -eq "1" ]
then
        CV_SUBJECT="[VIRUS!] "$CV_SUBJECT
elif [ "$CLAMSCAN" -gt "1" ]
then
        CV_SUBJECT="[ERR] "$CV_SUBJECT
fi

/bin/mail -s "$CV_SUBJECT" -c $CV_MAILTO_CC $CV_MAILTO -- -f $CV_MAILFROM < $CV_LOGFILE