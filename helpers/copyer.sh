#!/bin/bash

echo "Begin stage 3: copying files."
sleep 1

# You'll have to copy over the files from the first distro over to the successive ones.
# i.e. tsgl-1.6.2 & tsgl_1.6.2.orig.tar.gz from trusty to xenial, distro3, distro4, etc...
# That prevents the rejection of packages for different distros. 
# After copying the files over into the first distro, copy over the directory and upstream tarball to the sucessive distro folder.

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
			#We'll have to copy files over.
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
				
				if [ -d "oldBuilds" ]
				then
					#Move the old tar ball in with the old version folder
					mv *.orig.tar.gz oldBuilds/
				else
					#Make sure no tarballs are in there
					rm *.orig.tar.gz 
				fi
			
				tar czf "$newDir".orig.tar.gz $dirName
				
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
				
			else #Generic copy
				
				#Go to the library
				cd ../../../../../$lib/

				#Copy over all files
				cp -r * ../pkgMaker/packages/$lib/$distro/$dirName
				
				#Get over to the distro directory in the packages directory
				cd ../pkgMaker/packages/$lib/$distro
				
				sleep 1
				
				#Get the name (as per version conventions)
				newDir=$(echo "$dirName" | tr - _)

				#Check if we've made packages before for this library
				if [ -d "oldBuilds" ]
				then
					mv *.orig.tar.gz oldBuilds/
				else 
					#No, remove any upstream tarballs should they happen to exist
					rm *.orig.tar.gz 
				fi
				
				#Create the new upstream tarball
				tar czf "$newDir".orig.tar.gz $dirName

				#Look for the debian directory
				if [ -d "debian" ]
				then
					#Found. Move it into the new directory.
					echo "Debian folder found! Moving..."
					mv debian/ $dirName

					#Tell debHelper.sh that we didn't create a debian folder.
					cd ../../../helpers/imp/$lib/$distro
					echo "no" > debDirCreated.txt					
				else
					#Not found. Create one, move it into the new directory.
					echo "Debian folder not found! Creating..."
					mkdir -p debian/

					mv debian/ $dirName

					#Tell debHelper.sh that we did create a debian folder.
					cd ../../../helpers/imp/$lib/$distro
					echo "yes" > debDirCreated.txt

				fi
				
				cd ../../../
			fi
		fi
	
	done 4< $2
	
done 3< $1

#End copying stage
echo "End stage 3."
echo
