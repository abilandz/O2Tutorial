

# Local installation
**Last update**: 20261025-1



To install locally the O2 analysis software, the **Bash** shell utility function **InstallationO2** can be used. That function is implemented, alongside other O2 utility functions in this personalized [O2Tutorial](https://github.com/abilandz/O2Tutorial) repository, and the latest version of the code can be obtained directly by following this direct link [O2.sh](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/scripts/O2.sh). 

To use install locally O2, follow these steps:

* copy locally and source the file "O2.sh" 

  ```bash
  $ source O2.sh
  ```

  After this step, shell utility functions **InstallationO2**, **MenuO2**, etc., are in a computer's memory, and can be used like any other Linux or shell command.

+ print the example use cases of **InstallationO2**

  ```bash
  $ InstallationO2 -h
  Example use cases:
   # Example 1: InstallationO2 master # compiles package O2Physics@master in default top level build directory
  
   # Example 2: InstallationO2 nightly-20220630 # compiles package O2Physics@nightly-20220630 in default top level build directory
  
   # Example 3: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2 master 
                # Compiles package O2Physics@master in user specified top level build directory,
                # using default value hardwired for each machine for number of jobs (e.g. 16 for 'anteb', 8 for 'napalm', 12 for 'nx*' etc.) 
  
   # Example 4: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2_nJobs=12; InstallationO2 master 
                # Compiles package O2Physics@master in user specified top level build directory, using 12 nJobs as an argument to -j flag of aliBuild. 
  
   # Example 5: InstallationO2_TopLevelBuildDir=$HOME/scratch/aliceO2-1; InstallationO2_Compile=false; InstallationO2 master 
                # Only checks out package O2Physics@master in user specified top level build directory, i.e. compilation is NOT performed
  ```

  



a) Initialize locally the O2 environment using shell function **MenuO2**



1/ We ported two functions to your account, **InstallationO2** and **MenuO2**, and started from scratch your first local O2 compilation on /scratch disk area. Once the compilation finishes, please try to open a new terminal on 'nidoqueen', or a new window in the existing screen session (in both cases you get a new shell instance with a clean environment!), and use the **MenuO2** function to enable the O2 environment in that new and clean shell. If **MenuO2** succeeded, remember that you still have to type 

```bash
$ bash
```


in the terminal, to finalize environment initialization.


2/ Remember to keep in sync all default values for relevant variables (e.g. top-level directory for O2 compilation) in both InstallationO2 and MenuO2.

3/ There is another presentation from the latest O2 tutorial in November 2025: https://indico.cern.ch/event/1574136/timetable/ you can consult now (in case you do not have access, I have uploaded this 2nd presentation by David at the same public link ). Please have a look at the first 10 slides, and try to execute the tutorial executable (which shall be ready to use in your environment if compilation went through, and O2 environment is correctly initialized e.g. with MenuO2 function) to:
 a) process one example AOD2.root file. It's explained on the slides from David how to download it from his Dropbox - if his link expired, please try to process this local file: 
        /scratch3/abilandz/O2/Datasets/Run_3/2023/LHC23zzh/544122/apass3/0440/o2_ctf_run00544122_orbit0160006240_tf0000749850_epn059/003/AO2D.root
 b) as an output of this processing, try to produce a ROOT file automatically, holding a histogram with example eta distribution. Please send me that eta distribution by email! 

