#!/bin/bash

echo "Getting version number..."
sleep 1
echo

#Determine if the user made any changes to the library

#http://superuser.com/questions/421701/bash-reading-input-within-while-read-loop-doesnt-work
#Get the passed library name	
while read -u 3 -r lib
do
	#Go into the special directory...
	cd imp/

	#http://tldp.org/LDP/abs/html/fto.html
	#Check if the user has already used pkgMaker...
	if [ -e "$lib"OldVersion.txt ]
	then
		#Yes.
		#Get the old version number...
		oldVersNum=$(cat "$lib"OldVersion.txt)
		echo "$lib old version number: $oldVersNum"
		echo "Updating the version number..."
		
		#Go to the versions directory
		cd ../../versions/

		#Use the old version number that we got from the text file...
		./infoGetter.sh $oldVersNum
		
		#Store the new version number
		newVersNum=$(cat newVersNum.txt)
		
		echo "New version number: $newVersNum."

		rm newVersNum.txt
	
		#Update the version.txt file
		#(For redundancy. If someone deletes the imp/ directory, you can use the version.txt file as a fallback.)
		echo "$newVersNum" > "$lib"Version.txt
			
		#http://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-text-file-in-shell-script
		#Back out of the directories to write out results for dirMaker.sh
		cd ../helpers/
		echo "$lib-$oldVersNum" > "$lib"Directories.txt && echo "$lib-$newVersNum" >> "$lib"Directories.txt

		#Update the oldVers.txt file with the new version number (for the next set of packages...)
		cd imp/	
		echo "$newVersNum" > "$lib"OldVersion.txt
		
		#Tell dirMaker.sh that this isn't the first time a package has been made
		#for this library
		echo "no" > "$lib"FirstTime.txt
		
		cd ../
	else
		#First time use case
		echo "Old version number not found."
		echo "Getting version number from versions/ directory..."
		cd ../../versions/
		
		#Check if the user put the version number in a text file.
		if [ -e "$lib"Version.txt ]
		then
			#Get the version number from the text file
			versNum=$(cat "$lib"Version.txt)
			
			#http://ubuntuforums.org/showthread.php?t=922603
			#https://www.shell-tips.com/2006/11/04/using-bash-wildcards/
			#Check if the user made a mistake in putting the version number
			#Or if something went wrong when it was put in
			if [[ $versNum == ? ]] 
			then	
				#Fix and update
				versNum=$versNum".0"
				echo "$versNum" > "$lib"Version.txt	
			elif [[ $versNum == *. ]]
			then
				versNum=$versNum"0"
				echo "$versNum" > "$lib"Version.txt
			elif [[ $oldVersNum == *.*. ]]
			then
				versNum=$versNum"0"
				echo "$versNum" > "$lib"Version.txt
			fi

			echo "Found. $lib version number is: $versNum."

			cd ../helpers/
			
			#Store the version number in a text file so the directory maker
			#can use it
			echo "$lib-$versNum" > "$lib"Directories.txt	
			
			#Go into the important directory and create the oldVersion.txt file
			cd imp/
			echo "$versNum" > "$lib"OldVersion.txt
			
			#Tell the directory maker that this is first time use.
			echo "yes" > "$lib"FirstTime.txt
			
			cd ../
		else
			#File not found, user has not put the file in the correct place.
			echo "File not found for: $lib Aborting...."
			exit 1
		fi				
			
	fi

done 3< $1

#End version checking stage

