#!/bin/bash

HP_Information() {
hostname=`hostname`
echo "
#####################################################################
Health Check Report (CPU,Process,Disk Usage, Memory)
#####################################################################
Hostname : `hostname`
Kernel Version : `uname -r`
Uptime : `uptime | sed 's/.*up \([^,]*\), .*/\1/'`
Last Reboot Time : `who -b | awk '{print $4,$5}'`
Core Number : `/opt/ignite/bin/print_manifest|grep -w "Processors"|awk '{print $2}'`
CPU Type : `/usr/contrib/bin/machinfo -v|grep -w "Intel"|cut -d ':' -f 2,2|head -1`
Product : `model`
IP : `cat /etc/hosts|grep $hostname|grep -v '#'|grep -v "_hb"|grep -v "127.0.0.1"`
Virtual/Physical : `model`
Load Average : `uptime | awk -F'load average:' '{ print $2 }' |cut -d ',' -f 1,1|awk '{print $1}'`
Heath Status : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d, | awk '{if ($1 > 2) print "Unhealthy"; else if ($1 > 1) print "Caution"; else print "Normal"}`
#####################################################################
System Performance Report
"
}
HP_CPU() {
/usr/bin/top -n 1 -d 1 -f /tmp/top.out
echo "
#####################################################################
CPU USAGE
#####################################################################
"
printf "%-20s%-20s%-20s\n" "CPU ID" "IDLE" "TOTAL IDLE"
printf "%-20s%-20s%-20s\n" "------" "----" "---------"
for i in $(cat /tmp/top.out|grep '%'|grep -v CPU|grep -v avg|awk '{print $1}'|head -10)
do
CPUID=`echo CPU$i`
CPU_IDLE=`cat /tmp/top.out|grep '%'|grep -v CPU|grep -v avg|awk -v var=$i '{ if ($1 == var ) print $6}'|cut -d '%' -f 1,1`
TOTAL_CPU=`awk '/^avg/ { print $6; exit}' /tmp/top.out|cut -d '%' -f 1,1`
printf "%-20s%-20s%-20s\n" "$CPUID" "$CPU_IDLE" "$TOTAL_CPU"
done
echo "
---------------------------------------------------------------------
Process CPU Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s\n" "PID" "USER" "%CPU" "COMMAND"
printf "%-20s %-20s %-20s %-20s\n" "---" "----" "----" "------------------"
UNIX95= ps -ef -o 'pid ruser pcpu args'|sort -nr|head -10 |grep -v "PID"|tail -11|awk '{ printf "%-20s %-20s %-20s %-20s\n", $1, $2, $3, $4}'
cat /dev/null > /tmp/top.out
}
HP_Memory() {
echo "
#####################################################################
Memory USAGE
#####################################################################
"
TOTALMEM=`/opt/ignite/bin/print_manifest |grep -i memory|awk '{print $3}'`
USEDMEM=`/usr/sbin/swapinfo -tam|grep memory|awk '{print $2}'`
FREEMEM=`/usr/sbin/swapinfo -tam|grep memory|awk '{print $2}'`
TOTALSWAP=0
USEDSWAP=0
FREESWAP=0
SWAP_RES=0
for i in $(/usr/sbin/swapinfo -tam|grep dev|awk '{print $2}'); do TOTALSWAP=$(( $TOTALSWAP + $i )); done
for i in $(/usr/sbin/swapinfo -tam|grep dev|awk '{print $3}'); do USEDSWAP=$(( $USEDSWAP + $i )); done
for i in $(/usr/sbin/swapinfo -tam|grep dev|awk '{print $4}'); do FREESWAP=$(( $FREESWAP + $i )); done
Mem_res=`/usr/sbin/swapinfo -tam|grep memory|awk '{print $5}'|cut -d '%' -f 1,1|awk '{ print 100 - $1; exit}'`
for i in $(/usr/sbin/swapinfo -tam|grep dev|awk '{print $5}'|cut -d '%' -f 1,1); do SWAP_RES=$(( $SWAP_RES + $i )); done
Swap_res=`echo "$SWAP_RES"|awk '{print 100 - $1}'`
echo "
---------------------------------------------------------------------
Memory Detail
---------------------------------------------------------------------
"
printf "%-20s%-20s%-20s%-20s%-20s\n" "TOTAL MEMORY" "USED MEMORY" "FREE MEMORY" "FREE MEMORY(%)" "CACHE MEM"
printf "%-20s%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------" "---------"
printf "%-20s%-20s%-20s%-20s%-20s\n" " $TOTALMEM MB" " $USEDMEM MB" " $FREEMEM MB" " %$Mem_res" "$Cache MB"
echo "
---------------------------------------------------------------------
Swap Detail
---------------------------------------------------------------------
"
printf "%-20s%-20s%-20s%-20s\n" "TOTAL SWAP" "USED SWAP" "FREE SWAP" "FREE SWAP(%)"
printf "%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------"
printf "%-20s%-20s%-20s%-20s\n" " $TOTALSWAP MB" " $USEDSWAP MB" " $FREESWAP MB" " %$Swap_res"

echo "
---------------------------------------------------------------------
Process Memory Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s\n" "RSS" "PID" "USER" "COMMAND"
UNIX95= ps -ef -o 'vsz pid ruser args' |sort -nr|head -10|awk '{ printf "%-20s %-20s %-20s %-20s\n", $1, $2, $3, $4}'
}

