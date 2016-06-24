#!/bin/sh

echo "Begin final stage: debian directory management."
sleep 1

while read -r -u 3 lib #For each library
do

	while read -r -u 4 distro #For each distro
	do
		cd imp/$lib/$distro

		if [ -e debDirCreated.txt ]
		then
			read -r debCheck < debDirCreated.txt
			
			echo "$lib debian folder for $distro: $debCheck"
			
			cd ../../../
		else
			echo "debDircCreated.txt file not found. Abort."
			exit
		fi
			
	done 4< $2
done 3< $1

