#!/bin/bash

echo "Begin stage 3: Copying files."
sleep 1

#Iterate through the list of libraries
while read -r -u 3 lib 
do

	#Iterate through the list of distros
	while read -r -u 4 distro 
	do
		cd imp/$lib/$distro
		
		#If we haven't changed anything for this distro...
		if [ -e noChanges.txt ]
		then
			#Skip it
			echo "No changes made to $lib in $distro."
			echo "Skipping..."
			rm noChanges.txt
			cd ../../../	
		else 
			#We'll have to copy files over
			#Get the copy location from the text file
			read -r dirName < copyDir.txt
		
			#Special case for TSGL
			if [[ $lib == tsgl ]]
			then
	
				cd ../../../../../TSGL/
			
				#No binaries
				make clean
			
				#Copy the files and make the upstream tarball
				#Another *facepalm* moment: when you realize that "cp" is NOT "cd".
				cp -r * ../pkgMaker/packages/tsgl/$distro/$dirName #/$dirName
				echo "Making upstream tarball for $distro..."
				cd ../pkgMaker/packages/tsgl/$distro/			
				sleep 1
				
				#http://stackoverflow.com/questions/2871181/bash-string-replacing-some-chars-with-another
				#Replace the - with _ in the directory name (naming conventions for upstream tarballs)
				newDir=$(echo "$dirName" | tr - _)
				
				if [ -d "oldBuilds"	]
				then
					#Move the old tar ball in with the old version folder
					mv *.orig.tar.gz oldBuilds/
				else
					#Make sure no tarballs are in there
					rm *.orig.tar.gz 
				fi
			
				mv *.orig.tar.gz oldBuilds/
	
				tar cvzf "$newDir".orig.tar.gz $dirName
				
				#Check if the debian directory exists
				if [ -d "debian" ]
				then
					#Yes. 
					#Move it and tell debHandler.sh through a text file.
					echo "Debian folder found! Moving..."
					mv debian/ $dirName
	
					cd ../../../helpers/imp/tsgl/$distro
					echo "no" > debDirCreated.txt
				else 
					#No.
					#Make it, move it, then tell debHandler.sh.
					echo "Debian folder not found! Creating..."
					mkdir -p debian/
					mv debian/ $dirName
					
					cd ../../../helpers/imp/tsgl/$distro
					echo "yes" > debDirCreated.txt
				fi
	
				cd ../../../
				
			else
				cd ../../../
			fi
		fi
	
	done 4< $2
	
done 3< $1


##Iterate through the list of directories (locations to copy stuff to)
#	while read -u 6 -r dirName
#	do
#		#Special case: tsgl
#		#Because of the way that the Git directory is named,
#		#The generic way of copying won't work (at the moment).
#		if [ $lib = "tsgl" ]
#		then
#			cd ../../TSGL/
#			
#			make clean
#
#			cp -r * ../pkgMaker/packages/$dirName 
#			
#			cd ../pkgMaker/packages/
#			
#			#Make the upstream tarball
#			echo "Making upstream tarball for: $lib ..."
#			sleep 1
#			
#			#http://stackoverflow.com/questions/2871181/bash-string-replacing-some-chars-with-another
#			#Replace the - with _ in the directory name (naming conventions for upstream tarballs)
#			newDir=$(echo "$dirName" | tr - _)
#				
#			#Make the upstream tarball
#			tar cvzf "$newDir".orig.tar.gz $dirName
#			
#		
#			#Check if the debian directory exists
#			if [ -d "debian" ]
#			then
#				#Yes. 
#				#Move it and tell debHandler.sh through a text file.
#				#(So that all debHandler has to do is "autogenerate" the necessary files)
#				#(It will add more files and be the interface to edit them after we get to that stage).
#				echo "Debian folder found! Moving..."
#				mv debian/ $dirName
#
#				cd ../helpers/imp/
#				echo "no" > debFolderCreated.txt
#			else 
#				#No.
#				#Make it, move it, then tell debHandler.sh.
#				echo "Debian folder not found! Creating..."
#				mkdir debian/
#				mv debian/ $dirName
#				
#				cd ../helpers/imp/
#				echo "yes" > debFolderCreated.txt
#			fi
#			
#			cd ../
#		else 
#			echo "$lib"
#		fi
#done 
