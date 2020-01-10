function axis = VRMLca( rawpoints, preferredStep)
% Function to compute suitable values for the axis labels on a graph
%       [smin, step, smax] = VRMLca( rawpoints, preferredStep)
%       [smin, step, smax] = VRMLca( rawpoints)
%       Inputs are the raw axis values (for example: 0.01, 0.3 0.8)
%       Output are the axes label parameters ( for example [0, 0.2, 0.8] )
%
% Copyright Craig Sayers and WHOI 1996.
%
if( nargin < 2 )
  preferredStep=0;
end

rmin = min(rawpoints);
rmax = max(rawpoints);
rdiff = rmax - rmin;

if rdiff == 0
  rmin = rmin - 0.4*abs(rmin) - 0.1;
  rmax = rmax + 0.4*abs(rmax) + 0.1;
  rdiff=rmax - rmin;
end

% Try and perturn min/max to get zero as one limit
if rmin > 0 & rmax > 0 
  if rmin/rmax <= 0.25
    rmin = 0;
  end
elseif rmin < 0 & rmax < 0 
  if rmax/rmin <= 0.25
    rmax = 0;
  end
end

% Compute a step which guarantees between 1 and 10 steps between rmin and rmax
% If within 20% of preferred step then use that, otherwise look for
% a value of step which gives (in most cases) between 4 and 7 labels.
if rdiff > 0 
  step = 10^floor(log(abs(rdiff))/log(10));

  if preferredStep ~= 0 & abs(preferredStep - step )/step < 0.20
    step = preferredStep;
  elseif rdiff/step < 1.4
    step = step/4;
  elseif rdiff/step < 3
    step = step/2;
  end
  if rdiff/step > 6
    step = step*2;
  end

  smin = floor(rmin/step)*step;
  smax = ceil(rmax/step)*step;
else
  smin=rmin;
  smax=rmax;
  step=0;
end

axis = [smin,step,smax];
