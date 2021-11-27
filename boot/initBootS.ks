function Create_S_File{
  print "Creating the S file.".
  if EXISTS("1:/S") {
    deletepath("1:/S").
  }

  set S to LEXICON().
  S:ADD("STATE","0.ksm").
  WRITEJSON(S,"S.json").
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

function CopyStartup{
  print "Copying Startup program".
  set missionFile to "0:/Missions/" + SHIP:SHIPNAME + "/0.ksm").
  if EXISTS(missionFile) {
    copypath(missionFile,"").
    return true.
  } else {
    print "Startup not yet available".
    print " ".
    return false.
  }
}

function SetupGenBoot{
  parameter canStart.
  print "Copying the main boot File".
  if EXISTS("0:/boot/genBootS.ks") {
    compile "0:/boot/genBootS.ks" to "1:/boot/genBootS.ksm".

  	print "Main boot copied".

  	if canStart {
  		set CORE:BOOTFILENAME to "boot/genBootS.ksm".
  		deletepath("1:/boot/initBoot.ks").

  		print "Starting Main boot in 2 seconds.".
  		wait 2.
  		REBOOT.
  	}
  }
}

//Main Entry point.
function main{
  Print "Starting Initial Boot S".
  Print "SHIPNAME: " + SHIP:SHIPNAME.
  wait 1.

  Create_S_File().
  Compile_Mission().
  set canStart to CopyStartup().
  SetupGenBoot(canStart).

  if not canStart {
    set timerval to 5.
    Print("No startup found, waiting " + timerval + "seconds then retrying.").
    until timerval <= 0 {
   	  print timerval.
   	  wait 1.
   	  set timerval to timerval - 1.
    }

    REBOOT.
  }

  PRint "We are in an unexpected situation...".
  wait 5.
  REBOOT.
}

//Start the Init Boot program
main().
