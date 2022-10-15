runpath("utils.ks").
function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
//UF("HM2.ks").
UserNotify("Starting Test").
//run HM2. 

function AngleForIntersection {parameter Orbit1. parameter Orbit2. return Constant:RadToDeg * CONSTANT:PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3)).}
function TimeFromBurnToApproach {
	parameter Orbit1. 
	parameter Orbit2. 
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
}
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
until true = false {
	clearscreen.		
	
	set angle to AngleForIntersection(SHIP:ORBIT,myOrbit).
	
	print "Approach Angle: " + angle.
	
	print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.
	
	set timeForTransit to TimeFromBurnToApproach(SHIP:OBT, myOrbit).
	print "Time To reach Transition Orbit: " + timeForTransit.
	
	print "TIME to BURN: " + (timeForTransit - myOrbit:ETA:Periapsis).
	
	set AnglePos to VANG(ship:obt:position, myOrbit:position).
	print "Angle Diff: " + AnglePos.

	set kuniverse:timewarp:mode to "RAILS".
	if myOrbit:ETA:Periapsis < 1 and not PosSet {
		set TargetPos to myOrbit:POSITION:VEC.
		set maxDistance to (SHIP:OBT:POSITION - TargetPos):MAG + 10.
		set CurrentAngleDiff to AnglePos.		
		set CurrentTrueAnomaly to SHIP:obt:TRUEANOMALY.
		set TargetTrueAnomaly to mod(CurrentTrueAnomaly + angle, 360).
		set PosSet to true.
		kuniverse:timewarp:cancelwarp().
	} else if not PosSet {
		set kuniverse:timewarp:rate to myOrbit:ETA:Periapsis/2.
	}
	
	if PosSet {
		//set currentDistance to (SHIP:OBT:POSITION - TargetPos):MAG.
		//print "Current Distance: " + currentDistance.
		//print "Target Pos: " + TargetPos.
		//print "Target Pos 2: " + myOrbit:POSITION.
		//print "SHIP Pos: " + SHIP:OBT:POSITION.
		//print "Has Max Dist: " + hasMaxDist.
		
		print "Initial TrueAnomaly: " + CurrentTrueAnomaly.
		print "Target TrueAnomaly: " + TargetTrueAnomaly.
		print "Current TrueAnomaly: " + SHIP:OBT:TrueAnomaly.
		
		//if currentDistance > maxDistance and not HasMaxDist {
//			set maxDistance to currentDistance.
	//	} else {
		//	PRint "Max Dist".
			//set HasMaxDist to true.
			//set minDistance to maxDistance.
		//}
		
//		if HasMaxDist and currentDistance < minDistance{
	//		set mimDistance to currentDistance.
		//}else {
			//PRint "Min Dist".				
		//}			
	}		
	
	CLEARVECDRAWS().
	SET anArrow3 TO VECDRAW(SHIP:Position, myOrbit:POSITION, RGB(0,0,1), "Arrow 3", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	SET anArrow1 TO VECDRAW(Kerbin:position, myOrbit:POSITION - Kerbin:position, RGB(1,0,0), "Arrow 1", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	//SET anArrow2 TO VECDRAW(Kerbin:position, ship:obt:position, RGB(0,1,0), "Arrow 2", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	//SET anArrow4 TO VECDRAW(ship:position, kerbin:position, RGB(1,1,1), "Arrow 4", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	SET anArrow4 TO VECDRAW(kerbin:position, ship:position - Kerbin:position, RGB(1,1,1), "Arrow 4", 1.0, TRUE, 0.2, TRUE,	TRUE ).
	
	wait 0.2.
}

//OrbitalAllignmentWithOrbit(myOrbit).