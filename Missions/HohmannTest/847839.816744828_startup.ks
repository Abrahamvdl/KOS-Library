//Initialize the library
runpath("utils.ks").

function UpdateFile{
	parameter filename.
	
	if addons:rt:hasconnection(ship) {
		copypath("0:/library/" + filename, "").
	}
}

UpdateFile("HM2.ks").

UserNotify("Starting Test").
run HM. 

//eccentricity e can be calculated with:
// e = (ra - rp) / (ra + rp)
// where ra is radius apoapsis and rp is radius at periapsis.

//then we have
// rp = a(1-e)
// a = rp / (1-e) 
//where a is the semi-major axis.

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

SET myOrbit TO CREATEORBIT(inc, ecen, semiMajor, longOfAscen, arguOfPeri, 0, 0, Kerbin).

	print "RA: " + ra.
	print "RP: " + rp.
	print "ecen: " + ecen.
	print "semiMajor: " + semiMajor.
	print " ".	
	
	until true <> false {
		clearscreen.
		
		print "Info Start".
		
		print "TARGET ORBIT:Position: " + myOrbit:Position.
		print "TARGET ORBIT:True Anomaly: " + myOrbit:TrueAnomaly.
		print "TARGET ORBIT:Mean Anomaly at EPOCH: " + myOrbit:MEANANOMALYATEPOCH.
		print "TARGET ORBIT:EPOCH: " + myOrbit:EPOCH.
		print "TARGET ORBIT:Velocity: " + myOrbit:VELOCITY.
		
		print " ".
		print "Our Orbit info.".
		print "Inclination: " + ship:orbit:Inclination.
		print "LAN: " + ship:orbit:LAN.
		print "ArgumentOfPeriapsis: " + ship:orbit:ArgumentOfPeriapsis.
		print "True Anomaly: " + ship:orbit:TrueAnomaly.
		
		print "".
		
		set angle to AngleForIntersection(SHIP:ORBIT,myOrbit).
		
		print "Approach Angle: " + angle.
		
		print "Ship APOAPSIS ETA: " + SHIP:OBT:ETA:APOAPSIS.
		print "Ship Periapsis ETA: " + SHIP:OBT:ETA:Periapsis.
		print "TARGET ORBIT APOAPSIS ETA: " + myOrbit:ETA:APOAPSIS.
		print "TARGET ORBIT Periapsis ETA: " + myOrbit:Periapsis.
		
		set timeForTransit to TimeFromBurnToApproach(SHIP:OBT, myOrbit).
		print "Time To reach Transition Orbit: " + timeForTransit.
		
		print "TIME to BURN: " + (timeForTransit - myOrbit:ETA:APOAPSIS).
		
		CLEARVECDRAWS().
		
		//SET anArrow TO VECDRAW(	V(0,0,0),myOrbit:POSITION,RGB(1,0,0),"Arrow 1",1.0,TRUE,0.2,TRUE,TRUE).
		
		//SET anArrow2 TO VECDRAW(V(0,0,0), myOrbit:POSITION - SHIP:Position,	RGB(0,1,0),	"Arrow 2",	1.0,TRUE,0.2,TRUE,TRUE).
		
		SET anArrow3 TO VECDRAW(SHIP:Position, myOrbit:POSITION, RGB(0,0,1), "Arrow 3", 1.0, TRUE, 0.2, TRUE,	TRUE ).
		
		wait 1.
	}

OrbitalAllignmentWithOrbit(myOrbit).