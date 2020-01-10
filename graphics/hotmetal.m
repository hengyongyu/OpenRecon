function c = hotmetal(m)

%HOTMETAL a better hot metal color map.
%
%         map = metal(num_colors)
%
% HOTMETAL(M) returns an M-by-3 matrix containing a "hot" colormap.
% HOTMETAL, by itself, is the same length as the current colormap.
%
% For example, to reset the colormap of the current figure:
%
%           colormap(hotmetal)
%
% See also HSV, GRAY, PINK, HOT, COOL, BONE, COPPER, FLAG,
%          COLORMAP, RGBPLOT, SPECTRAL.

% $Id: metal.m,v 1.2 1997/10/20 18:23:20 greg Rel $
% $Name: emma_v0_9_5 $

%         Copyright (c) 1984-92 by The MathWorks, Inc.
%         metal version made by Mark Wolforth, MBIC, MNI (c) 1993

  if nargin<1, m = size(get(gcf,'colormap'),1); end

  base = [  0.000000 0.000000 0.000000
            0.100000 0.000000 0.000000
            0.200000 0.000000 0.000000
            0.300000 0.000000 0.000000
            0.400000 0.000000 0.000000
            0.500000 0.000000 0.000000
            0.600000 0.100000 0.000000
            0.700000 0.200000 0.000000
            0.800000 0.300000 0.000000
            0.900000 0.400000 0.000000
            1.000000 0.500000 0.000000
            1.000000 0.600000 0.100000
            1.000000 0.700000 0.200000
            1.000000 0.800000 0.300000
            1.000000 0.900000 0.400000
            1.000000 1.000000 0.500000
            1.000000 1.000000 0.600000
            1.000000 1.000000 0.700000
            1.000000 1.000000 0.800000
            1.000000 1.000000 0.900000
            1.000000 1.000000 1.000000
         ];

  % interpolate colormap
  n = length(base);
  t = linspace(1,n,m);
  n = 1:n;
  r = interp1(n,base(:,1),t,'linear');
  g = interp1(n,base(:,2),t,'linear');
  b = interp1(n,base(:,3),t,'linear');
  
  % compose colormap
  c = [r(:),g(:),b(:)];
