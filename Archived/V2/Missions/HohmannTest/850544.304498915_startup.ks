runpath("utils.ks").
function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
UF("HM3.ks").
UserNotify("Starting Test").
run HM3. 

//Orbit close to mum -- watch  out for transition
//set ra to 10191593 + Kerbin:radius.
//set rp to 10095538 + Kerbin:radius.
//set inc to 0.
//set longOfAscen to 0.
//set arguOfPeri to 0. 

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
until true <> false {
	clearscreen.		
	
	print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.	
	
	set orbitalAngle to vang(myOrbit:POSITION - Kerbin:position, ship:position - Kerbin:position).
	print "Orbital Angle Diff: " + orbitalAngle.
	
	CLEARVECDRAWS().
	SET anArrow3 TO VECDRAW(SHIP:Position, myOrbit:POSITION, RGB(0,0,1), "Arrow 3", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	SET anArrow1 TO VECDRAW(Kerbin:position, myOrbit:POSITION - Kerbin:position, RGB(1,0,0), "Arrow 1", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	SET anArrow4 TO VECDRAW(kerbin:position, ship:position - Kerbin:position, RGB(1,1,1), "Arrow 4", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	
	wait 0.2.
}

OrbitalAllignmentWithOrbit(myOrbit).