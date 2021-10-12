//probe boot system
//inspired by Kevin Gisi

Function Notify{
	parameter message.
	
	HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
}

//I suppose some more tests need to be added to ensure that we are on kerbin landed. 
IF ALT:RADAR < 50 and SHIP:VELOCITY:SURFACE:MAG < 100 {	
	print "Copying the programs".
	wait 3.
	copypath("0:/library/L1Launcher.ks", "").
	copypath("0:/library/NodeExecutor.ks", "").	
	copypath("0:/library/probeabort.ks", "").
	copypath("0:/library/HohmannManuver.ks", "").
	copypath("0:/Missions/HohmannTester.ks", "").
	run L1Launcher.
} 

if HASNODE {
	run NodeExecutor.
}