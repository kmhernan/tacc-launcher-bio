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

    # loop over every file in the directory 'indir' that ends with  '.sam'
    for fil in glob.glob(indir + "/*.sam"):
        # get the basename of the file, just like $(basename $fil) we did in bash
        base = os.path.basename(fil)
        # I want to split the filename at each '_', placing the strings into a list
        # If I split JOB_SAMPLE_BAR_LANE.sam by '_' the resulting list = 
        # ['JOB', 'SAMPLE', 'BAR', 'LANE.sam']
        # I want the sample name, which is index 1 (starts at 0)
        samp = base.split("_")[1]

        # if the sample is not in the dictionary, then we need to initialize 
        # the file list. For a dictionary 'dic' you can look up a key 'key' by
        # dic[key] and it will return the value.
        if samp not in dic:
            dic[samp] = []

        # Regardless of the sample existing in the dic or not, the script will
        # run this code which appends the full file path to the list for that sample.
        dic[samp].append(fil)

    # When you are here, you have looped over all files in the directory
    # and built the dictionary
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
    # sys.argv list is the scriptname, if we expect the user to provide 4 command-line arguments
    # as in this case, we need to make sure the length of the sys.argv list is 5.
    if len(sys.argv) != 5:
        # If the length of the sys.argv list is NOT equal to 4, then we print out the usage statement
        # and exit the program with exit status 1, since it is an error.
        print "Usage: make-merge.py <in/dir/> <out/dir/> <out.param> <path/to/log/dir/>"
        sys.exit(1)
   
    # If we are here, then the user has provided the correct number of arguments.
    # So, we can declare our global variable by accessing the values of the sys.argv
    # list by index number using the '[]' brackets. I like to use the os.path.abspath()
    # function to make sure all the paths are the same. They all will end in either the
    # name or the directory (i.e., path /this/is/a/path/ will be read as /this/is/a/path 
    # without the trailing '/'
    indir = os.path.abspath(sys.argv[1])
    odir  = os.path.abspath(sys.argv[2])
    param = os.path.abspath(sys.argv[3])
    olog  = os.path.abspath(sys.argv[4])

    # Now we need to build a dictionary (e.g., key - value lookup collection) for each sample 
    # and the files associated with it
    sample_dict = load_files()

    # Now we have a dictionary where the key is the sample name and value is a list of the
    # files associated with that sample (at least one). We want to loop through the dictionary
    # and write the parameter file now.

    # First, we need to open an output stream to the parameter file which we delcared
    # as 'param'. The syntax is simply open(file, 'wb'), where file is the path to the 
    # output file and 'wb' is the type of stream we want to open, w = write, b = binary. 
    # We will create the variable 'o' which will represent the output stream. REMEMBER TO CLOSE 
    o = open(param, 'wb')
    
    # Looping over a dictionary is simple
    for sample in sample_dict:
        # Each iteration of the for loop, sample will be a key (in our case sampleids)
        # We first want to create the name of the output file. We will use the nifty
        # os.path.join() function which will join a directory path with a file and you 
        # don't have to worry about forgetting the '/'. The actual filename will be
        # sample.sam.
        ofil = os.path.join(odir, sample + ".sam")
       
        # Also make the log file (only matters for cases with more than one file)
        logfil = os.path.join(olog, sample + ".log")
 
        # Now let's pull out the list for the current sample into its own variable we will
        # call 'curr' as in 'current'.
        curr = sample_dict[sample]

        # Now we need to see if there are multiple files for this sample, and perform
        # different actions if there are.
        if len(curr) > 1:
            # There are multiple samples (i.e., the file list for this sample contains
            # more than one file). So, we need to use the Picard MergeSamFiles.jar
            # First, we need to join all the files together into a string that is formatted
            # correctly for MergeSamFiles.jar which requires each sam file to have an 
            # 'INPUT=' in front of it.
            fout = " INPUT=".join(curr)
             
	    # Now we write the command to the parameter file. The '\' are required when you
            # want to wrap a single line of code across multiple lines for good coding practice.
            # Do make note that I added a space before 'OUTPUT=' and before 'SORT_ORDER='. Also,
            # you need to add the end of line marker '\n'
            o.write('java -Xms1G -Xmx2G -jar MergeSamFiles.jar' + fout + \
                    ' OUTPUT=' + ofil + \
                    ' SORT_ORDER=coordinate ASSUME_SORTED=true > ' + \
                    logfil + '\n')
	# These cases are where there are not multiple files to be merged for a sample.
        # For these cases I simply copy (cp) the files to the output directory using the
        # sample id naming convention I like. 
        else:
            # Grab the input file from the list, which is only of size 1. So, the file path
            # is in curr[0]
            o.write('cp ' + curr[0] + ' ' + ofil + '\n')

    # Now we are done, but we need to close the output stream
    o.close()
