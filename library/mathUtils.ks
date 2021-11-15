function RotateVector{
  parameter angle, AxisVec, TargetVec.

  set cA to cos(angle).
  set sA to sin(angle).
  set cAA to 1-cos(angle).

  set ux to AxisVec:X.
  set uy to AxisVec:Y.
  set uz to AxisVec:Z.

  set uxx to AxisVec:X*AxisVec:X.
  set uyy to AxisVec:Y*AxisVec:Y.
  set uzz to AxisVec:Z*AxisVec:Z.
  
  set uxy to AxisVec:X*AxisVec:Y.
  set uxz to AxisVec:X*AxisVec:Z.
  set uyz to AxisVec:Y*AxisVec:Z.

  set x to TargetVec:X * (cA+uxx*cAA) +    TargetVec:Y * (uxy*cAA-uz*sA) + TargetVec:Z * (uxz*cAA+uy*sA).
  set y to TargetVec:X * (uxy*cAA+uz*sA) + TargetVec:Y * (cA+uyy*cAA) +    TargetVec:Z * (uyz*cAA-ux*sA).
  set z to TargetVec:X * (uxz*cAA-uy*sA) + TargetVec:Y * (uyz*cAA+ux*sA) + TargetVec:Z * (cA+uzz*cAA).

  return v(x,y,z).
}
