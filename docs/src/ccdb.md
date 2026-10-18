

# Access to CCDB
**Last update**: 20261018-1



In this part of O2 tutorial, you will learn the technique for accessing a histogram (or some other ROOT object) at run-time in your analysis task in O2Physics from an external ROOT file, and saving that histogram in the output file of your analysis. Typically, this way you access a histogram with efficiency corrections from an external ROOT file, use information from it during analysis, and then save that histogram in the output file of your analysis. This last part is not a trivial duplication of histograms &mdash; it is important that you can easily trace back which efficiency corrections you have used in a given analysis, and that is easiest to achieve without additional bookkeeping if you save that histogram in the output of that analysis.

To master the technique, follow these steps below...


#### 1. Adding new data member in the analysis task.
Add among data members of your analysis task in O2Physics a new TH1F histogram, named **_histWeights_** (of course, you can generalize and rename later, we now focus only on technicalities).


#### 2. The structure of ROOT file with efficiency corrections.
Make locally a ROOT file, named "weights.root", which has the following internal structure (you can start developing and maintaining a dedicated ROOT macro/executable for this sake, to automate the whole procedure, as some aspects of this internal structure are mandatory):

```cpp
TList "ccdb_object"
  TList "000123456"
     histWithEfficiencyCorrections_1
     histWithEfficiencyCorrections_2 
     ... more histograms in TList named "000123456" ...
  TList "000654321"
     histWithEfficiencyCorrections_1 
     histWithEfficiencyCorrections_2 
     ... more histograms in TList named "000654321" ...
  ... more nested TLists within TList "ccdb_object" ...  
```

In the above example internal structure of ROOT file "weighs.root":

* **_TList "ccdb_object"_** is the top-level list which contains all other objects in this ROOT file "weights.root" &mdash; it has to be named exactly "ccdb_object";
* **_TList "000123456"_** is the example nested TList, which will contain all histograms with efficiency corrections for the particular run number "000123456" (the name of this TList is custom); 
* **_"histWithEfficiencyCorrections_1"_** is the first example histogram, with some specific efficiency corrections pertaining to run number "000123456" (e.g. phi-weights, the name of this histogram is custom);
* **_"histWithEfficiencyCorrections_2"_** is the second example histogram, with some other efficiency corrections pertaining to run number "000123456" (e.g. pt-weights, the name of this histogram is custom). 
* ... and so on!

It doesn't matter for the time being which content you will have in the above example histograms **_"histWithEfficiencyCorrections\_*"_** , what matters is that now you develop the code in your O2Physics analysis task, which will access, use in the analysis at run-time, and copy that histogram from an external ROOT file, into your data member **_histWeights_** , and then save it automatically in the output file "AnalysisResults.root" of your analysis, alongside of other booked objects in the analysis task. 


#### 3. New configurable.
Add a new configurable to your analysis code using the following code snippet:

```cpp
Configurable<std::string> cfFileWithWeights{"cfFileWithWeights", "/home/abilandz/DatasetsO2/weights.root", "path to external ROOT file which holds all particle weights"};
```

Then, in a JSON configuration file, you would need to have the corresponding new field when you are configuring your analysis task:

```json
 "cfFileWithWeights": "/home/abilandz/DatasetsO2/weights.root",
```

An external ROOT file "weights.root" can be in three different locations, and after this tutorial, you will master access to that external file for all three cases. An external ROOT file holding efficiency corrections can be:

1. on your local computer &mdash; just use an absolute or relative path to it in the above JSON field

2. in your home directory in CCDB ("Calibration and Conditions Database"). This is the default, and therefore most important, way to store efficiency corrections. For this case, prepend a file path in the above JSON field with a string "/alice-ccdb.cern.ch/"

3. in your home directory in AliEn. This works, but it is not allowed to use this approach later in a large-scale data analysis in Hyperloop. Therefore, use this only in a local analysis for testing purposes. For this case, prepend a file path in the above JSON field with a string "/alice/cern.ch/"

The main point behind the above convention in the JSON config of specifying the path of an external file is that now in the analysis code it will be automatically determined from that path whether that external file is on a local compute, in CCDB, or in AliEn. Correspondingly, different code needs to be used to access that file, and that is provided with the function **_TH1F* GetHistogramWithWeights(...)_**, which is introduced next


#### 4. function TH1F* GetHistogramWithWeights(...)
To fetch automatically in your analysis task in O2Physics a histogram with efficiency corrections from an external ROOT file, for any of the three cases of interest mentioned above (local, CCDB, and AliEn), consider incorporating the function **_TH1F* GetHistogramWithWeights(...)_** below into your analysis task. The latest version of the code can be obtained directly from [O2Tutorial](https://github.com/abilandz/O2Tutorial) repository, by following this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/cpp/GetHistogramWithWeights.cpp).  The function is implemented semi-schematically, but it's trivial to finalize yourself all the remaining details:

```cpp title="File: src/cpp/GetHistogramWithWeights.cpp"
--8<-- "src/cpp/GetHistogramWithWeights.cpp"
```


#### 5. Usage of the "ccdb" object in analysis task.
To be able to use the "ccdb" object in your analysis task, add the following line in the preamble among other **_include_** directives:

```cpp
#include <CCDB/BasicCCDBManager.h>
```
Then afterward in the code,  add this line just after you have started the **_struct_** definition of your analysis task:
```cpp
Service<ccdb::BasicCCDBManager> ccdb; 
```

After these additions., you call the above function **_TH1F* GetHistogramWithWeights(...)_** in your analysis code to initialize the data member **_histWeights_** (introduced in 1. above) as follows:

```cpp
histWeights = GetHistogramWithWeights(cfFileWithWeights, "some-run-number");
```

After that, you can use at runtime information from **_histWeights_** which was initialized with information from an external ROOT file. At the end of the analysis, **_histWeights_** will be automaticaly saved in the output of your analysis alongside other data members.


#### 6. function TObject* GetObjectFromList(...)
Finally, the promised implementation of the utility function GetObjectFromList(...) is below. The latest version of the code can be obtained directly from [O2Tutorial](https://github.com/abilandz/O2Tutorial) repository, by following this direct [link](https://github.com/abilandz/O2Tutorial/blob/gh-pages/src/cpp/GetObjectFromList.cpp).  Incorporate this function's implementation to your analysis task as well:

```cpp title="File src/cpp/GetObjectFromList.cpp"
--8<-- "src/cpp/GetObjectFromList.cpp"
```


TBC 20261018 ...


To upload a file in CCDB, I sent you the shell function UploadFileToCCDB in a separate email

The very same technique will work later in the online analysis using Hyperloop, to fetch efficiency corrections at run-time from an external file (only in this case it's **mandatory** to use CCDB access).

For bookkeeping sake, set the title of your data member histogram ```histWeights``` to the string stored in your configurable ```cfFileWithWeights```.

That's all in this email, please start working on this, and let me know how far you've got. Please have the same file weights.root (see 2/ above) in some local dir, then copy it to AliEn, and upload it to CCDB. Ideally, for all three cases, you should be able to access histogram histWithEfficiencyCorrections from that file just by modifying the path in the JSON configurable "cfFileWithWeights", initialize your data member histogram histWeights with its content, and save it in the output of your analysis. 
