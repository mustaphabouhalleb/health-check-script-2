#!/bin/bash

# Gets the local server to monitor IPaddresses

IP=`ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`

echo "IPaddress: "$IP

# Get cputotal number of nuclear

cpu_num=`grep -c "model name"/proc/cpuinfo`

echo "cputotal number of nuclear: "$cpu_num

# 1, get CPUutilization

# Get the user space occupied CPUpercentage

cpu_user=`top -b -n 1 | grep Cpu | awk '{print $2}' | cut -f 1 -d "%"`

echo "user space occupied CPUpercentage: "$cpu_user

# Get kernel space occupied CPUpercentage

cpu_system=`top -b -n 1 | grep Cpu | awk '{print $3}' | cut -f 1 -d "%"`

echo "kernel space occupied CPUpercentage: "$cpu_system

# Get idle CPUpercentage

cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $5}' | cut -f 1 -d "%"`

echo "idle CPUpercentage: "$cpu_idle

# Gets waiting for input and output accounted for CPUpercentage

cpu_iowait=`top -b -n 1 | grep Cpu | awk '{print $3}' | cut -f 1 -d "%"`

echo "wait for input-output accounting for CPUPercentage: "$cpu_iowait

#2, get CPUcontext switches and interrupts

# Get CPUinterrupts

cpu_interrupt=`vmstat -n 1 1 | sed -n 3p | awk '{print $11}'`

echo "CPUinterrupts: "$cpu_interrupt

# Get CPUcontext switches

cpu_context_switch=`vmstat -n 1 1 | sed -n 3p | awk '{print $12}'`

echo "CPUcontext switches: "$cpu_context_switch

#3, get CPUload information

# Get CPU15minutes ago to the current load average

cpu_load_15min=`uptime | awk '{print $11}' | cut -f 1 -d ','`

echo "CPU 15minutes ago to the current load average: "$cpu_load_15min

# Get CPU5minutes ago to the current load average

cpu_load_5min=`uptime | awk '{print $10}' | cut -f 1 -d ','`

echo "CPU 5minutes ago to the current load average: "$cpu_load_5min

# Get CPU1minutes ago to the current load average

cpu_load_1min=`uptime | awk '{print $9}' | cut -f 1 -d ','`

echo "CPU 1minute ago to the current load average: "$cpu_load_1min

# Get the job queue (number ready state waiting processes )

cpu_task_length=`vmstat -n 1 1 | sed -n 3p | awk '{print $1}'`

echo "CPUtask queue length: "$cpu_task_length

#4, get memory information

# Obtain total physical memory

mem_total=`free | grep Mem | awk '{print $2}'`

echo "total physical memory: "$mem_total

# Get the amount of memory used operating system

mem_sys_used=`free | grep Mem | awk '{print $3}'`

echo "has been used total amount of memory (OS ): " "$mem_sys_used

# Obtain the operating system does not use the amount of memory

mem_sys_free=`free | grep Mem | awk '{print $4}'`

echo "The remaining amount of memory (OS ): " "$mem_sys_free

# Get the amount of memory the application has been used

mem_user_used=`free | sed -n 3p | awk '{print $3}'`

echo "Used amount of memory (the application ): " "$mem_user_used

# Get the application does not use the amount of memory

mem_user_free=`free | sed -n 3p | awk '{print $4}'`

echo "The remaining amount of memory (the application ): " "$mem_user_free

# Get the total size of the swap partition

mem_swap_total=`free | grep Swap | awk '{print $2}'`

echo "Swap Total size: "$mem_swap_total

# Get used swap partition size

mem_swap_used=`free | grep Swap | awk '{print $3}'`

echo "has been used swap partition size: "$mem_swap_used

# Get the remaining swap partition size

mem_swap_free=`free | grep Swap | awk '{print $4}'`

echo "The remaining swap partition size: "$mem_swap_free

#5, the Disk I/Ostatistics

echo "the specified device (/dev/sda)statistics "

# Requests per second to read the number of device-initiated

disk_sda_rs=`iostat -kx | grep sda| awk '{print $4}'`

echo "per second, the number of requests to read device-initiated: "$disk_sda_rs

# 2.number of requests to write device-initiated

disk_sda_ws=`iostat -kx | grep sda| awk '{print $5}'`

echo "per device initiated to write the number of requests: "$disk_sda_ws

# To device-initiated I/Orequest queue length average

disk_sda_avgqu_sz=`iostat -kx | grep sda| awk '{print $9}'`

echo "to the device to initiate the I/Orequest queue average length "$disk_sda_avgqu_sz

# Each time the device-initiated I/Orequests the average time

disk_sda_await=`iostat -kx | grep sda| awk '{print $10}'`

echo "each time the device-initiated I/Orequests the average time: "$disk_sda_await

# Initiated to the device I/Oservice times the average

disk_sda_svctm=`iostat -kx | grep sda| awk '{print $11}'`

echo "to launch the device I/Oservice times mean: "$disk_sda_svctm

# Initiates a device I/Orequests CPUtime percentage proportion

disk_sda_util=`iostat -kx | grep sda| awk '{print $12}'`

echo "initiates a device I/Orequests CPUtime percentage proportion: "$disk_sda_util
