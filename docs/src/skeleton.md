#  Example task, JSON config and workflow

**Last update**: 20261113-1



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

Copy to your current working directory "workDir" (see the previous section) the example JSON config file ```config-3.json``` from this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/skeleton/config-3.json). The config file is indexed with "-3", to indicate that as the O2 framework is still regularly evolving, you will need to maintain in parallel different version of JSON config file, for different versions of O2Physics used in the analysis. 

```JSON title="File: src/skeleton/config-3.json"
--8<-- "src/skeleton/config-3.json"
```

By using this JSON file, one can for instance specify the path to the local "AO2D.root" file which will be processed, whether or not a task which was added to the workflow shall process real data or Monte Carlo, which histograms should be booked or cuts applies in the user's task "student-o2-physics", etc. 

In the above JSON config file ```config-3.json```  only the essential configurable options of each task which was added to the workflow is kept. One can obtain all configurable options for each task added to the workflow from automatically generated file ```dpl-config.json``` which is automatically dumped by the O2 framework in the directory in which the framework is executed (see next section).

If the configurable used in the JSON config is not supported by the corresponding task, it will be silently ignored by the framework. Since JSON format does not support comments, in what follows below we utilize the following convention in the JSON config:

```JSON
...
"some-supported-configurable": "first setting",
"__some-supported-configurable": "second setting",
...
```

In the above example, in the 2nd line we have appended ```__``` (two consecutive underscores) to the existing configurable named ```some-supported-configurable```. Since ```__some-supported-configurable``` does not exist, it's silently ignored, i.e. it acts in the same way as this whole line was commented out.  This way, by prepending or removing ```__``` to the name of configurable variable in the JSON config file, one can effectively comment in or comment out a specific setting for a given configurable.

To leading order, one needs to modify regularly in the JSON config file ```config-3.json``` only the following configurable fields:

1. ```"aod-file-private"``` &mdash; this configurable specifies the local path to a ```AO2D.root``` file which will be processed. It's currently set to the local path ``` /home/abilandz/scratch/O2/Datasets/Run_3/2023/LHC23zzh/544116/apass5/0140/o2_ctf_run00544116_orbit0034437888_tf0000000601_epn103/008/AO2D.root```", which you need to adapt to your local computer. This specific "AOD2.root" file can be copied from AliEn catalog locally in the current working directory, by executing in the terminal where O2 environment is already enabled (e.g. using the ```MenuO2``` utility function):

    ```bash
    $ alien_cp /alice/data/2023/LHC23zzh/544116/apass5/0140/o2_ctf_run00544116_orbit0034437888_tf0000000601_epn103/008/AO2D.root file:.
    ```

	The subdirectory path within the local directory ```/home/abilandz/scratch/O2/Datasets/Run_3/2023``` is kept intentional as the subdirectory path within the top-level AliEn directory for 2023 real data ```/alice/data/2023``` , so that it can easily be traced back where the local file ```AO2D.root``` originated from. In the above **alien_cp** command, instead of copying ```AO2D.root``` file to current working directory, one can copy that file into some other directory, simply by replacing at the end ```file:.``` with ```file:path-to-some-other-directory``` &mdash; this is the standard syntax. 

	Analogously, for Monte Carlo data which was anchored to the above real data (meaning that detector conditions were the same both in Monte Carlo production and in real data), one can for instance use Monte Carlo production ```LHC25f3_gp``` (the general-purpose Pythia 8 production anchored specifically to LHC23zzh, reconstruction pass5). One example file of that Monte Carlo production in the AliEn catalog is:
	```bash
	/alice/sim/2025/LHC25f3_gp/0/544116/AOD/044/AO2D.root
	```
	It can be copied locally in the same way using **alien_cp** command. 

2. In the JSON config, one can maintain the both fields in the following way. When running over real data, one sets (adapt ```/home/abilandz/scratch/O2/Datasets/Run_3``` to to your personal local path):
	```bash
	"aod-file-private": "/home/abilandz/scratch/O2/Datasets/Run_3/2023/LHC23zzh/544116/apass5/0140/o2_ctf_run00544116_orbit0034437888_tf0000000601_epn103/008/AO2D.root",
	"__aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2025/LHC25f3_gp/0/544116/AOD/044/AO2D.root"
	```
	and when running over Monte Carlo, one simply swaps:
	```bash
	"__aod-file-private": "/home/abilandz/scratch/O2/Datasets/Run_3/2023/LHC23zzh/544116/apass5/0140/o2_ctf_run00544116_orbit0034437888_tf0000000601_epn103/008/AO2D.root",
	"aod-file-private": "/scratch3/abilandz/O2/Datasets/Run_3/2025/LHC25f3_gp/0/544116/AOD/044/AO2D.root"
	```
	Note the standard trick: When I prepend ```__``` to the name of configurable variable in the JSON config  this variable is not recognized, and then the whole field acts merely as commented-out code.

3. In the same spirit, one swaps for "event-selection-service" task settings in JSON config the following configurables, whether running either over real data or over Monte Carlo:
	```bash
	 "isMC": "false"
	```
	into 
	```bash
	"isMC": "true"
	```

4. For "propagationservice" settings in JSON config, one needs to swap:
	```bash
	"processRealData": "true",
	"processMonteCarlo": "false",
	```
	into 
	```bash
	"processRealData": "false",
	"processMonteCarlo": "true",
	```
5. For "multcenttable":
	```bash
	"processMonteCarlo": "false",
	"processMonteCarlo2Mults": "false"
	```
	into
	```bash
	"processMonteCarlo": "true",
	"processMonteCarlo2Mults": "true"
	```
6. For your example task "student-o2-physics" in the JSON config, if you want to process in Monte Carlo only the reconstructed information, no changes is needed (i.e. you can leave the very same settings as when you are processing real data). However, if you want to process both reconstructed + simulated, you need to change:
	```bash
	"processRec": "true",
	"processRecSim": "false",
	```
	into 
	```bash
	"processRec": "false",
	"processRecSim": "true",
	```

With those changes in the JSON config file, the workflow remains the same whether you process real data or Monte Carlo data, and that workflow is detailed in the next section.


#### 3. Workflow

Copy to your current working directory "workDir" the example workflow script ```wf-3.sh``` from this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/skeleton/wf-3.sh), or copy from the code snippet below:

```Bash title="File: src/skeleton/wf-3.sh"
--8<-- "src/skeleton/wf-3.sh"
```

For each of the tasks added to the above workflow, namely **o2-analysis-event-selection-service**, **o2-analysis-propagationservice**, etc., when you execute the workflow, you will get for each task all configurables in the file "dpl-config.json". You can take some fields from this general config "dpl-config.json" into your personal JSON config ```config-3.json``` and change the default values, but do that really only if you fully understand what the effect of those changes is. 

The workflow is designed in such a way that each O2 executable is chained with another by using the standard pipe mechanism ```|``` . This is the standard mechanism in Unix-based systems how the output of one executable can become input for another.  

Finally, the workflow is simply executed as:
```bash
$ source wf-3.sh
```

