function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
UF("HM3.ks").
run HM3.

//Orbit close to mum -- watch  out for transition
//set ra to 10191593 + Kerbin:radius.
//set rp to 10095538 + Kerbin:radius.
//set inc to 0.
//set longOfAscen to 0.
//set arguOfPeri to 0.

// set ra to 5040791 + Kerbin:radius.
// set rp to 2539406 + Kerbin:radius.
// set inc to 2.4.
// set longOfAscen to 46.6.
// set arguOfPeri to 71.9.
//
// set ecen to (ra - rp) / (ra + rp).
// set semiMajor to rp / (1 - ecen).
//
// set TargetPos to V(0,0,0).
// set PosSet to false.
// set maxDistance to 0.
// set minDistance to 0.
// set HasMaxDist to false.
//
// SET myOrbit TO CREATEORBIT(inc, ecen, semiMajor, longOfAscen, arguOfPeri, 0, 0, Kerbin).

set target to "Gusson's Capsule".
set myOrbit to target:OBT.

OrbitalAllignmentWithOrbit(myOrbit).

set orbitalAngle to vang(myOrbit:POSITION - Kerbin:position, ship:position - Kerbin:position).
print "Orbital Angle Diff: " + orbitalAngle.
