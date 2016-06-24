#!/bin/bash

# Driver for the Package Maker v1.0
# --SUBJECT TO CHANGE--

echo "Initializing Package Maker..."
sleep 1

#The default is to remake all Debian packages when no arguments are passed.

#Check command-line arguments
if [ $# -gt 0 ]
then
	echo "Args passed!"
	#Parse the arguments
else
	echo "No Args passed!"
fi

cd helpers/

#Have I already been used?
if [ -d imp ]
then
	#Yes.
	echo "Done. Remaking packages..."
else
	#No. First time being used.
	echo "Done. Making preparations for first time package making..."
	sleep 1

	#Make the important directory for the version checking and directory making stages.
	mkdir -p imp

	cd ../

	#Copy the debian files over to imp/
	cp -r debFiles/ helpers/imp
	
	#Get back into helpers/
	cd helpers/

	#Packaging prelims: creating directories for each distro inside of each lib directory.
	while read -r lib
	do
		#Put the lib directories inside of the imp/, versions/, && packages/ directories
		cd imp/
		mkdir -p $lib
	
		cd ../../versions/	
		mkdir -p $lib
		
		cd ../packages/
		mkdir -p $lib
		
		#Now, make the distro directories in each one
		while read -r -u 3 distro
		do
			#Start in the packages/ directory
			cd $lib
			mkdir -p $distro						
			
			#Go to versions/
			cd ../../versions/$lib
			mkdir -p $distro		
	
			cd $distro
			
			echo "1.0" > version.txt #THIS WILL BE CHANGED
			
			#Go to imp/
			cd ../../../helpers/imp/$lib
			mkdir -p $distro
			
			#Go back to packages/ && repeat
			cd ../../../packages/		
	
		done 3< ../helpers/distros.txt
		
		cd ../helpers/
	
	done < libs.txt
	
	echo "Done."
fi

echo

#Version check
. ./versChecker.sh libs.txt distros.txt

#Directory maker 
. ./dirMaker.sh libs.txt distros.txt

#Copy stage
. ./copyer.sh libs.txt distros.txt

#Debian Handler
. ./debHandler.sh libs.txt distros.txt
