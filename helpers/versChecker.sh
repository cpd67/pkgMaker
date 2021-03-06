#!/bin/bash

echo "Begin stage 1: version checking."
sleep 1

#Determine if the user made any changes to the library

#http://superuser.com/questions/421701/bash-reading-input-within-while-read-loop-doesnt-work
#Get the passed library name	
while read -r -u 3 lib #For each library
do
	while read -r -u 4 distro #For each distro version
	do
		cd imp/$lib/$distro/
		
		#First time making a package for this distro?
		if [ -e oldVersion.txt ]
		then
			#No.
			oldVersNum=$(cat oldVersion.txt)
			
			echo "$lib version for $distro: $oldVersNum".
			echo "Updating the version number for: $distro."
			
			#Go to the versions directory
			cd ../../../../versions/
			
			#Pass the old version number to infoGetter.
			./infoGetter.sh $oldVersNum
			
			#Get the results
			newVersNum=$(cat newVersNum.txt)
			
			echo "$newVersNum"

			#Check if we have to move onto the next library (no changes registered)...
			if [[ $newVersNum == NEXT ]]
			then
				#Yes.
				echo "Moving onto the next library..."
				rm newVersNum.txt

				cd $lib/$distro
				
				echo "$oldVersNum" > version.txt

				cd ../../../packages/$lib/$distro/

				#Tell dirMaker.sh & copyer.sh that no changes have been made
				echo "" > noChanges.txt && echo "" > ../../../helpers/imp/$lib/$distro/noChanges.txt
				
				cd ../../../helpers/imp/$lib/$distro
				echo "$oldVersNum" > oldVersion.txt
				
				echo "$lib-$oldVersNum" > directories.txt
				echo "no" > firstUse.txt
				
				cd ../../../
			else
				#No.
				echo "New version number: $newVersNum."
				rm newVersNum.txt

				#Update the version text files
				cd $lib/$distro
				echo "$newVersNum" > version.txt
				cd ../../../helpers/imp/$lib/$distro
				echo "$newVersNum" > oldVersion.txt

				#While you're there, create the directories.txt file
				echo "$lib-$oldVersNum" > directories.txt
				echo "$lib-$newVersNum" >> directories.txt

				#This isn't the first time pkgMaker was used to make
				#a package for this distro
				echo "no" > firstUse.txt
				
				cd ../../../
			fi

		else
			#Yes.
			echo
			echo "Old version number not found for $distro in imp/$lib/$distro/."
			echo "Getting version number from versions/ directory..."
			echo

			#Go into the distro directory that's in the current lib
			cd ../../../../versions/$lib/$distro
			
			#Check if the user put the version number in a text file...
			if [ -e version.txt ]
			then
				#Get the version number from the text file
				versNum=$(cat version.txt)
			
				#http://ubuntuforums.org/showthread.php?t=922603
				#https://www.shell-tips.com/2006/11/04/using-bash-wildcards/
				#Check if the user made a mistake in putting the version number
				#Or if something went wrong when it was put in
				if [[ $versNum == ? ]] 
				then	
					#Fix and update
					versNum=$versNum".0"
					echo "$versNum" > version.txt	
				elif [[ $versNum == *. ]]
				then
					versNum=$versNum"0"
					echo "$versNum" > version.txt
				elif [[ $oldVersNum == *.*. ]]
				then
					versNum=$versNum"0"
					echo "$versNum" > version.txt
				fi	
	
				echo "Found. $lib version number for $distro is: $versNum."
				
				#Create the version text file in imp/
				cd ../../../helpers/imp/$lib/$distro
				echo "$versNum" > oldVersion.txt
				
				#While you're there, create the directories.txt file
				echo "$lib-$versNum" > directories.txt
				
				#And tell the dirMaker.sh that this is the first time making 
				#a package for this distro
				echo "yes" > firstUse.txt
				
				cd ../../../

			else
				echo "$lib version file not found for: $distro."
				echo "Aborting..."
				exit 1 
			fi
		fi

	done 4< $2

done 3< $1

#End version checking stage
echo "End stage 1."
echo
