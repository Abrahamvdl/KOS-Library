function Require{
	parameter filename.
	
	if not EXISTS(filename){
		copypath("0:/library/" + filename, "").
	}
}

Function UserNotify{
	parameter message.
	
	HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
}