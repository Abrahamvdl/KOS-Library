function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
UF("OA.ks").
run OA.

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
  print "TARGET ORBIT Periapsis ETA: " + myOrbit:Periapsis.

  print "TARGET ORBIT PERIOD: " + myOrbit:PERIOD.

  set MeanTrueAnomalyCalc to (myOrbit:PERIOD - myOrbit:ETA:PERIAPSIS) / myOrbit:PERIOD * 360.

  print "Calculated TrueAnomaly: " + MeanTrueAnomalyCalc.

  set PosVec to (myOrbit:POSITION - myOrbit:BODY:POSITION):NORMALIZED.
  set UpVector to VCRS(myOrbit:VELOCITY:ORBIT, PosVec):NORMALIZED.
  // SET myDir TO Q( PosVec:X, PosVec:y, PosVec:z, -TargetOrbit:TRUEANOMALY ).
  // SET myDir2 TO Q( UpVector:X, UpVector:y, UpVector:z, -TargetOrbit:TRUEANOMALY ).

  print "TargetOrbit:TRUEANOMALY:" + myOrbit:TRUEANOMALY.
  set myDir to ANGLEAXIS(0, PosVec).
  set myDirx to ANGLEAXIS(45, PosVec).
  set myDir2 to ANGLEAXIS(5, UpVector)	.
  set myDirx2 to ANGLEAXIS(-135 - myOrbit:TRUEANOMALY, UpVector).

  set PosLength to (myOrbit:POSITION - myOrbit:BODY:POSITION):MAG.

  CLEARVECDRAWS().

  set vd1 TO VECDRAW(Kerbin:position, myDir:FOREVECTOR * PosLength, RGB(0,1,0), "ForeVec", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd1x TO VECDRAW(Kerbin:position, myDirx:FOREVECTOR * PosLength, RGB(1,1,0), "ForeVecX", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd2 TO VECDRAW(Kerbin:position, PosVec * PosLength, RGB(1,0,0), "PosVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd3 TO VECDRAW(Kerbin:position, UpVector * PosLength, RGB(0,0,1), "UpVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd2x TO VECDRAW(Kerbin:position, myDirx2:FOREVECTOR * PosLength, RGB(0,1,1), "ForeVecX2", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd4 TO VECDRAW(Kerbin:position, myDir2:FOREVECTOR * PosLength, RGB(1,1,1), "UpVEct:Transformed:FORE", 1.0, TRUE, 0.2, TRUE,	TRUE ).


  wait 1.
}

//OrbitalAllignmentWithOrbit(myOrbit).

set orbitalAngle to vang(myOrbit:POSITION - Kerbin:position, ship:position - Kerbin:position).
print "Orbital Angle Diff: " + orbitalAngle.
