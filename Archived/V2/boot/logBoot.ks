//This script's purpose is to log information to the screen
//Modify and use it as necessary for testing situations
//Its supposed to be easier to log info here than within a program with limited space.

set initialDeltaV to 5424. //manual amount as given by Kerbal Engineer

until 0=1{
	clearscreen.
	print SHIP:name.
	print "Ship Status: 	" + SHIP:Status.
	print "Ship Type: 		" + SHIP:Type.
	print "Ship DV at Vacuum:			" + SHIP:DELTAV:VACUUM.
	print "Ship DV at Current:		" + SHIP:DELTAV:CURRENT.
	print "Ship DV Curation :			" + SHIP:DELTAV:DURATION.
	print "Ship DV:			" + SHIP:DELTAV.
	print "Stage Num:		" + SHIP:STAGENUM.
	print "Ship Max Thrust:	" + SHIP:MaxThrust.
	print "Ship Mass:		" + SHIP:Mass.
	print "Ship Mass (WET):	" + SHIP:WETMASS.
	print "Ship Mass (DRY):	" + SHIP:DRYMASS.
	print "Ship Dym Pres:	" + SHIP:Q.
	print " ".
	print "Ship Facing:		" + SHIP:Facing.
	print "Ship Bearing:	" + SHIP:Bearing.
	print "Ship Heading:	" + SHIP:Heading.
	print " ".
	print "Ship V Speed:	" + SHIP:VerticalSpeed.
	print "Ship H Speed:	" + SHIP:GroundSpeed.
	print " ".
	print "Sensors: 		".
	print SHIP:SENSORS.
	print " ".
	print "Ship connection: " + SHIP:CONNECTION.
	print "Ship Messages:	" + SHIP:MESSAGES.
	print "Ship Crew:		" + SHIP:Crew().
	print " ".
	print "Orbital Info".
	print "Name:			" + OBT:Name.
	print "Body:			" + OBT:Body.
	print "Apoapsis:		" + OBT:APOAPSIS.
	print "Periapsis:		" + OBT:PERIAPSIS.
	print "Period:			" + OBT:Period.
	print "Inclination:		" + OBT:Inclination.
	print "Eccentricity:	" + OBT:Eccentricity.
	print "SemiMajor Axis:	" + OBT:SemiMajorAXIS.
	print "SemiMinor Axis:	" + OBT:SemiMinorAXIS.
	print "LAN:				" + OBT:LAN.
	print "Argument of P:	" + OBT:ArgumentofPeriapsis.
	print "True Anomaly:	" + OBT:TrueAnomaly.
	print "Mean Anomaly E:	" + OBT:MeanAnomalyAtEPOCH.
	print "EPOCH:			" + OBT:EPOCH.
	print "Transition:		" + OBT:Transition.
	print "Position:		" + OBT:Position.
	print "Velocity:		" + OBT:Velocity.
	print "Velocity Magn:	" + OBT:Velocity:ORBIT:MAG.
	print "ETA APOAPSIS:	" + OBT:ETA:APOAPSIS.
	print "ETA PERIAPSIS:	" + OBT:ETA:PERIAPSIS.
	print "ETA Transition:	" + OBT:Transition.

	print " ".
	if SHIP:STATUS = "ORBITING" and OBT:BODY:NAME = "Kerbin" {
		print "DELTAV Used:	" + (initialDeltaV - SHIP:DELTAV).
	}

	wait 0.2.
}
