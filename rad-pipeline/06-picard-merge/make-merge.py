#!/usr/bin/env python
# Kyle Hernandez
# make-merge.py - Author parameter file for merging sam files

# These libraries are necessary for this script
import sys
import os
import glob

def load_files():
    """
    Loads the files in 'indir' into dictionary. The dictionary key
    is the SAMPLE id and the value is a list of files associated with that sample.
    I assume the file naming convention is JOB_SAMPLE.....sam
    """
    # initialize the temporary dictionary holder with '{}'
    dic = {}

    # globs the files
    for fil in glob.glob(indir + "/*.sam"):
        base = os.path.basename(fil)
        samp = base.split("_")[1]
        if samp not in dic:
            dic[samp] = []
        dic[samp].append(fil)
    return dic

# The Python script actually starts here.
# It is a good practice to start all python scripts like this with the
# if __name__=='__main__':
# statement.
# In Python, the white spaces are important. The convention is 4 spaces, but
# tabs are also considered accetable.
if __name__=='__main__':

    # Just like in our bash scripts, we want to make sure that the user has provided enough
    # command-line arguments to run the script. Since we imported the sys library, we can simply
    # check this by checking the length of the sys.argv list. Since the first value in the
    # sys.argv list is the scriptname, if we expect the user to provide 3 command-line arguments
    # as in this case, we need to make sure the length of the sys.argv list is 4.
    if len(sys.argv) != 4:
        # If the length of the sys.argv list is NOT equal to 4, then we print out the usage statement
        # and exit the program with exit status 1, since it is an error.
        print "Usage: make-merge.py <in/dir/> <out/dir/> <out.param>"
        sys.exit(1)
   
    # If we are here, then the user has provided the correct number of arguments.
    # So, we can declare our global variable by accessing the values of the sys.argv
    # list by index number using the '[]' brackets 
    indir = os.path.abspath(sys.argv[1])
    odir  = os.path.abspath(sys.argv[2])
    param = os.path.abspath(sys.argv[3])

    # Now we need to build a dictionary (e.g., key - value lookup collection) for each sample and the
    # files associated with it
    sample_dict = load_files() 
