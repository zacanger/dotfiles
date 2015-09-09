#!/bin/bash
hw_mem=0
free_mem=0
human=1024

mem_info=$(</proc/meminfo)
                mem_info=$(echo $(echo $(mem_info=${mem_info// /}; echo ${mem_info//kB/})))
                for m in $mem_info; do
                        if [[ ${m//:*} = MemTotal ]]; then
                                memtotal=${m//*:}
                        fi

                        if [[ ${m//:*} = MemFree ]]; then
                                memfree=${m//*:}
                        fi

                        if [[ ${m//:*} = Buffers ]]; then
                                membuffer=${m//*:}
                        fi

                        if [[ ${m//:*} = Cached ]]; then
                                memcached=${m//*:}
                        fi
                done

usedmem="$(((($memtotal - $memfree) - $membuffer - $memcached) / $human))"
totalmem="$(($memtotal / $human))"

echo "$usedmem"
