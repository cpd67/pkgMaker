#!/bin/bash

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
			
			read -r dirName < copyDir.txt

			#Get out of helpers/
			cd ../../../../

			#Tell the user to edit the files themselves using whatever text editor they like.
			#First time use case?
			if [[ $debCheck == yes ]]
			then
				#Yep.
				echo "$lib debian folder for $distro: $debCheck"
			
				#You'll have to copy over the files from the 
				#distro folder
				cd debFiles/$lib/$distro/debian
				
				cp -r * ../../../../packages/$lib/$distro/$dirName/debian
				
				#Get back into position
				cd ../../../../helpers/
				
			else 
				#Standard case. Debian files are already in existence.
				echo "Debian folder was not created for $lib in: $distro."
				cd helpers/
			fi
			
		else
			echo "debDirCreated.txt file not found. Abort."
			exit
		fi
		
	done 4< $2
done 3< $1

echo "Finished!"
echo
echo "Go into each debian folder and edit the files using your favorite text editor!"
echo 
