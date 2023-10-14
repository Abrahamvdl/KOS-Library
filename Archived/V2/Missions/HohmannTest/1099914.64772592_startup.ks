//Initialize the library
runpath("utils.ks").

function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
UF("HM2.ks").
UserNotify("Starting Test").
run HM2. 

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
		
		print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.
		
		set timeForTransit to TimeFromBurnToApproach(SHIP:OBT, myOrbit).
		print "Time To reach Transition Orbit: " + timeForTransit.
		
		print "TIME to BURN: " + (timeForTransit - myOrbit:ETA:Periapsis).
		
		set AnglePos to VANG(ship:position, myOrbit:position).
		print "Angle Diff: " + AnglePos.
		
		if myOrbit:ETA:Periapsis < 1  {
			set TargetPos to myOrbit:POSITION:VEC.
			set maxDistance to (SHIP:POSITION - TargetPos):SQRMAGNITUDE + 10.
			set PosSet to true.
		}
		
		if PosSet {
			set currentDistance to (SHIP:POSITION - TargetPos):SQRMAGNITUDE.
			print "Current Distance: " + currentDistance.
			
			if currentDistance > maxDistance and not HasMaxDist {
				set maxDistance to currentDistance.
			} else {
				PRint "HERE IS THE Max Distance".
				set HasMaxDist to true.
				set minDistance to maxDistance.
			}
			
			if HasMaxDist and currentDistance < minDistance{
				set mimDistance to currentDistance.
			}else {
				PRint "HERE IS THE MIM Distance".				
			}			
		}		
		
		CLEARVECDRAWS().
		SET anArrow3 TO VECDRAW(SHIP:Position, myOrbit:POSITION, RGB(0,0,1), "Arrow 3", 1.0, TRUE, 0.2, TRUE,	TRUE ).
		
		wait 1.
	}

//OrbitalAllignmentWithOrbit(myOrbit).