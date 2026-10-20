TH1F* GetHistogramWithWeights(const char* filePath, const char* runNumber)
{
  // Last update: 20261018 

  // *) Return value:
  TH1F* hist = NULL;
  TList* baseList = NULL; // base top-level list in the TFile, e.g. named "ccdb_object"
  TList* listWithRuns = NULL; // nested list with run-wise TList's holding run-specific weights

  // *) Determine from filePath if the file is on a local machine, or in home dir AliEn, or in CCDB:

  //    Algorithm: a) If filePath begins with "/alice/cern.ch/" then it's in the home dir AliEn;
  //               b) If filePath begins with "/alice-ccdb.cern.ch/" then it's in CCDB. Therefore, files in AliEn and CCDB must be specified with abs path;
  //               c) For local files both absolute and relative paths are just fine.

  bool bFileIsInAliEn = false;
  bool bFileIsInCCDB = false;
  

  // ... implement your own code here for the above Algorithm, 
  //     to determine from the content of filePath where the external file is, 
  //     and reset the above flags bFileIsInAliEn and bFileIsInCCDB correspondingly ...


  if (bFileIsInAliEn) {

​    // File you want to access is in your home directory in AliEn.
    // In this branch, there is a special code to support file access in that case.

​    TGrid* alien = TGrid::Connect("alien", gSystem->Getenv("USER"), "", ""); 
    // For this to work, do not forget to add #include <TGrid.h> to the preamble of your analysis task

​    if (!alien) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }
​    TFile* weightsFile = TFile::Open(Form("alien://%s", filePath), "READ"); // yes, ROOT can open a file transparently, even if it's sitting in AliEn, with this specific syntax
​    if (!weightsFile) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }
​    weightsFile->GetObject("ccdb_object", baseList);
​    if (!baseList) {
​     // weightsFile->ls();
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }

​    // Finally, from the top-level TList "ccdb_object", get the desired nested TList.
    // The technical problem here is that it can be nested at any level,
​    // to overcome that there is a helper utility function TObject* GetObjectFromList(...),
    // whose implementation if discussed and provided separately.
​    listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumber));
​    if (!listWithRuns) {
​     TString runNumberWithLeadingZeroes = "000";
​     runNumberWithLeadingZeroes += runNumber; // another try, with "000" prepended to run number
​     listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumberWithLeadingZeroes.Data()));
​     if (!listWithRuns) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }
   }

   // OK, we got the desired run-specific TList with efficiency corrections for AliEn case, 
   // after that we can use the common code for all 3 cases (local, AliEn, CCDB),
   // that common code is further below.

   } else if (bFileIsInCCDB) {

​    // File you want to access is in your home directory in CCDB. 
    // In this branch, there is a special code to support file access in that case.

​    // Remember that here I do not access the file; instead, I directly access the object in that file.
​    // My home dir in CCDB: https://alice-ccdb.cern.ch/browse/Users/a/abilandz/ => adapt for your case
​    ccdb->setURL("http://alice-ccdb.cern.ch"); // to be able to use the "ccdb" object in your analysis task, see further down in this tutorial an explanation
​    baseList = reinterpret_cast<TList*>(ccdb->get<TList>(TString(filePath).ReplaceAll("/alice-ccdb.cern.ch/", "").Data())); 
​    if (!baseList) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }

​    listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumber));
​    if (!listWithRuns) {
​    TString runNumberWithLeadingZeroes = "000";
​    runNumberWithLeadingZeroes += runNumber; // another try, with "000" prepended to run number
​    listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumberWithLeadingZeroes.Data()));
​    if (!listWithRuns) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }
   }

   // OK, we got the desired run-specific TList with efficiency corrections for CCDB, 
   // after that we can use the common code for all 3 cases (local, AliEn, CCDB),
   // that common code is further below.

   } else {

​    // File you want to access is on your local computer. 
    // In this branch, there is a special code to support file access in that case.

​    // Check if the external ROOT file exists at the specified path:
​    if (gSystem->AccessPathName(filePath, kFileExists)) {
​     LOGF(info, "\033[1;33m if(gSystem->AccessPathName(filePath,kFileExists)), filePath = %s \033[0m", filePath);
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }

​    TFile* weightsFile = TFile::Open(filePath, "READ");
​    if (!weightsFile) {
​     LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
​    }

​    weightsFile->GetObject("ccdb_object", baseList);

    if (!baseList) {
    // weightsFile->ls();
    LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
   }

   listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumber));
   if (!listWithRuns) {
    TString runNumberWithLeadingZeroes = "000";
    runNumberWithLeadingZeroes += runNumber; // another try, with "000" prepended to run number
    listWithRuns = reinterpret_cast<TList*>(GetObjectFromList(baseList, runNumberWithLeadingZeroes.Data()));
    if (!listWithRuns) {
     // baseList->ls();
     LOGF(fatal, "\033[1;31m%s at line %d : this crash can happen if in the output file there is no list with weights for the current run number = %s\033[0m", __FUNCTION__, __LINE__, tc.fRunNumber.Data());
    }
   }

   // OK, we got the desired run-specific TList with efficiency corrections for local case, 
   // after that we can use the common code for all 3 cases (local, AliEn, CCDB),
   // that common code is further below.

  } // end of else

  // The common code for all three cases, where from "listWithRuns" you fetch the desired histogram with efficiency corrections:
  // listWithRuns->ls();


  // ... implement your own code to get pointer to "hist" object from TList *listWithRuns" 
  //     (it was declared at the beginning of this function "TH1F* hist = NULL;"   
  //     Once you have a valid pointer to "hist", add the technical lines below.


  hist->SetDirectory(0); // remove ownerhip from an external file
  TH1F* histClone = reinterpret_cast<TH1F*>(hist->Clone()); // yes, I have to clone here

  delete baseList; // release back the memory

  return histClone;

} // end of TH1F* GetHistogramWithWeights(...)
