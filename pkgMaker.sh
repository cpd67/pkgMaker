#!/bin/bash

# Driver for the Package Maker v1.0
# --SUBJECT TO CHANGE--

echo "Initializing Package Maker..."
sleep 1

cd helpers/

#Have I already been used?
if [ -d imp ]
then
	#Yes.
	echo "Done. Remaking packages..."
else
	#No. First time being used.
	echo "Done. Making preparations for first time package making..."
	#Make the important directory for the version checking and directory making stages.
	mkdir -p imp	
	echo "Finished."
fi

echo
echo "Begin."

#Version check
. ./versChecker.sh libs.txt

#Directory maker 
. ./dirMaker.sh libs.txt

#Copy stage

./copyer.sh libs.txt masterDir.txt #THIS NEEDS TO BE CHANGED

#Debian Handler
