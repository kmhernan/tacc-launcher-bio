tacc-launcher-bio
=================

Using the TACC launcher to run bioinformatic pipelines

A. Stampede directory structure

```
home - Where you are when you log into Stampede. Contains the bash profile hidden file and others.
      I highly recommend that you create a bin/ directory here to store all the applications you wish
      to install. Do NOT store data here.
   
work - 400GB. You can save data here and it won't be automatically purged.

scratch - More or less unlimited storage, but it is purged. I always in scratch, but it's up to you. I always
         move raw files to corral.
             
corral - Juenger space: /corral-repl/utexas/hallii_expression; We have several TB of space and I store all raw 
            files here.
```
   
B. Getting data from forseq to Stampede
  
```bash
rsync --progress -r Project_JA12345 username@stampede.tacc.utexas.edu:/path/to/directory/
```
*this often fails, and you will need to `CTRL-C` and re-run with:*

```bash
rsync --progress --ignore-existing -r Project_JA12345 username@stampede.tacc.utexas.edu:/path/to/directory/
```

*if your data is on Corral, you will basically have to `cp` it from the directory over to where you want it.*

C.  Setting aliases and path

There are several built in aliases/paths to get around Stampede.
`cds` - go to scratch
`cdw` - go to work
`cd`  - go to home
`$HOME` - the home path
`$SCRATCH` - the scratch path
  
However, you will likely want to add more aliases and paths
  1. Create the hidden file `.profile_user` using your editor of choice
  2. Set aliases using `alias whatever='command -flag'` where `whatever` is the alias for the command `command -flag`
  3. Set paths using `export PATH=$PATH:/path/to/dir` *notice that I don't have a trailing `/` after dir*
  4. Set named path variable using `export MYPATH=/the/path/to/dir; export PATH=${PATH}:${MYPATH}`

Here is an example `.bash_profile` file:
```bash
###############################################################################
#          Environmental Variables for Kyle Hernandez                         #
#          Stampede                                                           #
###############################################################################
# Aliases
alias shu='showq -u'

# blast path 
export PATH=$PATH:/home1/01832/kmhernan/bin/ncbi-blast-2.2.27+/bin
# taccNGS path
export PATH=$PATH:/home1/01832/kmhernan/bin/taccNGS/taccNGS_1_1_0
# scala path
export PATH=$PATH:/home1/01832/kmhernan/bin/scala-2.10.1/bin
# ExprScripts Path 
export PATH=$PATH:/home1/01832/kmhernan/bin/switchgrass-expression/utils
# GATK PATH
export GATK=/home1/01832/kmhernan/bin/GATK-2.5-2
# Samtools path
export SAM=/home1/01832/kmhernan/bin/samtools-0.1.18
# Corral path
export CORRAL=/corral-repl/utexas/hallii_expression
export PATH=${PATH}:${GATK}:${SAM}:${CORRAL}
```
