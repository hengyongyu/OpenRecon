function A = VRMLra(nx,ny,nz,phi)
%
% function returns a 3x3 rotation matrix corresponding to
% a rotation of phi about [xn;xy;xz]
%

sp = sin(phi); cp = cos(phi); vp = 1-cp;

A = [nx*nx*vp+cp  nx*ny*vp-nz*sp  nx*nz*vp+ny*sp; ny*nx*vp+nz*sp ny*ny*vp+cp ny*nz*vp-nx*sp; nz*nx*vp-ny*sp nz*ny*vp+nx*sp nz*nz*vp+cp ];

