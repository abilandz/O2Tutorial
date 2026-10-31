#  Example task, JSON config and workflow

**Last update**: 20261031-1



In this part of O2 tutorial, the example skeleton analysis task is introduced, alongside its JSON configuration file (_config_ for short), and the workflow in which it can be used. This example is sufficient to process the O2 AO2D.root files locally, which were obtained both from real reconstructed data, and from reconstructed simulated Monte Carlo productions. In the latter case, reconstructed and simulated information can be processed separately.

This part of tutorial offers a starting working template for the analsyis in O2, on top of which later you can further develop your own analysis taks, workflow, etc., by adding more functionalities and features.

The provided example task, JSON config and workflow were tested for:

* O2Physics "master" dated Mon Oct 19 2026, and compiled locally;
* real reconstructed data "AO2D.root" files from the latest apass5 reconstruction of LHC23zzh dataset (Pb-Pb collisions from 2023 run);
* simulated reconstructed data "AO2D.root" files from Monte Carlo production LHC25f3_gp which was _anchored_ on the above real dataset (i.e. it was simulated using the same detector conditions &mdash; this connection between real data and Monte Carlo is mandatory to obtain reliable efficiency corrections).

If this tutorial is executed successfully, the example analysis task will produced an output file of analysis named "AnalysisResults.root", where all histograms and other objects booked in this example task are automatically saved. 



#### 1. Analysis task skeleton

The latest version of the analysis task skeleton code is available in the file named "student-o2physics.cxx" and can be obtained directly from the personalized [O2Tutorial](https://github.com/abilandz/O2Tutorial) repository, by following this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/cpp/student-o2physics.cxx). The analysis task is designed and organized schematically as:

```bash
# Preamble
## Licencing information
## Include headers
## Namespaces
## Joint tables
## Enums

# The main task
## Task definition
## Definition of base TList to hold all output objects
## Configurables
## Data members
## Local member functions
## mandatory function init() 
## mandatory process functions and related process switches

# The final technical details
```

In the above analysis structure, we highlight the following:

1. mandatory **function init()** &mdash; before data processing starts, the framework will call automatically this function. Whatever is implemented in that function, will be executed automatically (typically, one books all analysis objects in this function). The framework does not care about the details of internal implementation of **function init()**, it only requests that such function exists, and that function will be called;
2. mandatory process functions and related process switches &mdash; one can implement one or more _process_ functions and corresponding process switches. Settings of process switches determines which process function will be executed during data processing. Framework automatically calls a specified process function for each collision which is processed, and whatever is implemented in that process function, will be executed for that collision, during data processing;
3. histograms are filled and saved in the output file "AnalysisResults.root", and it is illustrated with nesting of TLists how the structure of that output file can be organized to resemble directory/subdirectory hierarchy. 

To be able to use the above example analysis task "student-o2physics.cxx", one needs to include that task in the O2Physics code base, and then re-compile. For that, the following steps need to be followed:

1. adapt all file paths below whenever necessary, e.g. in 2.) you need to replace ```~/scratch/aliceO2-1``` with what corresponds to your local build directory of O2 (this step you accomplished in TBI 20261026 add link to the section);

2. copy the class "student-o2physics.cxx" (fetch the latest version from this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/skeleton/student-o2physics.cxx)) into subdirectory ```~/scratch/aliceO2-1/O2Physics/PWGCF/MultiparticleCorrelations/Tasks```;

3. in that subdirectory, there is a **cmake** configuration file "CMakeLists.txt". Append the following lines at the end of that file:

    ```cmake
    o2physics_add_dpl_workflow(student-o2physics
                        SOURCES student-o2physics.cxx
                        PUBLIC_LINK_LIBRARIES O2::Framework O2Physics::AnalysisCore O2Physics::PWGCFCore
                        COMPONENT_NAME Analysis)
    ```

4. compile centrally this newly added task (for all later compilations, use **ninja** in the next step, to compile differentially only changes in the module PWG-CF, where your code sits);

    ```bash
    $ cd ~/scratch/aliceO2-1
    $ aliBuild build O2Physics -j 4 --defaults o2 --debug | tee build.log
    ```

    If the above compilation fails due to large memory consumption, restart the above procedure by using smaller number of CPUs (e.g. use ```-j 3``` instead of ```-j 4```, and so on);

5. if the above compilation succeeded, open a new terminal, and check if you can recompile differentially only PWG-CF module using **ninja**, to check if the newly added task is taken into account:

    ```bash
    $ cd ~/scratch/aliceO2-1
    $ alienv enter O2Physics/latest ninja/latest
    $ bash
    $ cd sw/BUILD/O2Physics-latest/O2Physics
    $ ninja install PWGCF/all | tee build.log
    ```

    The first time, the above **ninja** compilation should just go through. After that, introduce some trivial minor change in the class "student-o2physics.cxx", and re-execute the last line above. Since now you are only re-compiling differentially the PWG-CF module, the compilation shall take less than ~ 1 min. If the compilation fails, inspect the content of the "build.log" file. 