###################Linux Control###################
Linux_Information() {
echo -e "
#####################################################################
Health Check Report (CPU,Process,Disk Usage, Memory)
#####################################################################
Hostname : `hostname`
Kernel Version : `uname -r`
Uptime : `uptime | sed 's/.*up \([^,]*\), .*/\1/'`
Last Reboot Time : `/usr/bin/who -b | awk '{print $3,$4}'`
Core Number : `cat /proc/cpuinfo |grep processor|wc -l|awk '{print $1}'`
CPU Type : `/usr/sbin/dmidecode -t processor|grep Version|grep GHz |sort -u|cut -d ':' -f 2,2|awk '{print substr($0,length($1)+1);}'`
Product : `/usr/sbin/dmidecode -t system|grep Product|cut -d ':' -f 2,2`
IP : `cat /etc/hosts|egrep 'loghost|localhost'|awk '{print $1}'|grep -v ":"|grep -v 127.0.0.1`
Virtual/Physical : `/usr/sbin/dmidecode -t System|grep -iw Product|cut -d ':' -f 2,2`
Load Average : `uptime | awk -F'load average:' '{ print $2 }' |cut -d ',' -f 1,1|awk '{print $1}'`
Heath Status : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d, | awk '{if ($1 > 2) print "Unhealthy"; else if ($1 > 1) print "Caution"; else print "Normal"}'`
#####################################################################
System Performance Report
"
}
Linux_CPU() {
echo -e "
#####################################################################
CPU USAGE
#####################################################################
"
printf "%-20s%-20s%-20s\n" "CPU ID" "IDLE" "TOTAL IDLE"
printf "%-20s%-20s%-20s\n" "------" "----" "---------"
for i in $(cat /proc/cpuinfo |grep processor|awk '{print $3}'|head -10)
do
CPUID=`echo CPU$i`
#CPU_IDLEX=`/usr/bin/mpstat -P ALL`
#CPU_IDLE=`echo $CPU_IDLEX| awk -v var=$i '{ if ($3 == var ) print $10 }'`
CPU_IDLE=`/usr/bin/mpstat -P ALL 1 1|grep Average|grep -v all|awk -v var=$i '{ if ($2 == var ) print $9}'`
#TOTAL_CPU=`sar -u 1 1|awk '{print $8}'|grep '[0-9][0-9]'`
TOTAL_CPU=`/usr/bin/top -b -d 1 -n1|grep Cpu|awk '{print $5}'|cut -d '%' -f 1,1`
printf "%-20s%-20s%-20s\n" "$CPUID" "$CPU_IDLE" "$TOTAL_CPU"
done
echo "
---------------------------------------------------------------------
Process CPU Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s\n" "PID" "USER" "%CPU" "COMMAND"
printf "%-20s %-20s %-20s %-20s\n" "---" "----" "----" "------------------"
/usr/bin/top b -n1 | head -17 |grep -v "PID"|tail -11|awk '{ printf "%-20s %-20s %-20s %-20s\n", $1, $2, $9, $12}'
}
Linux_Memory() {
echo -e "
#####################################################################
Memory USAGE
#####################################################################
"
TOTALMEM=`/usr/bin/free -m | head -2 | tail -1| awk '{print $2}'`
TOTALBC=`echo "scale=2;if($TOTALMEM<1024 && $TOTALMEM > 0) print 0;$TOTALMEM/1024"| bc -l`
USEDMEM=`/usr/bin/free -m | head -2 | tail -1| awk '{print $3}'`
USEDBC=`echo "scale=2;if($USEDMEM<1024 && $USEDMEM > 0) print 0;$USEDMEM/1024"|bc -l`
FREEMEM=`/usr/bin/free -m | head -2 | tail -1| awk '{print $4}'`
FREEBC=`echo "scale=2;if($FREEMEM<1024 && $FREEMEM > 0) print 0;$FREEMEM/1024"|bc -l`
TOTALSWAP=`/usr/bin/free -m | tail -1| awk '{print $2}'`
TOTALSBC=`echo "scale=2;if($TOTALSWAP<1024 && $TOTALSWAP > 0) print 0;$TOTALSWAP/1024"| bc -l`
USEDSWAP=`/usr/bin/free -m | tail -1| awk '{print $3}'`
USEDSBC=`echo "scale=2;if($USEDSWAP<1024 && $USEDSWAP > 0) print 0;$USEDSWAP/1024"|bc -l`
FREESWAP=`/usr/bin/free -m | tail -1| awk '{print $4}'`
FREESBC=`echo "scale=2;if($FREESWAP<1024 && $FREESWAP > 0) print 0;$FREESWAP/1024"|bc -l`
Cache=`/usr/bin/free -m | head -2 | tail -1| awk '{print $7}'`
Cached=`echo "scale=2;if($Cache<1024 && $Cache > 0) print 0;$Cache/1024"|bc -l`
Mem_res=`echo "$(($FREEMEM * 100 / $TOTALMEM ))"`
Swap_res=`echo "$(($FREESWAP * 100 / $TOTALSWAP ))"`
echo "
---------------------------------------------------------------------
Memory Detail
---------------------------------------------------------------------
"
printf "%-20s%-20s%-20s%-20s%-20s\n" "TOTAL MEMORY" "USED MEMORY" "FREE MEMORY" "FREE MEMORY(%)" "CACHE MEM"
printf "%-20s%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------" "---------"
printf "%-20s%-20s%-20s%-20s%-20s\n" " $TOTALMEM MB" " $USEDMEM MB" " $FREEMEM MB" " %$Mem_res" "$Cache MB"
echo "
---------------------------------------------------------------------
Swap Detail
---------------------------------------------------------------------
"
printf "%-20s%-20s%-20s%-20s\n" "TOTAL SWAP" "USED SWAP" "FREE SWAP" "FREE SWAP(%)"
printf "%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------"
printf "%-20s%-20s%-20s%-20s\n" " $TOTALSWAP MB" " $USEDSWAP MB" " $FREESWAP MB" " %$Swap_res"

echo "
---------------------------------------------------------------------
Process Memory Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s %-20s\n" "USER" "PID" "%MEM" "RSS" "COMMAND"
#ps aux | awk '{print $1, $2, $4, $6, $11}' | sort -k3rn | head -n 10|awk '{ printf "%-20s %-20s %-20s %-20s %-20s\n", $1, $2, $3, $4, $5}'
ps -eo user,pid,pmem,rss,comm| awk '{print $1, $2, $3, $4, $5}' | sort -k3rn | head -n 10|awk '{ printf "%-20s %-20s %-20s %-20s %-20s\n", $1, $2, $3, $4, $5}'
}
Linux_Disk() {
echo -e "
#####################################################################
Disk Performance
#####################################################################
"
c=1
a=1
k=0
while [ $c -le 10 ];
do
#Tot=`iostat -x 1 1 |grep ssd|awk '{total = total + int($8)}END{print total}'`
Tot=`/usr/bin/iostat -x 1 1 |grep sd|awk '{total = total + int($13)}END{print total}'`
num=`/usr/bin/iostat -x 1 1 |grep sd|wc -l`; avearaST=`echo "$Tot/$num" | bc`
if [[ "$(echo $avearaST)" -gt "100" ]]; then (( c++ )); if [[ "$(echo $c)" -gt "10" ]]; then
x=`expr $k + $a`
fi
else
c=`expr $c + $a`
fi
done
if [[ "$(echo $k)" -gt "5" ]];
then
echo "Disk Service Time Problem. Check disk I/O performance"
else
echo "Disk Service Time OK"
fi

}
###################################################
###################Solaris Control#################
Solaris_Information() {

echo "
#####################################################################
Health Check Report (CPU,Process,Disk Usage, Memory)
#####################################################################
Hostname : `hostname`
Kernel Version : `uname -r`
Uptime : `uptime | sed 's/.*up \([^,]*\), .*/\1/'`
Last Reboot Time : `/usr/bin/who -b|awk '{print $4,$5,$6}'`
Core Number : `echo "::cpuinfo"|/usr/bin/mdb -k|grep -v "PROC"|wc -l|awk '{print $1}`
CPU Type : `/usr/sbin/psrinfo -vp|grep clock|head -1`
CPU Socket Number: `/usr/sbin/psrinfo -vp|grep clock|wc -l|awk '{print $1}`
Product : `uname -i`
IP : `cat /etc/hosts|grep loghost|awk '{print $1}'`
Virtual/Physical : `/usr/sbin/virtinfo`
Health Status : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d,|cut -d ':' -f 2,2| awk '{if ($1 > 2) print "Unhealthy"; else if ($1 > 1) print "Caution"; else print "Normal"}'`
Load Average : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d,|cut -d ':' -f 2,2`
#####################################################################
System Performance Report
"
}
Solaris_CPU() {
echo "
#####################################################################
CPU USAGE
#####################################################################
"
printf "%-20s%-20s%-20s\n" "CPU ID" "IDLE" "TOTAL IDLE"
printf "%-20s%-20s%-20s\n" "------" "----" "---------"
for i in $(/usr/sbin/psrinfo |awk '{print $1}'|head -10)
do
# echo "CPU$i : `/usr/bin/mpstat |awk '$1 == '$i'' |awk '{print $16}'` "
CPUID=`echo CPU$i`
CPU_IDLE=`/usr/bin/mpstat |awk '$1 == '$i'' |awk '{print $16}'|cut -d ':' -f 2,2`
TOTAL_CPU=`sar -u 1 1|grep -v SunOS|awk '{print $5}'|grep '[0-9][0-9]'`
printf "%-20s%-20s%-20s\n" "$CPUID" "$CPU_IDLE" "$TOTAL_CPU"
done
echo "
---------------------------------------------------------------------
Process CPU Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s\n" "%CPU" "PID" "USER" "COMMAND"
ps -ef -o pcpu,pid,user,args|sort -nr|head -10|grep -v "PID"|awk '{ printf "%-20s %-20s %-20s %-20s\n", $1, $2, $3, $4}'
}
Solaris_Memory() {
echo "
#####################################################################
Memory USAGE
#####################################################################
"

TOTALMEM=`/usr/sbin/prtconf |grep -w "Memory size:"|awk '{print $3}'`
FREEMEMB=`sar -r 1 1 |sed -n '$p'|awk '{print $2}'`
FREEMEM=`echo "$FREEMEMB*8/1024"|bc -l|cut -d '.' -f 1,1`
USEDMEM=`echo "$TOTALMEM-$FREEMEM"|bc -l`
SWAPVALUE=`/usr/sbin/swap -l|awk '{print $4}'|grep -v blocks`
TOTALSWAP=`echo "$SWAPVALUE/1024/2"|bc -l|cut -d '.' -f 1,1`
FREESWAPVALUE=`/usr/sbin/swap -l|awk '{print $5}'|grep -v free`
FREESWAP=`echo "$FREESWAPVALUE/1024/2"|bc -l|cut -d '.' -f 1,1`
USEDSWAP=`echo "$TOTALSWAP-($FREESWAP)"|bc -l`
Mem_res=`echo "$(($FREEMEM * 100 / $TOTALMEM ))"`
Swap_res=`echo "$(($FREESWAP * 100 / $TOTALSWAP ))"`
echo "
---------------------------------------------------------------------
Memory Detail
---------------------------------------------------------------------
"

printf "%-20s%-20s%-20s%-20s\n" "TOTAL MEMORY" "USED MEMORY" "FREE MEMORY" "FREE MEMORY(%)"
printf "%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------"
printf "%-20s%-20s%-20s%-20s\n" " $TOTALMEM MB" " $USEDMEM MB" " $FREEMEM" " %$Mem_res"
echo "
---------------------------------------------------------------------
Swap Detail
---------------------------------------------------------------------
"
printf "%-20s%-20s%-20s%-20s\n" "TOTAL SWAP" "USED SWAP" "FREE SWAP" "FREE SWAP(%)"
printf "%-20s%-20s%-20s%-20s\n" "------------" "-----------" "-----------" "--------------"
printf "%-20s%-20s%-20s%-20s\n" " $TOTALSWAP MB" " $USEDSWAP MB" " $FREESWAP" " %$Swap_res"

echo "
---------------------------------------------------------------------
Process Memory Usage Detail
---------------------------------------------------------------------
"
printf "%-20s %-20s %-20s %-20s\n" "PID" "%MEM" "RSS" "COMMAND"
ps -ef -o pid,pmem,vsz,rss,comm | sort -rnk2 | head -10|grep -v "PID"|awk '{ printf "%-20s %-20s %-20s %-20s\n", $1, $2, $3, $5}'
}
Solaris_Disk() {
echo "
#####################################################################
Disk Performance
#####################################################################
"
c=1
a=1
k=0
while [ $c -le 10 ];
do
Tot=`/usr/bin/iostat -x 1 1 |grep ssd|awk '{total = total + int($8)}END{print total}'`
num=`/usr/bin/iostat -x 1 1 |grep ssd|wc -l`; avearaST=`echo "$Tot/$num" | bc`
if [[ "$(echo $avearaST)" -gt "100" ]]; then (( c++ )); if [[ "$(echo $c)" -gt "10" ]]; then
x=`expr $k + $a`
fi
else
c=`expr $c + $a`
fi
done
if [[ "$(echo $k)" -gt "5" ]];
then
echo "Disk Service Time Problem. Check disk I/O performance"
else
echo "Disk Service Time OK"
fi
}
###################################################

OS=`uname -s`

case "$OS" in
"SunOS")
Solaris_Information
Solaris_CPU
Solaris_Memory
Solaris_Disk
;;
"Linux")
Linux_Information
Linux_CPU
Linux_Memory
Linux_Disk
;;
"HP-UX")
HP_Information
HP_CPU
HP_Memory
;;
"AIX")
;;

esac

exit 0
