function RotateVector{
  parameter angle, AxisVec, SrcVec.

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

  set x to SrcVec:X * (cA+uxx*cAA)    + SrcVec:Y * (uxy*cAA-uz*sA) + SrcVec:Z * (uxz*cAA+uy*sA).
  set y to SrcVec:X * (uxy*cAA+uz*sA) + SrcVec:Y * (cA+uyy*cAA)    + SrcVec:Z * (uyz*cAA-ux*sA).
  set z to SrcVec:X * (uxz*cAA-uy*sA) + SrcVec:Y * (uyz*cAA+ux*sA) + SrcVec:Z * (cA+uzz*cAA).

  return v(x,y,z).
}
