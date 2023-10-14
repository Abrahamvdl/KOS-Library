function Compile_Library{
  print "Compiling the programs in the Library Folder.".

  SWITCH TO ARCHIVE.
  CD("Library/").

  LIST FILES in fileList.

  for file in fileList {
    if file:extension = "ks" {
      print "Compiling: " + file:name.
      COMPILE file:name to "0:/Library/" + file:name + "m".
    }
  }

  SWITCH TO 1.
}

Compile_Library().