6. if the compilation went through, organize your working area for local O2 analysis in the following way:

	* keep one separate terminal always open only for **ninja** compilation;

	* in a new terminal, initialize the environment for O2Physics which you just compiled with **ninja** in a separate terminal (e.g. using the utility function **MenuO2**). In this terminal create some working directory (refering to it as "workDir" below), where you are going to run O2 analysis locally. Each time you introduce some change in the analysis code and recompile it with **ninja** in a separate terminal, in this new terminal automatically you will be using its latest version; 

	* copy and maintain in "workDir" the JSON configuration file and the workflow script, which are introduced in detail next.



#### 2. JSON configuration file

In this section the JSON configuration file is introduced. As its name suggests, this file is used to set and adjusts all configurables options of user's analysis task "student-o2physics.cxx", as well as of other tasks which are added to the analysis workflow (the script which defines the analysis workflow is introduced in the next section). 

Copy to your current working directory "workDir" the example JSON config file ```config-2.json``` from this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/skeleton/config-2.json). The config file is indexed with "-2", to indicate that as the O2 framework is evolving, you will need to maintain in parallel different version of JSON config, for different versions of O2Physics used in the analysis. 

```JSON title="File: src/skeleton/config-2.json"
--8<-- "src/skeleton/config-2.json"
```

By using this JSON file, one can for instance speficy the path to the local "AO2D.root" file which will be processed, whether or not some task which was added to the workflow shall process real data or Monte Carlo, which histograms should be booked or cuts applies in the user's task "student-o2-physics", etc. 




TBC 20261031 -- ctd. with  material from below on how to copy files from AliEn, etc.





#### 3. Workflow



Copy to your current working directory "workDir" the example workflow script ```wf-2.sh``` from this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/skeleton/wf-2.sh).







 






Copy from AliEn (in case you are still not an officially member of the ALICE Collaboration and do not have access rights to AliEn, I executed this step) locally two recent AO2D.root file, e.g. this one for real data, which is indicated in .json config:

​     "aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2023/LHC23zzh/544122/apass3/0440/o2_ctf_run00544122_orbit0160006240_tf0000749850_epn059/003/AO2D.root",

In AliEn, its path shall be /alice/data/2023/LHC23zzh/544122/apass3/0440/o2_ctf_run00544122_orbit0160006240_tf0000749850_epn059/003/AO2D.root

I copied this file to /scratch3 , so you should be able to access and process it. 

And analogously, this one for Monte Carlo anchored to real data:

​    "aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2024/LHC24g3/0/544122/AOD/001/AO2D.root"

In AliEn, its path shall be /alice/sim/2024/LHC24g3/0/544122/AOD/001/AO2D.root

In case you decide to copy over these two files to your personal directory, do not forget to adapt the path in "aod-file-private" field in JSON config.

The default settings in the JSON config correspond to analysis of reconstructed real data, "Rec" mode, just execute: source wf-2.sh

IMPORTANT: This workflow will work only if you are a member of the ALICE Collaboration and have access to AliEn, CCDB, etc. 

If you want to process Monte Carlo data, only reconstructed (mode "Rec") or reconstructed + simulated information (mode "RecSim"), then in the JSON config you have to:

a) Change 

​    "aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2023/LHC23zzh/544122/apass3/0440/o2_ctf_run00544122_orbit0160006240_tf0000749850_epn059/003/AO2D.root",
​    "__aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2024/LHC24g3/0/544122/AOD/001/AO2D.root"

into 

​    "__aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2023/LHC23zzh/544122/apass3/0440/o2_ctf_run00544122_orbit0160006240_tf0000749850_epn059/003/AO2D.root",
​    "aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2024/LHC24g3/0/544122/AOD/001/AO2D.root"

Note the standard trick: When I prepend __ to the name, this variable is not recognized, and then the whole field acts merely as commented-out code.

b) For "eventselection-run3" task settings in JSON config, please change:

 "isMC": "false"

into 

 "isMC": "true"

c) For "propagation-service" settings in JSON config, please change: 

​    "processRealData": "true",
​    "processMonteCarlo": "false",

into 

​    "processRealData": "false",
​    "processMonteCarlo": "true",

d) For "mult-cent-table" :

​    "processMonteCarlo": "false",
​    "processMonteCarlo2Mults": "false"

into

​    "processMonteCarlo": "true",
​    "processMonteCarlo2Mults": "true"

e) For your task "student-o2-physics" in the JSON config, if you want to process in Monte Carlo only reconstructed information, no changes is needed, if you want to process both reconstructed + simulated, please change:

​    "processRec": "true",
​    "processRecSim": "false",

into 

​    "processRec": "false",
​    "processRecSim": "true",

And that's it! The workflow remains the same, whether you process real data or Monte Carlo, so just execute source wf-2.sh

And check whether the pT histogram, both for reconstructed and simulated particles, is filled. 

6/ For all tasks added to the workflow, when you execute the workflow, you will get for each task all configurables in the file "dpl-config.json" . You can take some fields from this config into your personal JSON config and change the default values, but do that really only if you fully understand what the effect of those changes is. 

