TObject* GetObjectFromList(TList* list, const char* objectName)
{
 // Last update: 20261018 

 // Get TObject pointer from TList, even if it's in some nested TList. 
 // Foreseen to be used to fetch histograms or profiles from files directly. 

 // Some ideas taken from TCollection::ls()

 // If you have added histograms directly to files (without TList's), then you can fetch them directly with
 // file->Get("hist-name").

 // Example usage: TH1D *hist = (TH1D*) GetObjectFromList("some-valid-TList-pointer","some-object-name");

 // Insanity checks:
 if (!list) {
  LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
 }
 if (!objectName) {
  LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
 }
 if (0 == list->GetEntries()) {
  return NULL;
 }

 // The object is in the current base list:
 TObject* objectFinal = list->FindObject(objectName); // the final object I am after
 if (objectFinal ) { return objectFinal; }

 // Otherwise, search for the object recursively in the nested lists:
 TObject* objectIter; // iterator object in the loop below
 TIter next(list);
 while ((objectIter = next())) // double round braces are to silence the warnings
 {
  if (TString(objectIter->ClassName()).EqualTo("TList")) {
   objectFinal = GetObjectFromList(reinterpret_cast<TList*>(objectIter), objectName);
   if (objectFinal)
    return objectFinal;
  }
 } // while(objectIter = next())

 return NULL;

} // TObject* GetObjectFromList(...)
