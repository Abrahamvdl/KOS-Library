// This function is the HohmannManuver. 
// It accepts an orbit and performs the necessary manuvers to reach that orbit.

//Assumptions and what it can't do yet.
//1. The inclination difference is less than 90 degrees.
//2. The SHIP:ORBIT and the newOrbit do not intersect.

//Limitations that need to be checked.
//1. Can it handle orbits that are very ecentric
//2. Can it handle orbits that have exotic shapes.

//First it will correct the inclination, to match the new orbit. 
// (which is not necessarilly part of the Hohmann Transfer, but we add it to allign 
//  the orbits)
//Then it will perform the classic Hohmann Manuver, which is raise or lower 
//the orbit until a tangent orbit is achieved then it will fly to that tangent point
//and circularize the orbit.


//Angle needed between two entities to reach the target orbit at the same position at the same time:
// angle = pi * (1 - (1 / (2*sqr(2))) * sqr((r1/r2 + 1)^3)

//Time from first burn to second burn: 
// t_h = pi * sqr((r1 + r2)^3/(8*mu))

//delta V necessary for the orbits
//dv1 = sqr(mu/r1) * (sqr(2*r2/(r1+r2)) - 1) <-- this is the greater of the two 
//dv2 = sqr(mu/r2) * (1 - sqr(2*r1/(r1+r2))) <-- the circularization burn.

//Maps (-180,180) to (0,360)
function LNG_TO_DEGREES {
  parameter lng.

  RETURN MOD(lng + 360, 360).
}


function PerformManuver {
	PARAMETER FlyToLongitude.
	PARAMETER SteeringDirection.
	PARAMETER OurAltitude.
	PARAMETER TargetAltitude.		
	
	lock THROTTLE to 0.
	
	//Our fly to point should be on the oposite side of the point we are aiming at.

	clearscreen.
	Print "Flying to target Longitude of: " + FlyToLongitude.		
	lock shipAbsOrbitPos to SHIP:ORBIT:LAN + SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY.
	
	until abs(LNG_TO_DEGREES(FlyToLongitude) - LNG_TO_DEGREES(shipAbsOrbitPos)) < 1{//within 1 degree
		print "Current longitude: " + LNG_TO_DEGREES(shipAbsOrbitPos) at (0,1).		
		wait 0.1.
	}
	
	LOCK STEERING to SteeringDirection.
	wait 2.

	clearscreen.
	Print "Performing the Burn manuver".

	set throttleVal to 1.0.
	lock THROTTLE to throttleVal.		

	until ABS(OurAltitude - TargetAltitude) < TargetAltitude * 0.002  { 
		print "Current Steering Direction: " at (0,1).
		print SteeringDirection at (0,2).
		
		print "Current Altitude: " at (0,4).
		print OurAltitude at (0,5).
			
		if ABS(OurAltitude - TargetAltitude) < TargetAltitude * 0.1 {
			set throttleVal to 0.05.
		}
		
		wait 0.1.
	}
	
	if STAGE:DELTAV:CURRENT < 1 {
		set CurrentThrottleLevel to THROTTLE.
		lock THROTTLE to 0.
		stage.
		wait 2.
		lock THROTTLE to CurrentThrottleLevel.			
	}
	wait 0.5.	
	
	lock THROTTLE to 0.
}	


