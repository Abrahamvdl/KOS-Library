Print "Now we are ready to go to Mum.".
print "And we have to do a half-Hohmann Transfer such that we create a flyby.".


if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Kerbin" {
	//I suppose nothing to do here?
}

if SHIP:STATUS = "ORBITING" and OBT:BODY:NAME = "Mum" {
	//TODO
}

if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Mum" {
	//TODO
}

//TODO capturing and landing.











print "Good luck going to Mum.".

SHUTDOWN.
