prev=3
while :
do	
	current=$(virsh list | wc -l)
	new="$((current - prev))"
        if [ $new -gt 0 ]
	then
		instances=($(virsh list | tail -$((new+1)) | sed '/^\s*$/d' | awk '{print$1}'))
		nodes_number=$(numactl --hardware | grep available| awk -F ":" '{print$2}' | awk '{print$1}')
		for ((i=0;i<nodes_number;i++));
		do
    			node_cpu_list=($(numactl --hardware | grep  "node $i cpus" | awk -F ":" '{print $2}'))
    			for x in "${instances[@]}"
    			do
				numa=$(virsh dumpxml $x | grep cpuset | awk -F "='" '{print$3}'|awk -F "-" '{print$1}')
        			for y in "${node_cpu_list[@]}"
        			do
					if [ $y == $numa ]
					then
						echo The instance $x has been placed on numa node $i
					fi
				done
        
    			done
   
		done
		prev=$current
	fi
sleep 5
echo listening
done