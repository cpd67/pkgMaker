#!/bin/bash

echo "Hey there, i'm your copyer!"

#Starting out in helpers, go to imp/
cd imp/

#Iterate through the list of libraries
while read -u 5 -r lib 
do
	#Will need to add a second loop for the distros
	
	#Iterate through the list of directories (locations to copy stuff to)
	while read -u 6 -r dirName
	do
		if [ "$lib" = "tsgl" ]
		then
			cd ../../../TSGL/
			
			make clean

			cp -r * ../../
		fi

	done 6< $3
	
	
done 5< $1

# ./debHandler.sh
