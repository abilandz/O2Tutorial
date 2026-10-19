

# Installation
**Last update**: 20261008-1

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

