//Initialize the library
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

set ra to 10191593.
set rp to 10095538.
set ecen to (ra - rp) / (ra + rp).
set semiMajor to rp / (1 - ecen).


//set semiMajor to (10191593 + 10095538)/2.
SET myOrbit TO CREATEORBIT(0, 0, semiMajor, 0, 0, 0, 0, Kerbin).


HohmannManuver(myOrbit).