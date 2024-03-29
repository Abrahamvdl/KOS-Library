function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
UF("OA.ks").
UF("mathUtils").
run OA.
run mathUtils.

//Orbit close to mum -- watch  out for transition
set ra to 10191593 + Kerbin:radius.
set rp to 10095538 + Kerbin:radius.
set inc to 0.
set longOfAscen to 0.
set arguOfPeri to 0.

set ra to 5040791 + Kerbin:radius.
set rp to 2539406 + Kerbin:radius.
set inc to 2.4.
set longOfAscen to 46.6.
set arguOfPeri to 71.9.

set ecen to (ra - rp) / (ra + rp).
set semiMajor to rp / (1 - ecen).

set TargetPos to V(0,0,0).
set PosSet to false.
set maxDistance to 0.
set minDistance to 0.
set HasMaxDist to false.

SET myOrbit TO CREATEORBIT(inc, ecen, semiMajor, longOfAscen, arguOfPeri, 0, 0, Kerbin).

//set target to "Gusson's Capsule".
//set myOrbit to target:OBT.

until true = false {
  clearscreen.

  print "Info Start".

  print "TARGET ORBIT:Position: " + myOrbit:Position.
  print "TARGET ORBIT:True Anomaly: " + myOrbit:TrueAnomaly.
  print "TARGET ORBIT:Mean Anomaly at EPOCH: " + myOrbit:MEANANOMALYATEPOCH.
  print "TARGET ORBIT:EPOCH: " + myOrbit:EPOCH.
  print "TARGET ORBIT:Velocity: " + myOrbit:VELOCITY.
  print "TARGET ORBIT APOAPSIS ETA: " + myOrbit:ETA:APOAPSIS.
  print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.

  print "TARGET ORBIT PERIOD: " + myOrbit:PERIOD.

  set MeanTrueAnomalyCalc to (myOrbit:PERIOD - myOrbit:ETA:PERIAPSIS) / myOrbit:PERIOD * 360.

  SET EccenVec to (myOrbit:VELOCITY:SQRMAGNITUDE/myOrbit:BODY:MU - 1/myOrbit:POSITION:MAG) * myOrbit:POSITION - (vdot(myOrbit:POSITION, myOrbit:VELOCITY)/myOrbit:BODY:MU) * myOrbit:VELOCITY.

  set TrueAnomalyCalc = arccos(vdot(EccenVec, myOrbit:POSITION)/(EccenVec:MAG * myOrbit:POSITION:MAG)).

  print "Calc Mean Anomaly: " + MeanTrueAnomalyCalc.
  print "Calc TrueAnomaly:  " + TrueAnomalyCalc.


  set PosVec to (myOrbit:POSITION - myOrbit:BODY:POSITION):NORMALIZED.
  set UpVector to VCRS(PosVec, myOrbit:VELOCITY:ORBIT):NORMALIZED.

  set AOPVec to RotateVector(-MeanTrueAnomalyCalc, UpVector, PosVec).
  set AOPVecX to RotateVector(-TrueAnomalyCalc, UpVector, PosVec).

  set AOPVec1 to RotateVector(10, UpVector, PosVec).
  set AOPVec2 to RotateVector(20, UpVector, PosVec).
  set AOPVec3 to RotateVector(30, UpVector, PosVec).

  CLEARVECDRAWS().

  set vd2 TO VECDRAW(Kerbin:position, myOrbit:POSITION - myOrbit:BODY:POSITION, RGB(1,0,0), "PosVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd3 TO VECDRAW(Kerbin:position, UpVector * myOrbit:PERIAPSIS, RGB(0,0,1), "UpVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).

  set vd1 TO VECDRAW(Kerbin:position, AOPVec * myOrbit:PERIAPSIS , RGB(0,1,0), "RotatedVec", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vdx TO VECDRAW(Kerbin:position, AOPVecC * myOrbit:PERIAPSIS , RGB(0,1,0), "RotatedVec", 1.0, TRUE, 0.2, TRUE,	TRUE ).

  // set vda TO VECDRAW(Kerbin:position, AOPVec1 * myOrbit:PERIAPSIS , RGB(1,1,0), "RotatedVec A", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdb TO VECDRAW(Kerbin:position, AOPVec2 * myOrbit:PERIAPSIS , RGB(0,1,1), "RotatedVec B", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdc TO VECDRAW(Kerbin:position, AOPVec3 * myOrbit:PERIAPSIS , RGB(1,0,1), "RotatedVec C", 1.0, TRUE, 0.2, TRUE,	TRUE ).

  wait 0.5.
}

//OrbitalAllignmentWithOrbit(myOrbit).

set orbitalAngle to vang(myOrbit:POSITION - Kerbin:position, ship:position - Kerbin:position).
print "Orbital Angle Diff: " + orbitalAngle.
