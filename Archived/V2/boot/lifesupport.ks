SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").

set terminal:WIDTH to 70.
set terminal:HEIGHT to 60.


//Step 1. Get the lifesupport equipment.
  //Like batteries, solar panels, and generators.

set ElectricCharge to 0.

function DisplayResources {
  clearscreen.
  LIST RESOURCES IN RESLIST.
  FOR RES IN RESLIST {
      set strLen to RES:NAME:LENGTH.

      PRINT RES:NAME + " ":PADRIGHT(20-strLen) + ROUND(100*RES:AMOUNT/RES:CAPACITY) + "% full.".
  }.
}


LIST RESOURCES IN RESLIST.
FOR RES IN RESLIST {
    if res:NAME:Contains("Electric") {
      set ElectricCharge to RES.
    }
}.

set ShipFuelCells to SHIP:PARTSDUBBED("Fuel Cell").




// print "Part: " + FuelCell:TITLE.
// set file to "0:/Missions/MF-Delta-R-2/FuelCellDescriptor".
//
// log "Part: " + FuelCell:TITLE to file.
// set Modules to FuelCell:MODULES.
// print "  Num of Modules: " + Modules:LENGTH.
// log "  Num of Modules: " + Modules:LENGTH to file.
//
//
// FROM {local j is 0.} UNTIL j = Modules:LENGTH STEP {set j to j+1.} DO {
//   print "  Module: " + Modules[j].
//   log "  Module: " + Modules[j] to file.
//
//   set MyPartModule to FuelCell:GETMODULEBYINDEX(j).
//
//   if MyPartModule:ALLFIELDS:LENGTH > 0 {
//     print "   Fields:".
//     log "   Fields: " to file.
//     for F in MyPartModule:ALLFIELDS {
//       print "    Field: " + F.
//       log "    Field: " + F to file.
//     }
//   }
//
//   if MyPartModule:ALLEVENTNAMES:LENGTH > 0 {
//     print "   Event Names:".
//     log "   Event Names:" to file.
//     for Ev in MyPartModule:ALLEVENTS {
//       print "    Event Name: " + Ev.
//       log "    Event Name: " + Ev to file.
//     }
//   }
//
//   if MyPartModule:ALLACTIONS:LENGTH > 0 {
//     print "   Actions:".
//     log "   Actions:" to file.
//     for Ac in MyPartModule:ALLACTIONS {
//       print "    Action: " + Ac.
//       log "    Action: " + Ac to file.
//     }
//   }
// }




//Main loop.
function main {
  parameter waitTime.

  set FuelCellState to false.

  until 1=2 {
    DisplayResources().

    if ROUND(100*ElectricCharge:AMOUNT/ElectricCharge:CAPACITY) < 60 and not FuelCellState {
      //we need to turn on some generation.
      print "Powering on the Fuel Cells.".
      set FuelCellState to true.
      // FUELCELLS ON. //not working yet
      for fuelCell in ShipFuelCells{
        fuelCell:GETMODULE("ProcessController"):DOEVENT("<b>h2+o2 fuel cell</b>: stopped").
      }
    }

    if ROUND(100*ElectricCharge:AMOUNT/ElectricCharge:CAPACITY) > 80 and FuelCellState{
      //we need to turn off some generation.
      print "Powering off the Fuel Cells.".
      set FuelCellState to false.
      // FUELCELLS OFF.
      for fuelCell in ShipFuelCells{
        fuelCell:GETMODULE("ProcessController"):DOEVENT("<b>h2+o2 fuel cell</b>: running").
      }
    }

    wait waitTime.
  }
}

set waitTime to 60.
main(waitTime).
