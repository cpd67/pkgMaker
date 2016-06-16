#!/bin/bash

echo "Copying over files..."
sleep 1

#Iterate through the list of libraries
while read -r lib 
do
	#Will need to add a second loop for the distros
	
	#Iterate through the list of directories (locations to copy stuff to)
	while read -u 6 -r dirName
	do
		#Special case: tsgl
		#Because of the way that the Git directory is named,
		#The generic way of copying won't work (at the moment).
		if [ $lib = "tsgl" ]
		then
			cd ../../TSGL/
			
			make clean

			cp -r * ../pkgMaker/testBed/$dirName #THIS WILL HAVE TO BE CHANGED
			
			cd ../pkgMaker/testBed/ #THIS WILL HAVE TO BE CHANGED
			
			#Make the upstream tarball
			echo "Making upstream tarball for: $lib ..."
			sleep 1
			
			#http://stackoverflow.com/questions/2871181/bash-string-replacing-some-chars-with-another
			#Replace the - with _ in the directory name (naming conventions for upstream tarballs)
			newDir=$(echo "$dirName" | tr - _)
				
			#Make the upstream tarball
			tar cvzf "$newDir".orig.tar.gz $dirName
			
		
			#Check if the debian directory exists
			if [ -d "debian" ]
			then
				#Yes. 
				#Move it and tell debHandler.sh through a text file.
				echo "Debian folder found! Moving..."
				mv debian/ $dirName

				cd ../helpers/imp/
				echo "no" > debFolderCreated?.txt
			else 
				#No.
				#Make it, move it, then tell debHandler.sh.
				echo "Debian folder not found! Creating..."
				mkdir debian/
				mv debian/ $dirName
				
				cd ../helpers/imp/
				echo "yes" > debFolderCreated.txt
			fi
			
			cd ../
		else 
			echo "$lib"
		fi

	done 6< $2 #THIS WILL NEED TO BE CHANGED
	
	
done < $1

# ./debHandler.sh
