#!/bin/bash
#
# rebuild directory structure based on the outputs of `tree -F` 
# author: kozz
# date: 2014-06-06
# modified: 2014-06-09
# 

usage(){
 cat <<USAGE
USAGE: 
    ./treegen.sh tree_outputs
USAGE
 exit 1  
}

index_of(){
    local str=$1
    local substr=$2
    for i in $(seq 0 $((${#str} - 1))); do 
        [[ ${str:$i:1} == ${substr:0:1} ]] && {
            echo $i 
            return
        }
    done
}

OLDIFS=$IFS
IFS=$'\n'
f=$1
[[ -z $f ]] && usage

last_dir=
parent[0]="./"
for line in $(<$f); do 
    [[ $line =~ ^[0-9]+.* ]] && exit 0
    dir=${line##* }
    [[ -z $last_dir || ${dir:$((${#dir}-1)):1} != '/' ]] && { 
        last_dir=$dir
        continue
    }
    depth=$(($(index_of $line $dir)/4))
    path=${parent[$((depth-1))]}$dir
    parent[$depth]=$path
    #echo $depth:$path
    mkdir $path
done

IFS=$OLDIFS

