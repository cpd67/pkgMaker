#!/bin/bash

echo "Begin stage 2: Directory making."
sleep 1

count=0

while read -r lib #For each library
do
	while read -r -u 3 distro #For each distro
	do
		cd imp/$lib/$distro
		#Clear out the masterDirs.txt list
		echo "" > masterDirs.txt

		#Is it the first use case?
		firstUse=$(cat firstUse.txt)
		if [ $firstUse = "yes" ]
		then
			#Yes.
			#We just have to make the directory then.
			dirName=$(cat directories.txt)
			
			cd ../../../../packages/$lib/$distro/
			
			#If the directory already exists, something went wrong.
			if [ -d "$dirName" ] && [ ! -e noChanges.txt ]
			then 
				echo "$dirName found in $distro. Something went wrong..."
				echo "Abort."
				exit 1
			#Else, if no changes have been made, don't do anything.
			elif [ -e noChanges.txt ] 
			then
				echo "No changes have been made for $lib in $distro."
				rm noChanges.txt
			#Else, we need to make directories.
			else 
				#Make the directory
				mkdir -p $dirName

				#Go back to the distro/ directory
				cd ../../../helpers/imp/$lib/$distro/
			
				#Tell copyer.sh the copying destination.
				echo "$dirName" >> masterDirs.txt			
			fi

			#Get back in place for the next iteration	
			cd ../../../

		else
			#No.
			#We'll have to add a 3rd loop for the directories.txt files.			
			cd ../../../../packages/$lib/$distro/
			
			#First, check if any changes have been registered.
			if [ -e noChanges.txt ]
			then
				#None have been made.
				echo 
				echo "No changes made to $lib in $distro."
				echo "Skipping..."
				echo
				rm noChanges.txt
				#Get back in place for the next distro.
				cd ../../../helpers/
			else
				#Changes have been made. Begin preparations.
				while read -r -u 4 dirName 
				do
					#Do we have to move the old directory?
					if [ $count == 0 ]
					then
						#First, have any changes been made?
						#If no, then don't do anything.
						#We'll have to move the old directory.
						mkdir -p oldBuilds/

						#Is the old directory in the distro/ directory?
						if [ -d "$dirName" ]
						then
							echo "$dirName found in $distro."
						else
							#No. Something went wrong.
							echo "$dirName not found in $distro."
							echo "Abort."
							exit 1
						fi
						
						cd $dirName
						
						#http://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script
						#Check if the debian directory is inside of the old directory
						if [ -d "debian" ]
						then
							#Found
							echo "$lib debian folder found for: $distro."
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
							#Not found!
							echo "$lib debian folder not found for: $distro."
							cd ../
						fi	

						#Move the old directory into the oldBuilds/ directory
						mv "$dirName" oldBuilds/
							
						count=1
					#Do we have to make the new directory?
					else
						#Yes.
						mkdir -p "$dirName"
						cd ../../../helpers/imp/$lib/$distro/
						
						echo "$dirName" >> masterDirs.txt
						count=0
						
						#Get back into position for the next distro
						cd ../../../
					fi
				done 4< ../../../helpers/imp/$lib/$distro/directories.txt
			fi
		fi
		
	done 3< $2

done < $1	

echo "End stage 2."
echo
