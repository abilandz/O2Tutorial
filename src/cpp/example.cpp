TObject* GetObjectFromList(TList* list, const char* objectName)
{
 // Get TObject pointer from TList, even if it's in some nested TList. Foreseen

 // Insanity checks:
 if (!list) {
  LOGF(fatal, "\033[1;31m%s at line %d\033[0m", __FUNCTION__, __LINE__);
 }

}
