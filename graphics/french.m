function h = french(m,flag)
%FRENCH    French's flag color map.
%   FRENCH(M) returns an M-by-3 matrix containing a "french flag" colormap.
%   FRENCH, by itself, is the same length as the current colormap.
%
%   FRENCH(M,FLAG) enables a modification of the colormap, where
%   FLAG can be either 1 (default) or 2.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(french)
%
%   See also HOT, HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

% Copyright (c) 2002 by AMRON
% Norbert Marwan, Potsdam University, Germany
% http://www.agnld.uni-potsdam.de
%
% Last Revision: 2002-11-08
% Version: 1.1


  if nargin < 1
    m = size(get(gcf,'colormap'),1); 
  else
    if isempty(m)
      m = size(get(gcf,'colormap'),1); 
    end
  end
  if nargin < 2, flag = 1; end

  n1 = fix(3*m/8);
  n2 = fix(m/4);
  n3 = fix(m/2);

  switch flag
   case 1
    r = [ones(n3,1); (sqrt(1-((1:n3)/n3).^2))'];
    g = [flipud( (sqrt(1-((1:n3)/n3).^2))'); (sqrt(1-((1:n3)/n3).^2))'];
    b = [flipud((sqrt(1-((1:n3)/n3).^2))'); ones(n3,1)];
   case 2
    r = [ones(n1+n2,1); (n1-1:-1:0)'/n1;];
    g = [(0:n1-1)'/n1; ones(n2,1); (n1-1:-1:0)'/n1;];
    b = [(0:n1-1)'/n1; ones(n1+n2,1);];
  end

  h = [r g b];

  if size(h,1)<m
    h(ceil(m/2)+1:m,:)=h(ceil(m/2):end,:);
    h(ceil(m/2),:)=1;
  end

