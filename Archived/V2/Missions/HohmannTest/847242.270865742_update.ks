//Initialize the library
runpath("utils.ks").
Require("hohmannManuver.ks").

UserNotify("ALL SYSTEMS GO!!").
run HohmannManuver. 

//CREATEORBIT(inc, e, sma, lan, argPe, mEp, t, body)
//Parameters:	
//inc – (scalar) inclination, in degrees.
//e – (scalar) eccentricity
//sma – (scalar) semi-major axis
//lan – (scalar) longitude of ascending node, in degrees.
//argPe – (scalar) argument of periapsis
//mEp – (scalar) mean anomaly at epoch, in degrees.
//t – (scalar) epoch
//body – (Body) body to orbit around
//Returns:	
//Orbit

//eccentricity e can be calculated with:
// e = (ra - rp) / (ra + rp)
// where ra is radius apoapsis and rp is radius at periapsis.

//then we have
// rp = a(1-e)
// a = rp / (1-e) 
//where a is the semi-major axis.

set ra to 10191593 + Kerbin:radius.
set rp to 10095538 + Kerbin:radius.
set ecen to (ra - rp) / (ra + rp).
set semiMajor to rp / (1 - ecen).


//set semiMajor to (10191593 + 10095538)/2.
SET myOrbit TO CREATEORBIT(0, ecen, semiMajor, 0, 0, 0, 0, Kerbin).

	print "RA: " + ra.
	print "RP: " + rp.
	print "ecen: " + ecen.
	print "semiMajor: " + semiMajor.
	print " ".

	print "Apoapsis: " + myOrbit:Apoapsis.
	print "Periapsis: " + myOrbit:Periapsis.
	print "Inclination: " + myOrbit:Inclination.
	print "Eccentricity: " + myOrbit:Eccentricity.
	print "SemiMajorAxis: " + myOrbit:SEMIMAJORAXIS.
	print "LAN: " + myOrbit:LAN.
	print "ArgumentOfPeriapsis: " + myOrbit:ArgumentOfPeriapsis.

	print " ".
	print "Our Orbit info.".
	print "Inclination: " + ship:orbit:Inclination.
	print "LAN: " + ship:orbit:LAN.
	print "ArgumentOfPeriapsis: " + ship:orbit:ArgumentOfPeriapsis.
	print "True Anomaly: " + ship:orbit:TrueAnomaly.
	wait 1.





HohmannManuver(myOrbit).