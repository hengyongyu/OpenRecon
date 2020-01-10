function c = gecolour(m)

%GECOLOUR - Colour map used by GE software.
%
%         map = gecolour(num_colors)
%
% GECOLOUR(M) returns an M-by-3 matrix containing a GE colormap.
% GECOLOUR, by itself, is the same length as the current colormap.
%
% For example, to reset the colormap of the current figure:
%
%           colormap(gecolour)
%
% See also HSV, GRAY, PINK, HOT, COOL, BONE, COPPER, FLAG,
%          COLORMAP, RGBPLOT.

% $Id: gecolour.m,v 1.2 1997/10/20 18:23:23 greg Rel $
% $Name: emma_v0_9_5 $

%         Copyright (c) 1984-92 by The MathWorks, Inc.
%         gecolour version made by Mark Wolforth, McBIC, MNI (c) 1993

  if nargin < 1, m = size(get(gcf,'colormap'),1); end

  base = [  0         0         0
            0         0.0321    0.0314
            0         0.0643    0.0627
            0         0.0964    0.0941
            0         0.1325    0.1255
            0         0.1647    0.1569
            0         0.1968    0.1882
            0         0.2289    0.2196
            0         0.2610    0.2510
            0         0.2932    0.2824
            0         0.3253    0.3137
            0         0.3574    0.3451
            0         0.3936    0.3765
            0         0.4257    0.4078
            0         0.4578    0.4392
            0         0.4900    0.4706
            0.0078    0.5060    0.5020
            0.0392    0.4739    0.5294
            0.0706    0.4418    0.5608
            0.1020    0.4096    0.5922
            0.1333    0.3815    0.6235
            0.1647    0.3494    0.6549
            0.1922    0.3173    0.6863
            0.2235    0.2851    0.7176
            0.2549    0.2530    0.7490
            0.2863    0.2209    0.7804
            0.3176    0.1888    0.8118
            0.3490    0.1566    0.8431
            0.3804    0.1285    0.8745
            0.4118    0.0964    0.9059
            0.4431    0.0643    0.9373
            0.4745    0.0321    0.9686
            0.5020    0         1.0000
            0.5333    0.0321    0.9373
            0.5647    0.0643    0.8745
            0.5961    0.0964    0.8118
            0.6275    0.1285    0.7490
            0.6588    0.1606    0.6863
            0.6902    0.1928    0.6235
            0.7216    0.2249    0.5608
            0.7529    0.2570    0.5020
            0.7843    0.2892    0.4392
            0.8157    0.3213    0.3765
            0.8431    0.3534    0.3137
            0.8745    0.3855    0.2510
            0.9059    0.4177    0.1882
            0.9373    0.4498    0.1255
            0.9686    0.4819    0.0627
            1.0000    0.5181    0
            1.0000    0.5502    0.0627
            1.0000    0.5823    0.1255
            1.0000    0.6145    0.1922
            1.0000    0.6466    0.2549
            1.0000    0.6787    0.3176
            1.0000    0.7108    0.3804
            1.0000    0.7430    0.4431
            1.0000    0.7751    0.5098
            1.0000    0.8072    0.5725
            1.0000    0.8394    0.6353
            1.0000    0.8715    0.6980
            1.0000    0.9036    0.7608
            1.0000    0.9357    0.8235
            1.0000    0.9679    0.8902
            1.0000    1.0000    0.9529
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
