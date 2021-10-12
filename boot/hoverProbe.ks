// Proportional Function v1.0.0
// Kevin Gisi
// http://youtube.com/gisikw

SET kP to 0.01.
SET kI to 0.001.
SET kD to 0.005.

SET lastP to 0.
SET lastTime to 0.
SET totalP to 0.

FUNCTION PID_LOOP {
  PARAMETER target.
  PARAMETER current.
  
  SET output to 0.
  SET now to TIME:SECONDS.
  
  SET P to target - current.
  SET I to 0.
  SET D to 0.
  
  if lastTime > 0 {
	SET I to totalP + ((P + lastP)/2 * (now - lastTime)). //Ave heigth * elapsed time = area under the curve
	SET D to (P - lastP) / (now - lastTime). //Difference in the height / elapsed time = tangent line to the curve  
  }
  
  SET output to P * kP + I * kI + D * kD.
  
  CLEARSCREEN.
  Print "P: " + P.
  Print "D: " + D.
  Print "I: " + I.
  Print "Output: " + output.
  
  Set lastP to P.
  Set lastTime to now.
  SET totalP to I.

  RETURN output.
}


SET PID to PIDLOOP(kP, kI, kD).
SET PID:SETPOINT to 500.

// Get us 500 meters up
LOCK STEERING TO HEADING(90, 90).
LOCK THROTTLE TO 0.3.
STAGE.
WAIT UNTIL ALTITUDE > 500.

// Test our proportional function
SET autoThrottle TO 0.
LOCK THROTTLE TO autoThrottle.

SWITCH TO 0.
SET startTime TO TIME:SECONDS.

UNTIL STAGE:LIQUIDFUEL < 10 {
  //SET autoThrottle TO PID_LOOP(500, ALTITUDE).
  SET autoThrottle TO PID:UPDATE(TIME:SECONDS, ALTITUDE).
  SET autoThrottle TO MAX(0, MIN(autoThrottle, 1)).
  WAIT 0.001.
  LOG (TIME:SECONDS - startTime) + "," + ALTITUDE + "," + autoThrottle TO "testflight1.csv".
}

// Recover the vessel
LOCK THROTTLE TO 0.
STAGE.
switch to 1.