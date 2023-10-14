core:doevent("open terminal").

function Create_S_File{ 
  parameter volLoc, startState.
  
  set volLoc to path(volLoc):combine("S.json").
  print "Creating the S file.".
  print(volloc).
  if exists(volLoc) {
    deletepath(volLoc).
  }

  set S to LEXICON().
  S:ADD("STATE", startState).
  S:ADD("OLDSTATE", startState).
  WRITEJSON(S, volloc).
}

function Compile_Mission{
  print "Compiling the programs in the Mission Folder.".

  SWITCH TO ARCHIVE.
  CD("Missions/"+SHIP:SHIPNAME).

  LIST FILES in fileList.

  for file in fileList {
    if file:extension = "ks" {
      print "Compiling: " + file:name.
      COMPILE file:name.
    }
  }

  SWITCH TO 1.
}

function Copy_Startup{
  print "Copying Startup program".
  set missionFile to "0:/Missions/" + SHIP:SHIPNAME + "/0.ksm".
  if exists(missionFile) {
    copypath(missionFile,"").
    return true.
  } else {
    print "Startup not yet available".
    print " ".
    return false.
  }
}

function Setup_OS{
  parameter canStart.
  print "Copying the main boot File".
  if exists("0:/boot/OS.ks") {
    compile "0:/boot/OS.ks" to "1:/boot/OS.ksm".

  	print "Main boot copied".

  	if canStart {
  		set CORE:BOOTFILENAME to "boot/OS.ksm".
  		deletepath("1:/boot/bootstrap.ks").

  		print "Starting OS in 2 seconds.".
  		wait 2.
  		REBOOT.
  	}
  }
}

function Setup_Subsystems{
  //first collect all the computers
  set computers to SHIP:partsdubbed("CX-4181 Scriptable Control System").

  print("Computers:").
  for comp in computers {
    set libCoreLoc to "0:/Missions/" + SHIP:SHIPNAME + "/" + comp:tag.
    set systemFile    to libCoreLoc + ".ksm".
    set systemReqFile to libCoreLoc + ".req".
    set compModule to comp:getmodule("kOSProcessor").
    
    if comp:tag:length{ 
      if exists(systemFile) and exists(systemReqFile) {    
        print ("  Computer "+  comp:tag + " setup.").           

        //Get the bootfile
        compile "0:/boot/SubSystemOS.ks" to "0:/boot/SSOS.ksm".
        movePath("0:/boot/SSOS.ksm", compModule:volume:create("boot/SSOS.ksm")). 
        set compModule:bootfilename to "boot/SSOS.ksm".

        //Get the main program
        copypath(systemFile, compModule:volume).  

        //Get dependancies 
        set reqFiles to open(systemReqFile):readall:iterator.
        until not reqFiles:next {
          copypath("0:/Library/" + reqFiles:value, compModule:volume).
        }        

        //Create the state file for booting the correct program.
        Create_S_File(compModule:volume, comp:tag + ".ksm").        
      } else {
        print ("  Computer found without mission program: " + comp:tag).
      }
    }

    if compModule:part:UID <> core:part:UID {
      compModule:deactivate().
    }       
  }  
}

//Main Entry point.
function Main{
  wait 2.
  print "Bootstrapping the System".
  print "SHIPNAME: " + SHIP:SHIPNAME.
  wait 1.  

  Create_S_File("1:/", "0.ksm").
  Compile_Mission().

  Setup_Subsystems().
  
  set canStart to Copy_Startup().
  Setup_OS(canStart).

  if not canStart {
    set timerval to 10.
    print("No startup found, waiting " + timerval + " seconds then retrying.").
    until timerval <= 0 {
   	  print timerval.
   	  wait 1.
   	  set timerval to timerval - 1.
    }

    REBOOT.
  }

  print "We are in an unexpected situation...".
  wait 5.
  REBOOT.
}

//Start the Init Boot program
Main().
