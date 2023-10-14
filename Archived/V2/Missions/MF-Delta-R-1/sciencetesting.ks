SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").
set terminal:WIDTH to 50.
set terminal:HEIGHT to 60.

print "Test the Science Parts.".
print "Lets do some science".

print " ".

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
GeigerCounter:GETMODULE("Experiment"):DOEVENT("<b>radiation scan</b>: <color=#ffd200>stopped</color>").
print "Start Mystery Goo".
MysteryGoo:GETMODULE("Experiment"):DOEVENT("<b>mystery goo™ observation</b>: <color=#ffd200>stopped</color>").
print "Start Thermometer".
Thermometer:GETMODULE("Experiment"):DOEVENT("<b>temperature scan</b>: <color=#ffd200>stopped</color>").


wait until 1=2.
