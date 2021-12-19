
SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").

set terminal:WIDTH to 70.
set terminal:HEIGHT to 60.

wait 0.5.

Print "Some tests on parts.".

Print "Parts:".
set ShipParts to SHIP:PARTS.
for Part in ShipParts{
  print "Part: " + Part:TITLE.
}

print "Num of Parts: " + ShipParts:LENGTH.

set CurrentPartIndex to 2.

FROM {local i is CurrentPartIndex.} UNTIL i = CurrentPartIndex + 1 STEP {set i to i+1.} DO {
  print "Part: " + ShipParts[i]:TITLE.
  log ShipParts[i]:TITLE to "0:/Missions/SC-Delta-R-2/name".

  set Modules to ShipParts[i]:MODULES.
  print "  Num of Modules: " + Modules:LENGTH.

  FROM {local j is 0.} UNTIL j = Modules:LENGTH STEP {set j to j+1.} DO {
    print "  Module: " + Modules[j].

    set MyPartModule to ShipParts[i]:GETMODULEBYINDEX(j).

    if MyPartModule:ALLFIELDS:LENGTH > 0 {
      print "   Fields:".
      for F in MyPartModule:ALLFIELDS {
      	print "    Field: " + F.
      }
    }

    if MyPartModule:ALLEVENTNAMES:LENGTH > 0 {
      print "   Event Names:".
      for Ev in MyPartModule:ALLEVENTS {
      	print "    Event Name: " + Ev.
      }
    }

    if MyPartModule:ALLACTIONS:LENGTH > 0 {
      print "   Actions:".
      for Ac in MyPartModule:ALLACTIONS {
      	print "    Action: " + Ac.
      }
    }
  }
}.

Print "Starting to do science!".

print "These have science".
SHIP:PARTSDUBBED("SC-9001 Science Jr.")[0]:GETMODULE("Experiment"):DOEVENT("<b>materials study</b>: <color=#ffd200>stopped</color>").
SHIP:PARTSDUBBED("PresMat Barometer")[0]:GETMODULE("Experiment"):DOEVENT("<b>atmospheric pressure scan</b>: <color=#ffd200>stopped</color>").

print "These have no science".
SHIP:PARTSDUBBED("2HOT Thermometer")[0]:GETMODULE("Experiment"):DOEVENT("<b>temperature scan</b>: <color=#ffd200>stopped</color>").
SHIP:PARTSDUBBED("Geiger Counter")[0]:GETMODULE("Experiment"):DOEVENT("<b>radiation scan</b>: <color=#ffd200>stopped</color>").

print "Weird name".
SHIP:PARTSDUBBED("Mystery Goo™ Containment Unit")[0]:GETMODULE("Experiment"):DOEVENT("<b>mystery goo™ observation</b>: <color=#ffd200>stopped</color>").

print " ".
Print "do something to check until we are either full or done with science or out of power and then finish.".

// print "stuff: " + SHIP:PARTSDUBBED("PresMat Barometer")[0]:GETMODULE("Experiment"):DOEVENT("<b>info</b>: <color=#6dcff6><b>1.1</b></color> / 1.1 t-none").


print "Science Jr is done: " + SHIP:PARTSDUBBED("SC-9001 Science Jr.")[0]:GETMODULE("Experiment"):ALLEVENTNAMES[1]:Contains("t-none").
print "Baro is done: " + SHIP:PARTSDUBBED("PresMat Barometer")[0]:GETMODULE("Experiment"):ALLEVENTNAMES[1]:Contains("t-none").
print "Thermo is done: " + SHIP:PARTSDUBBED("2HOT Thermometer")[0]:GETMODULE("Experiment"):ALLEVENTNAMES[1]:Contains("t-none").
print "Geiger is done: " + SHIP:PARTSDUBBED("Geiger Counter")[0]:GETMODULE("Experiment"):ALLEVENTNAMES[1]:Contains("t-none").
print "Mystery Goo is done: " + SHIP:PARTSDUBBED("Mystery Goo™ Containment Unit")[0]:GETMODULE("Experiment"):ALLEVENTNAMES[1]:Contains("t-none").


local MysteryGoo is 0.
local GeigerCounter is 0.
local Thermometer is 0.

set ShipParts to SHIP:PARTS.
for Part in ShipParts{
  // print "Part: " + Part:TITLE.
  if Part:TITLE:Contains("Mystery Goo"){
    set MysteryGoo to Part.
  }
  if Part:TITLE:Contains("Geiger Counter"){
    set GeigerCounter to Part.
  }
  if Part:TITLE:Contains("Thermometer"){
    set Thermometer to Part.
  }
}

print "Start Geiger Counter".
GeigerCounter[0]:GETMODULE("Experiment"):DOEVENT("<b>radiation scan</b>: <color=#ffd200>stopped</color>").
print "Start Mystery Goo".
MysteryGoo:GETMODULE("Experiment"):DOEVENT("<b>mystery goo™ observation</b>: <color=#ffd200>stopped</color>").
print "Start Thermometer".
Thermometer[0]:GETMODULE("Experiment"):DOEVENT("<b>temperature scan</b>: <color=#ffd200>stopped</color>").


// Sometimes this technique is needed:




wait until 1=0.
