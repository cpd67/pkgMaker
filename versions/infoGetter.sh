#!/bin/bash

#Holders
majorNum=0
minorNum=0
patchNum=0

#Get the old version number
oldVersNum=$1

#Ask for major changes
#http://linuxcommand.org/wss0110.php
read -r -p "Did you make any major changes to the library? (API changes, etc...) (y or n)" userInput

#http://stackoverflow.com/questions/10849297/compare-a-string-in-unix
if [ $userInput = "y" -o $userInput = "yes" ]
then
	echo "Major changes have been made."
	majorNum=1
elif [ $userInput = "n" -o $userInput = "no" ]
then
	echo "No major changes have been made."
else 
	echo "I didn't catch that."
fi
 
#Ask for minor changes
read -r -p "Did you make any minor changes to the library? (new features, optimization, documentation, etc...) (y or n)" userInput

if [ $userInput = "y" -o $userInput = "yes" ]
then
	echo "Minor changes have been made."
	minorNum=1
elif [ $userInput = "n" -o $userInput = "no" ]
then
	echo "No minor changes have been made."
else 
	echo "I didn't catch that."
fi

#Ask for bug fixes
read -r -p "Did you fix any bugs? (y or n)" userInput

if [ $userInput = "y" -o $userInput = "yes" ]
then
	echo "Bug fixes have been made."
	patchNum=1
elif [ $userInput = "n" -o $userInput = "no" ]
then
	echo "No bug fixes have been made."
else 
	echo "I didn't catch that."
fi

#Go into the versioner program
cd versioner/

#Compile and link it, then execute it
g++ -c version.cpp && g++ version.o -o version

#http://ubuntuforums.org/showthread.php?t=922603
#http://stackoverflow.com/questions/18161234/integer-comparison-in-bash-using-if-else
#https://www.shell-tips.com/2006/11/04/using-bash-wildcards/
#Determine if the user made a mistake with the version number
#Or if the version number needs to be expanded
if [[ $oldVersNum == ? ]] && (($minorNum == 1)) || [[ $oldVersNum == ? ]] # 1
then
	oldVersNum=$oldVersNum".0"
elif [[ $oldVersNum == *. ]] && (($minorNum == 1)) || [[ $oldVersNum == *. ]] # 1.
then
	oldVersNum=$oldVersNum"0"
elif [[ $oldVersNum == *.*. ]] && (($patchNum == 1)) || [[ $oldVersNum == *.*. ]] # 1.0
then
	oldVersNum=$oldVersNum"0"
fi

results=$(./version $majorNum $minorNum $patchNum $oldVersNum)

cd ../

#Put the results in a text file for next stage...
echo "$results" > newVersNum.txt


#http://askubuntu.com/questions/601227/can-i-call-a-cpp-program-in-bash
#http://stackoverflow.com/questions/21197207/returning-values-from-a-c-program-into-a-bash-script
#Compile and execute the versioner program,
#Capturing the output
#g++ -c version.cpp && g++ version.o -o version
#newVersNum=$(./version $oldVersNum)


