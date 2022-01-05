#!/bin/bash

MemUsage ()
{
	# $3 is Used Mem, $2 is Total Mem.
	free -m | grep Mem | awk '{printf "%d/%dMB (%.2f%%)", $3, $2, 100*$3/$2}'
}

LVMisEnabled ()
{
	lsblk | awk '{print $6}' | grep -w lvm &> /dev/null && echo 'yes' || echo 'no'
}

DiskUsage ()
{
	# $3 = Used.
	# $4 = Availible.
	UsedDisk=$(df | awk 'NR>1 {Count+=$3} END {print Count}')
	TotalDisk=$(($(df | awk 'NR>1 {Count+=$4} END {print Count}') + $UsedDisk))
	echo "$UsedDisk $TotalDisk" | awk '{printf "%.0f/%.0fGB (%.0f%%)\n", $1/1024, $2/1048576, 100*$1/$2}'
}

wall "
    #Architecture: $(uname -a)
    #CPU physical : $(lscpu | awk '/^CPU\(s\):/ {print $2}')
    #vCPU :$(awk -F ':' '/^cpu cores/ {print $2}' /proc/cpuinfo)
    #Memory Usage: $(MemUsage)
    #Disk Usage: $(DiskUsage)
    #CPU Load: $(top -bn1 | awk '/%Cpu/ {printf "%.1f%%\n", $2}')
    #Last boot: $(who -b | awk '{print $3, $4}')
    #LVM use: $(LVMisEnabled)
    #Connexions TCP : $(ss -t | awk 'END {print NR-1}') ESTABLISHED
    #User log: $(users | tr ' ' '\n' | uniq | wc -l)
    #Network: IP $(hostname -I)($(ip link show enp0s3 | awk '/ link\/ether / {print $2}'))
    #Sudo : $(find /var/log/sudo-io/ -mindepth 3 -maxdepth 3 -type d -print | wc -l) cmd
"
