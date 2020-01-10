function c = spectral(m)

%SPECTRAL Black-purple-blue-green-yellow-red-white color map.
%
%         map = spectral(num_colors)
%
% SPECTRAL(M) returns an M-by-3 matrix containing a "spectral" colormap.
% SPECTRAL, by itself, is the same length as the current colormap.
%
% For example, to reset the colormap of the current figure:
%
%           colormap(spectral)
%
% See also HSV, GRAY, PINK, HOT, COOL, BONE, COPPER, FLAG,
%          COLORMAP, RGBPLOT.

% $Id: spectral.m,v 1.4 1997/10/20 18:23:22 greg Rel $
% $Name: emma_v0_9_5 $

%         Copyright (c) 1984-92 by The MathWorks, Inc.
%         Spectral version made by Gabriel Leger, MBIC, MNI (c) 1993

  if nargin<1, m = size(get(gcf,'colormap'),1); end

  base = [  0.0000 0.0000 0.0000
            0.4667 0.0000 0.5333
            0.5333 0.0000 0.6000
            0.0000 0.0000 0.6667
            0.0000 0.0000 0.8667
            0.0000 0.4667 0.8667
            0.0000 0.6000 0.8667
            0.0000 0.6667 0.6667
            0.0000 0.6667 0.5333
            0.0000 0.6000 0.0000
            0.0000 0.7333 0.0000
            0.0000 0.8667 0.0000
            0.0000 1.0000 0.0000
            0.7333 1.0000 0.0000
            0.9333 0.9333 0.0000
            1.0000 0.8000 0.0000
            1.0000 0.6000 0.0000
            1.0000 0.0000 0.0000
            0.8667 0.0000 0.0000
            0.8000 0.0000 0.0000
            0.8000 0.8000 0.8000
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
