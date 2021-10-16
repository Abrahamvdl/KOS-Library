print "Copying Utilities".
if EXISTS("0:/library/utils.ks") {
	copypath("0:/library/utils.ks","1:/utils.ks").	
	runpath("utils.ks").
}

Require("hohmannManuver.ks").

UserNotify("ALL SYSTEMS GO!!").

print ("rename the update now").