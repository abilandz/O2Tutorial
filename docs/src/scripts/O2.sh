#!/bin/bash

# Library of shell functions to perform various tasks related to the local O2 analysis.

#############################################################
# List of functions (order of their implementation matters!):

# Green            : Print in green 
# Red              : Print in red
# Yellow           : Print in yellow
# Blue             : Print in blue
# Date             : Simple reformat of standard 'date'
# InstallationO2   : Use this function to compile O2 software from scratch, using aliBuild
# MenuO2           : Use to initialize the environment of local O2 installation
# UploadFileToCCDB : This function is a wrapper to O2 executable o2-ccdb-upload, used to upload a file to CCDB

#############################################################

function Green
{
 # Write the specified text in green.

 [[ $# -eq 0 ]] && return 1
 echo -e "\E[1;32;48m$*"; tput sgr0  

 return 0;

} # function Green

##########################################

function Red
{
 # Write the specified text in red.

 [[ $# -eq 0 ]] && return 1
 echo -e "\E[1;31;48m$*"; tput sgr0  

 return 0;

} # function Red

##########################################

function Yellow
{
 # Write the specified text in yellow.

 [[ $# -eq 0 ]] && return 1
 echo -e "\E[1;33;48m$*"; tput sgr0  

 return 0;

} # function Yellow

##########################################

function Blue
{
 # Write the specified text in blue.

 [[ $# -eq 0 ]] && return 1
 echo -e "\E[1;36;48m$*"; tput sgr0  

 return 0;

} # function Blue

##########################################

function Date
{
 # Last update: 20261019
 
 # Reformat the printout of 'date', and try to make it uniform across different environments.

 case $HOSTNAME in
  lxi*|lxbk*|ccsub*)
    # These are the machines at GSI, where i have the following formatting of 'date': Mon Oct 19 07:50:00 CEST 2026
    date | awk '{ print $3 ".",$2,$4 }'
  ;; 
  nido*)
    # These are login machines at TUM, where i have the following formatting of 'date': Mon Oct 19 07:51:06 AM CEST 2026
    date | awk '{ print $3 ".",$2,$4 }'
  ;; 
  *)
    # Default formatting of 'date' on my computer: Mo 23. Jan 06:14:42 CET 2023
    date | awk '{ print $2,$3,$4 }'
  ;;  
 esac

 return 0;

} # function Date

##########################################

function InstallationO2
{
 # Last update: 20261019

 # Use this function to compile O2 software from scratch, using aliBuild.
 # If variable InstallationO2_TopLevelBuildDir is set before calling the function, local var TopLevelBuildDir is initialized with that value. 
 # If variable InstallationO2_Compile is set before calling the function, local var Compile is initialized with that value. 
 # If Compile=false, then I only check out, without compiling. 
 # Otherwise, hardcoded values below are used.

 # To do:
 ## ...

 # Example use cases: InstallationO2 -h # this will print several example use cases on the screen

 # Scripting flow:
 ## a) Support for flag -h => here just print example use cases (no configs!);
 ## b) Local environment variables;
 ## c) Insanity checks;
 ## d) Check what is already available locally;
 ## e) Initializing;
 ## f) Check your prerequisites and install what is missing;
 ## g) Finally, starting the compilation;
 ## h) Final message.


 ## a) Support for flag -h => here just print example use cases (no configs!):
 case $1 in 
  '-h')
     # Print example use cases:

     echo "Example use cases:"

cat << 'here-doc'
 # Example 1: InstallationO2 master # compiles package O2Physics@master in default top level build directory

 # Example 2: InstallationO2 nightly-20220630 # compiles package O2Physics@nightly-20220630 in default top level build directory

 # Example 3: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2 master 
              # Compiles package O2Physics@master in user specified top level build directory,
              # using default value hardwired for each machine for number of jobs (e.g. 16 for 'anteb', 8 for 'napalm', 12 for 'nx*' etc.) 

 # Example 4: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2_nJobs=12; InstallationO2 master 
              # Compiles package O2Physics@master in user specified top level build directory, using 12 nJobs as an argument to -j flag of aliBuild. 

 # Example 5: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2_Compile=false; InstallationO2 master 
              # Only checks out package O2Physics@master in user specified top level build directory, i.e. compilation is NOT performed
here-doc

     return 0 
    ;; # '-h'  
 esac


 # b) Local environment variables:
 local TopLevelBuildDir
 if [[ -n $InstallationO2_TopLevelBuildDir ]]; then
  # 1. if user has defined before calling this function variable InstallationO2_TopLevelBuildDir, use its content to initialize TopLevelBuildDir:
  TopLevelBuildDir=$InstallationO2_TopLevelBuildDir
 else
  # 2. use default value hardwired here to initialize TopLevelBuildDir:
  TopLevelBuildDir=$HOME/aliceO2-9
 fi

 local Compile
 if [[ -n $InstallationO2_Compile ]]; then
  # 1. if user has defined before calling this function variable InstallationO2_Compile, use its content to initialize Compile:
  Compile=$InstallationO2_Compile
 else
  # 2. use default value hardwired here to initialize Compile:
  Compile=true # so by default, I am both checking out AND compiling
 fi

 local nJobs

 if [[ -n $nJobs ]]; then
  # 1. if user has defined before calling this function variable InstallationO2_nJobs, use its content to initialize nJobs:
  nJobs=$InstallationO2_nJobs
 else
  # 2. use default value hardwired here to initialize nJobs, specific to some known host names:
  case ${HOSTNAME} in  
    "napalm") nJobs=4 ;;
     "anteb") nJobs=16 ;;
       nido*) nJobs=12 ;; # machines after upgrade, "nidoking" or "nidoqueen"
         nx*) nJobs=12 ;; # I use here regex, because HOSTNAME is set to e.g. "nx1.ktas.ph.tum.de" in this case
           *) nJobs=4 ;; # default value if HOSTNAME is not rexognized
  esac           
 fi
 

 # c) Insanity checks:
 ## c1) aliBuild:
 which aliBuild &>/dev/null || { Red "\n aliBuild is not installed. Please do that step first. \n"; return 1; }
 local AliBuildVersion=$(awk '{print $3}' <<< $(aliBuild version))
 [[ -z $AliBuildVersion ]] && { Red "\n AliBuildVersion is NULL. \n"; return 1; }
 Yellow "\n=> O2 software will be installed using aliBuild version $AliBuildVersion .... $(Date)"; sleep 1

 ## c2) Configuration:
 [[ $nJobs -gt $(nproc) ]] && { Red "\n This machine has only $(nproc) CPUs. Trim down \"nJobs\" = $nJobs \n"; return 1; } 

 ## c3) PPs:
 [[ $# -eq 1 ]] || { Red "\n This script expects exactly 1 argument: \"master\" or some tag, e.g. \"nightly-20220630\"\n"; return 1; }
 local Tag=$1  
 if [[ $Tag != "master" ]]; then 
  # User didn't provide as PP1 a key word "master", then it must be a tag in the example format "nightly-20220630" or "daily-20220311-1046"
  # If more formats for tag names in the future are supported, add support for them in this branch.  
  grep -q "nightly\|daily" <<< $Tag || { Red "\n Tag name, when it's not \"master\", must contain either \"nightly\" or \"daily\" \n"; return 1; }
  local Stamp=$(awk 'BEGIN{FS="-"}{print $2}' <<< $Tag) # exctracting e.g. "20220630" from "nightly-20220630" or "daily-20220630-1046"
  [[ 8 -eq ${#Stamp} ]] || { Red "\n Wrong format for time stamp in tag name: Stamp = $Stamp do not have 8 digits (correct format: \"YYYYMMDD\") \n"; return 1; }
  # grep -q "^202" <<< $Stamp || { Red "\n Wrong format for time stamp in tag name: Stamp = $Stamp do not beging with \"202\" (correct format: \"YYYYMMDD\") \n"; return 1; }
 fi # if [[ $Tag != "master" ]]; then
 Yellow "\n=> Compiling package O2Physics@$Tag .... $(Date)"; sleep 1


 # d) Check what is already available locally:
 Yellow "\n=> Checking if TopLevelBuildDir = $TopLevelBuildDir already exists .... $(Date)"
 if [[ -d $TopLevelBuildDir ]]; then
  Green "   TopLevelBuildDir = $TopLevelBuildDir already exists!\n   Its content:"
  ls $TopLevelBuildDir; sleep 1
  if ls $TopLevelBuildDir/$Tag &>/dev/null; then
   Red "\n   Directory $TopLevelBuildDir/$Tag already exists.\n   Most likely, you checked out already this tag or master?\n   Delete this directory, and restart this script.\n"; return 1;
  fi   
 else
  echo "   Checked, it doesn't exist! .... $(Date)"
  mkdir -p $TopLevelBuildDir && echo "   Made now brand new directory $TopLevelBuildDir .... $(Date)" || { Red "\n Failed: mkdir -p $TopLevelBuildDir\n"; return 1; }
 fi # if [[ -d $TopLevelBuildDir ]]; then


 # e) Initializing:
 Yellow "\n=> Downloading and initializing the specified O2 software .... $(Date)"
 cd $TopLevelBuildDir # yes, cd first in top-level build dir
 case $AliBuildVersion in 
  # I use the case statement here, leaving a room open that for some other aliBuild version, default options might be set the other way
  "v1.11.3"|"1.16.1"|"1.17.1"|"1.17.11"|"1.17.12"|"1.17.18")
    aliBuild init O2@dev --defaults o2 
    aliBuild init O2Physics@${Tag} --defaults o2 
  ;;
  *)
    Red "\n Version $AliBuildVersion of aliBuild is still not supported here (case statement for \"init\" stage)\n"; return 1; 
  ;; 
 esac
 Green "   Done! .... $(Date)" 


 # f) Check your prerequisites and install what is missing:
 Yellow "\n=> You can now check your prerequisites and install what is missing with: aliDoctor O2Physics --defaults o2 .... $(Date)"; sleep 4
 Green "   OK, continuing, taking for granted that all prerequisites are already installed."


 # g) Finally, starting the compilation:
 Yellow "\n=> Finally, starting the compilation (using $nJobs CPU cores) .... $(Date)"

 if ! $Compile; then 
  Green "\n   Well, per explicit request (InstallationO2_Compile was set to \"false\"), compilation is NOT performed, only the new code was checked out.\n" 
  return 0
 fi

 echo -e "   Build log: $TopLevelBuildDir/build-${Tag}.log\n"; sleep 4
 local Started=$(Date)
 case $AliBuildVersion in 
  # I use the case statement here, leaving a room open that for some other aliBuild version, default options might be set the other way
  "v1.11.3"|"1.16.1"|"1.17.1"|"1.17.11"|"1.17.12"|"1.17.18")
    # To build without some specific package, use a flag e.g. --disable DPMJET,GEANT4
    aliBuild build O2Physics -j $nJobs --defaults o2 --debug 2>&1 | tee $TopLevelBuildDir/build-${Tag}.log
  ;;
  *)
    Red "\n Version $AliBuildVersion of aliBuild is still not supported here (case statement for \"build\" stage)\n"; return 1; 
  ;; 
 esac


 # h) Final message:
 Green "\nStarted:  $Started"
 Green "Finished: $(Date)\n"


 return 0


 # Upon succesful compilation, you shall get a message like this in the terminal: 
: <<'here-doc'

Build of O2Physics successfully completed on `anteb'.
Your software installation is at:

  /home/abilandz/aliceO2-4/sw/ubuntu2004_x86-64

You can use this package by loading the environment:

  alienv enter O2Physics/latest-master-o2
Build directory for devel package O2:
/home/abilandz/aliceO2-4/sw/BUILD/O2-latest-master/O2
Build directory for devel package O2Physics:
/home/abilandz/aliceO2-4/sw/BUILD/O2Physics-latest-master/O2Physics
2022-07-02@11:34:21:DEBUG:O2Physics:O2Physics:master: Everything done

here-doc

} # function InstallationO2

##########################################

function MenuO2
{
 # Last update: 20261019

 # Menu to select among several local O2 installations within the specified TopLevelBuildDir.
 # If variable MenuO2_TopLevelBuildDir is set in the environment before calling the function, 
 # the local var TopLevelBuildDir is initialized with that value.

 # Usage: MenuO2

 # Example 1: MenuO2 # show menu for local O2Physics installations, in the default TopLevelBuildDir
 # Example 2: MenuO2_TopLevelBuildDir=/scratch3/TEST/aliceO2-1; MenuO2 # show menu for local O2Physics installations,
 #                                                                       in the TopLevelBuildDir specified via MenuO2_TopLevelBuildDir

 # Scripting flow:
 ## a) Local environment variables;
 ## b) Insanity checks;
 ## c) Using 'alienv', determine the installed versions of O2Physics;
 ## d) Build up the final 'menu'.


 ## a) Local environment variables:
 local TopLevelBuildDir
 if [[ -n $MenuO2_TopLevelBuildDir ]]; then
  # 1. if user has defined before calling this function variable MenuO2_TopLevelBuildDir, use its content to initialize TopLevelBuildDir:
  TopLevelBuildDir=$MenuO2_TopLevelBuildDir
 else
  # 2. use default value hardcoded here to initialize TopLevelBuildDir:
  TopLevelBuildDir=/scratch3/TEST/aliceO2-1
 fi


 ## b) Insanity checks:
 ## a) alienv:
 which alienv &>/dev/null || { echo -e "\n alienv is not installed. Please install aliBuild \n"; return 1; }
 [[ -d $TopLevelBuildDir ]] && cd $TopLevelBuildDir || { echo -e "\n TopLevelBuildDir = $TopLevelBuildDir doesn't exist \n"; return 1; }


 ## c) Using 'alienv', determine the installed versions of O2Physics:
 ## Algorithm:
 # 1.) $ alienv q | grep 'VO_ALICE@O2Physics::latest-'
 # 2.) VO_ALICE@O2Physics::latest-master-o2
 # 3.) VO_ALICE@O2Physics::latest-nightly-20220630-o2
 # 4.) => Then, I use sed to remove patterns "VO_ALICE@O2Physics::latest-" and "-o2", respectively.

 local O2PhysicsVersions=( $( alienv q | grep 'VO_ALICE@O2Physics::latest-') )
 O2PhysicsVersions=( $(sed 's/VO_ALICE@O2Physics::latest-//g' <<< "${O2PhysicsVersions[*]}") )
 O2PhysicsVersions=( $(sed 's/-o2//g' <<< "${O2PhysicsVersions[*]}") )


 ## d) Build up the final 'menu':
 local PS3="=> Your choice? "
 clear
 echo -e "Avaliable O2Physics versions on \"$HOSTNAME\" in $TopLevelBuildDir :"
 local Version
 select Version in ${O2PhysicsVersions[*]}; do
  alienv enter O2Physics/latest-${Version}-o2
  break
 done


 return 0;

} # function MenuO2 

##########################################

function UploadFileToCCDB
{
 # Last update: 20261019

 # This function is a wrapper to O2 executable o2-ccdb-upload, used to upload a file to CCDB. 
 # Source code of o2-ccdb-upload can be found in O2/CCDB/src/UploadTool.cxx.
 # Remember that:
 #  1) o2-ccdb-upload accepts timestamps as integers interpreted as miliseconds, not seconds!! 
 #  2) To cast timestamps in integers in seconds to ordinary human readable format, use:
 #      $ date -d @1732782495
 #      Do 28. Nov 09:28:15 CET 2024
 #  3) You can upload to CCDB only specially formatted ROOT files, which has one top-level object named "ccdb_object" inside
 #     (that object can be TObjArray, TList, etc., and it can contain all other objects)

 # To do: 
 ## 20241135 There is a bug, UploadFileToCCDB -p calls UploadFileToCCDB -h recursively, but the config file is not correctly printed.
 ##          Most likely has to do with what file descriptors are doing in recursive call, in this case for 'cat'

 # Usage: UploadFileToCCDB [-h] [-p] <path-to-config-file>

 # Example 1: Dump the config file, edit it, and then upload the file.
 ## UploadFileToCCDB -h # dump the default config file in PWD
 ## ... edit the config file at path-to-config-file ...
 ## UploadFileToCCDB <path-to-config-file>

 # Example 2: Print the current content of $AliEnDir corresponding to CCDB. This way, I can see how to name the next available dir in CCDB.
 ## UploadFileToCCDB -p
 
 # Scripting flow:
 ## a) Support for flag -h;
 ## b) Insanity checks;
 ## c) Local variables;
 ## d) Source the config file;
 ## e) Adjust user-supplied timestamps in the format which o2-ccdb-upload supports;
 ## f) Print the configuration;
 ## g) Finaly, use O2 executable with current configuration, and upload;
 ## h) Hasta la vista.


 local ConfigFile=${PWD}/${FUNCNAME}.config


 ## a) Support for flag -h:
 case $1 in 
  '-h')
     # Print default config file in $PWD:
     [[ -f $ConfigFile ]] && { Red "\n ConfigFile = $ConfigFile already exists, it will be overwritten with the new one."; sleep 1; }
     Yellow "\n=> Printing the example config file for function $FUNCNAME into: ${ConfigFile}"

# Config file, if not specified, variables are taken from the environment:
cat > $ConfigFile <<'here-doc'
# Path to the file which will be uploaded:
local File="/home/abilandz/scratch/O2/master/weights.root"

# Relative path to the top-level directory in CCDB where 
# file will be uploaded (relative to CCDB host below):
local RelativePath="Users/a/abilandz/test-1"

# CCDB host:
local Host_CCDB="alice-ccdb.cern.ch"

# Corresponding AliEn dir:
local AliEnDir_CCDB="/alice/data/CCDB/Users/a/abilandz"

# Key:
local Key="ccdb_object"

# Start timestamp of validity (set to -1 or to 0 for valid as of now):
local StartTimeStamp="-1"

# End timestamp of validity in days from start timestamp
# (set e.g. 7 for 7 days):
local EndTimeStamp="7"
here-doc

     Green "   Done.\n"
     return 0
    ;; # '-h'

  '-p')
     # Print the current content of $AliEnDir corresponding to CCDB. This way, I can see how to name the next available dir in CCDB:
     # Algorithm: If AliEnDir_CCDB is available in the enbironment, I take that one. 
     #            If not, I take it from default config content. 
     which alien.py 1>/dev/null || { Red "\n alien.py is not available => enable e.g. O2 env. before starting.\n" >&2; return 1; }
     if [[ -z $AliEnDir_CCDB ]]; then 
      # AliEnDir_CCDB is not available in the environment, I take it from default config. 
      UploadFileToCCDB -h
      source $ConfigFile || { Red "source $ConfigFile failed" >&2; return 1; }
      [[ -z $AliEnDir_CCDB ]] && { Red "AliEnDir_CCDB is not defined in config $ConfigFile" >&2; return 1; }     
      rm $ConfigFile # clean up, why not
     fi
      Yellow "\n=> Printing only the content of AliEnDir_CCDB = $AliEnDir_CCDB"
      Yellow "   If that is not the path you want, set in environment AliEnDir_CCDB to the new path, and start again.\n"
      alien.py ls $AliEnDir_CCDB || { Red "Failed: alien.py ls $AliEnDir_CCDB" >&2; return 1; }
      echo
      return 0 
    ;; # '-p'
 esac


 ## b) Insanity checks:
 which alien.py 1>/dev/null || { Red "\n alien.py is not available => enable e.g. O2 env. before starting.\n" >&2; return 1; }
 alien.py ls 1>/dev/null || { Red "\n \"alien.py ls\" failed => check your AliEn env.\n" >&2; return 1; }
 if [[ -n ${1} ]]; then
  ConfigFile=$1 # user supplied 1st argument as a config file
  [[ -f $ConfigFile ]] || { Red "ConfigFile = $ConfigFile doesn't exist" >&2; return 1; }
  [[ -s $ConfigFile ]] || { Red "ConfigFile = $ConfigFile is empty" >&2; return 1; }
 else
  Red "Provide a config file via the 1st argument" >&2; return 1;
 fi 
 which o2-ccdb-upload 1>/dev/null || { Red "\n O2 executable \"o2-ccdb-upload\" is not available in the environment => enable e.g. O2 env. before starting.\n" >&2; return 1; }



 ## c) Local variables:
 ## ...


 ## d) Source the config file:
 Yellow "\n=> Sourcing the config file .... $(Date)"
 Blue "   ConfigFile = $ConfigFile"
 source $ConfigFile
 [[ -f $File ]] || { Red "\n File = $File doesn't exist" >&2; return 1; }
 [[ -z $RelativePath ]] && { Red "RelativePath is not set" >&2; return 1; }
 [[ -z $Host_CCDB ]] && { Red "Host_CCDB is not set" >&2; return 1; }
 grep -q "^alice" <<< $Host_CCDB || { Red "Host_CCDB = $Host_CCDB doesn't begin with key word \"alice\", that's mandatory (I think)" >&2; return 1; }
 [[ -z $AliEnDir_CCDB ]] && { Red "AliEnDir_CCDB is not set" >&2; return 1; }

 ### Check quickly if dir specified with RelativePath already exists in CCDB, by looking at its corresponding path in AliEnDir_CCDB: 
 local CorrespondingDirPathInAliEn=${AliEnDir_CCDB}/$(basename $RelativePath)
 if alien.py ls $CorrespondingDirPathInAliEn &> /dev/null; then 
  Red "CorrespondingDirPathInAliEn = $CorrespondingDirPathInAliEn already exists. Change the basename in RelativePath = $RelativePath" >&2; return 1;
 fi
 
 [[ -z $Key ]] && { Red "Key is not set. Most likely, you just need to default it to \"ccdb_object\"" >&2; return 1; }
 [[ -z $StartTimeStamp ]] && { Red "StartTimeStamp is not set." >&2; return 1; }
 [[ $StartTimeStamp -ge -1 ]] || { Red "StartTimeStamp = $StartTimeStamp is not integer >= -1." >&2; return 1; }
 [[ -z $EndTimeStamp ]] && { Red "EndTimeStamp is not set." >&2; return 1; }
 [[ ${EndTimeStamp} -gt ${StartTimeStamp} ]] || { Red "EndTimeStamp = $EndTimeStamp is not strictly bigger than StartTimeStamp = $StartTimeStamp" >&2; return 1; }
 Green "   Done!"
 sleep 1


 ## e) Adjust user-supplied timestamps in the format which o2-ccdb-upload supports:
 ### Get current time in seconds from Unix epoch:
 local CurrentTime  
 CurrentTime=$(date +%s) || { Red "Failed: date %s" >&2; return 1; }

 local StartTimeStampAdjusted
 if [[ -1 -eq ${StartTimeStamp} ]] || [[ 0 -eq ${StartTimeStamp} ]]; then 
  StartTimeStampAdjusted=$CurrentTime
 else 
  ### Increase it by number of seconds per day multiplied with total number of days indicated with StartTimeStamp:
  StartTimeStampAdjusted=$(( CurrentTime + 86400*StartTimeStamp )) # use "date -d @time-in-seconds" to cast into human-readable format 
 fi
 
 local EndTimeStampAdjusted
 ### Start with offset of StartTimeStampAdjusted, increase it by number of seconds per day multiplied with total number of days indicated with EndTimeStamp:
 EndTimeStampAdjusted=$(( StartTimeStampAdjusted + 86400*EndTimeStamp )) # use "date -d @time-in-seconds" to cast into human-readable format 

 ### Finally, multiply by 1000, to get resolution in miliseconds:
 ((StartTimeStampAdjusted*=1000));
 ((EndTimeStampAdjusted*=1000));


 ## f) Print the configuration:
 Yellow "\n=> This is the top level configuration .... $(Date)"
 Blue "   File: ${File}"
 Blue "   RelativePath: ${RelativePath}"
 Blue "   Host_CCDB: ${Host_CCDB}"
 Blue "   AliEnDir_CCDB: ${AliEnDir_CCDB}"
 Blue "   Key: ${Key}"
 Blue "   StartTimeStamp: ${StartTimeStamp} => StartTimeStampAdjusted = $StartTimeStampAdjusted ms = $(date -d @$((StartTimeStampAdjusted/1000)))"
 Blue "   EndTimeStamp: ${EndTimeStamp} => EndTimeStampAdjusted = $EndTimeStampAdjusted ms = $(date -d @$((EndTimeStampAdjusted/1000)))"


 ## g) Finaly, use O2 executable with current configuration, and upload:
 Yellow "\n=> Finaly, uploading .... $(Date)"
 echo "   Executing: o2-ccdb-upload --host "$Host_CCDB" -f "$File" --path "$RelativePath" --key "$Key" --starttimestamp $StartTimeStampAdjusted --endtimestamp $EndTimeStampAdjusted"
 o2-ccdb-upload --host "$Host_CCDB" -f "$File" --path "$RelativePath" --key "$Key" --starttimestamp $StartTimeStampAdjusted --endtimestamp $EndTimeStampAdjusted || { Red "Failed." >&2; return 1; }
 # Remark: Always make sure that the above 2 lines correspond to each other
 Green "   Done! Timestemp is valid from ==> $(date -d @$((StartTimeStampAdjusted/1000))) <== all the way to ==> $(date -d @$((EndTimeStampAdjusted/1000))) <=="
 sleep 1


 ## h) Hasta la vista:
 return 0
 
} # function UploadFileToCCDB

##########################################