Function HohmannManuver {	
	PARAMETER newOrbit.
	set ourOrbit to SHIP:ORBIT.
	
	//Step 1: Fix the inclination.
	//We have to fly until we reach the target orbit's langitude or assension, 
	//Then we burn in the perpendicular direction of our orbital plane to raise/lower ouer inclination,
	//until it matches the target orbit's inclination.
	
	//The inclination is a value from 0-360 degrees. 
	//0 degrees is co-planer.
	//90 degrees is edge on.
	//180 degrees is retrograde orbit.
	//270 degrees is edge on retrograde.
	//360 degrees is exactly the same as 0 degrees.
	
	//Thus to simplify this script we will only allow manuvers that is less than 90 degrees from 
	//our current inclination (positive or negative)
	//Since if it is more than 90 degrees then we made a mistake during launch and an error should be given and the program should abort.
	
	//Test values
	//10 - 0 = 10
	//350 - 0 = 350 -> 10
	
	//350 - 10 = 340 -> 20
	//10 - 350 = -340 -> -20
	
	//340 - 310 = 30
	//310 - 340 = -30
	
	set inclinationTarget to newOrbit:Inclination - ourOrbit:Inclination.
	
	if inclinationTarget > 180 {
		set inclinationTarget to 360 - inclinationTarget.
	}
	if inclinationTarget < -180 {
		set inclinationTarget to 360 + inclinationTarget.
	}
	
	if inclinationTarget > 90 or inclinationTarget < -90 {
		print "ERROR: Target orbit is too inclined to reach".
		abort.
	}
	
	//At this point we know that the inclinationTarget is acceptable, 
	//so we want to travel to the longitude of assension 
	//(or the desension if it is closer)
		
	set targetLong to newOrbit:LAN. //start by assuming the LAN is ahead of us and we aim for it.
		
	if (newOrbit:LAN - SHIP:GEOPOSITION:LNG) < 0 { // the LAN is behind us, and thus we aim for the longitude of Desension instead.
		set targetLong to MOD(targetLong + 180, 360).
	}
	
	wait until SHIP:GEOPOSITION:LNG - targetLong < 1. //fly until the difference is less than 1 degree.
	
	if inclinationTarget > 0 {	
		lock steering to SHIP:UP.
	}else{
		lock steering to SHIP:UP:INVERSE. //down.
	}
	
	//now we have to burn until the inclination matches.
	set throttleSetting to 0.
	lock throttle to throttleSetting.
	
	until ABS(newOrbit:Inclination - ourOrbit:Inclination) < 0.2 {
		set throttleSetting to ABS(newOrbit:Inclination - ourOrbit:Inclination) / 90 * 0.5. //max 0.5 throttle, but will slow down as we reach the target value.
	}
	
	lock throttle to 0.
	
	//At this point our inclination should match (or very close).
	//Thus we now start the standard Hohmann Manuver
	//We are going to work with the asumption that the 2 orbits do not intersect currently. 
	//Now we need to determine which orbit is inside and which is outside.
	
	set raiseOrbit to newOrbit:APOAPSIS - SHIP:ORBIT:APOAPSIS > 0.
	
	if raiseOrbit {
		//position the target Orbit's periapsis, which is the Longitude of Assension + the Agrument of PERIAPSIS.
		set TargetLongitude to mod(newOrbit:LAN + newOrbit:ARGUMENTOFPERIAPSIS, 360). 
		lock SteeringDirection to PROGRADE.
		lock OurAltitude to SHIP:APOAPSIS. //we are raising our apoapsis.
		
		PerformManuver(TargetLongitude, SteeringDirection, OurAltitude, newOrbit:APOAPSIS).
		
		//position of the target Orbit's apoapsis
		set TargetLongitude to mod(newOrbit:LAN + newOrbit:ARGUMENTOFPERIAPSIS + 180, 360).
		lock SteeringDirection to PROGRADE.
		lock OurAltitude to SHIP:PERIAPSIS.
		
		PerformManuver(TargetLongitude, SteeringDirection, OurAltitude, newOrbit:PERIAPSIS).		
	} else {
		set TargetLongitude to mod(newOrbit:LAN + newOrbit:ARGUMENTOFPERIAPSIS + 180, 360).
		lock SteeringDirection to PROGRADE.
		lock OurAltitude to SHIP:PERIAPSIS.
		
		PerformManuver(TargetLongitude, SteeringDirection, OurAltitude, newOrbit:PERIAPSIS).		
		
		set TargetLongitude to mod(newOrbit:LAN + newOrbit:ARGUMENTOFPERIAPSIS, 360). 
		lock SteeringDirection to PROGRADE.
		lock OurAltitude to SHIP:APOAPSIS. //we are raising our apoapsis.
		
		PerformManuver(TargetLongitude, SteeringDirection, OurAltitude, newOrbit:APOAPSIS).
	}
	
	Print "Final Orbit achieved.".
}

//For the second plan of the Hohmann Transfer
//1. We need the orbit we want to achieve. 
//2. For the target orbit we want to find where the apoapsis and/or periapsis is located in 3d space 
//3. 



// Hohmann Transfer is about transfering from one circular orbit to another circular orbit.
//Thus trying to find parameters such that we can use the HT to go to any orbit is not the 
// function of the HT manuver

// I thus propose that we approach this problem piecemeal.
// 1. Alling the inclination.
// 2. Do a transfer to a circular orbit that have semi-major axis equal to the 
//    periapsis of the target orbit.
// 3. Adjust the orbit to match the true target apoapsis.