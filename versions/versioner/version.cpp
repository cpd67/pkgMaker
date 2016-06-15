#include <iostream>
#include <cstring>
#include <stdlib.h>
using namespace std;

int main(int argc, char * argv[]) {
	bool majorChange, minorChange, patchChange;
    //Check if args were passed...
	if(argc > 1) {
        //Get the numbers that need to be changed from the 
        //command line
		int majorNum = atoi(argv[1]);
		int minorNum = atoi(argv[2]);
		int patchNum = atoi(argv[3]);
        //Get the old version number
		char * versNum = argv[4];
        //Check which numbers need to be changed
		if(majorNum == 1) {
            //Get the number from the old version number 
			int major = (int)versNum[0];
            //Increment it and replace the old
			major++;
			versNum[0] = (char)major;
		}
		//Do the same for the minor and patch numbers
		if(minorNum == 1) {
			int minor = (int)versNum[2];
			minor++;
			versNum[2] = (char)minor;
		}

		if(patchNum == 1) {
			int patch = (int)versNum[4];
			patch++;
			versNum[4] = (char)patch;
		}
        //Send the new version number out for
        //processing by a bash script
		string newVersNum = versNum;
		cout << newVersNum;
	} else {
        cerr << "No args passed! Exiting..." << endl;
        exit(1);
    }
}
