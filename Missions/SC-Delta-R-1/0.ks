Print "Some tests on parts.".

SET ReactionWheels to somevessel:PARTSTITLED("Small Inline Reaction Wheel").

SET Wheels2 to somevessel:PARTSDUBBED("Small Inline").

print "ReactionWeeels Length: " + ReactionWheels:LENGTH.
print "Wheels2 Length: " + Wheels2:LENGTH.

FOR P IN SHIP:PARTS {
  print "Part: " + P:NAME.
	for M in P:MODULES {
			print "  Module: " + M:NAME.

			print "  Fields:".
			for F in M:ALLFIELDS {
				print "    Field: " + F.
			}

			print "  Events:".
			for Ev in M:ALLEVENTS {
				print "    Event: " + Ev.
			}
			
			print "  Actions:".
			for Ac in M:ALLACTIONS {
				print "    Action: " + Ac.
			}
	}
}.
