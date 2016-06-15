#!/bin/bash


echo "Directories being made..."
sleep 1

count=0

while read -r lib 
do
	cd imp/
	
	#See if it's the first time use case...
	firstTime=$(cat "$lib"FirstTime.txt)
	if [ $firstTime = "yes" ]
	then
		#Yes.
		cd ../
		
		#Read the directory from the text file
		dirName=$(cat "$lib"Directories.txt)
		
		cd ../testBed/ #Change when script is finished!

		#Check if the directory is inside of the workspace...
		if [ -d "$dirName" ] 
		then
			#Yes. Something went wrong...
			echo "Directory found! Something went wrong..."
			echo "Abort."
			exit 1
		else
			mkdir -p $dirName
		fi
		
	else
		#Not the first time use case. Continue as planned...	
		cd ../
		
		while read -r -u 4 dirName
		do
			#Do we have to move the old directory?
			if [ $count -eq 0 ]
			then
				#Yes.
				cd ../testBed #Change this when the script is finished!
				mkdir -p oldBuilds/
				#Check if the directory even exists first...		
				if [ -d "$dirName" ]
					then
					echo "$dirName found!"
				else 
					#No. Something went wrong (first time use case)....
					echo "$dirName not found! Aborting..."
					exit 1
				fi
			
				cd "$dirName"
		
				#http://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script
				#Check if the debian directory is inside
				if [ -d "debian" ]
				then
					#Found
					echo "Debian folder found!"	
					#Check if it's a symlink
					if [ -L "debian" ] 
					then
						echo "SYMLINK"
						exit 1
					else
						#Nope. Move it out
						mv debian ../
						cd ../
					fi	
				else
					echo "Debian folder not found!"
					cd ../	
				fi
			#Move the old directory into the oldBuilds directory
			mv "$dirName" oldBuilds/
			count=1
			#Do we have to make the new directory?
			else
				mkdir -p "$dirName" #Should still be within the correct directory
				count=0
			fi
		done 4< "$lib"Directories.txt
	fi
	cd ../helpers/
done < $1

#./copyer.sh

