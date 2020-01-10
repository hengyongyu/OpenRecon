function [xx,yy,zz] = plane(c,y,z)
%PLANE Generate plane.
%   [X,Y,Z] = PLANE(N) generates three (N+1)-by-(N+1)
%   matrices so that SURF(X,Y,Z) produces a unit plane.
%
%   [X,Y,Z] = PLANE uses N = 20.
%
%   PLANE(N) and just PLANE graph the plane as a SURFACE
%   and do not return anything.
%
%   See also ELLIPSOID, CYLINDER, SPHERE.

  if nargin<2, y = [-1,1,2]; end
  if nargin<3, z = y; end
  y = ParseInput(y);
  z = ParseInput(z);
  
  [y,z] = meshgrid(linspace(y(1),y(2),y(3)),linspace(z(1),z(2),z(3)));
  
  x = z;
  x(:) = c;

  if nargout == 0
    surf(x,y,z);
    alpha(.3);
  else
    xx = x; yy = y; zz = z;
  end


function y = ParseInput(y)
  
  if length(y)==1
    y = [-y,y,2];
  elseif length(y)==2
    y = [y 2];
  end
  