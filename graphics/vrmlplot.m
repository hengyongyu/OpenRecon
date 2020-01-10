function outfile = VRMLplot(a,b,c,d,e,f,g,h,i,j)
% VRMLplot - generate a 3-D interactive graph in VRML 2.0 format.
% 
% Type VRMLplot; and hit enter/return for detailed documentation
%
% Requires the files: VRMLplot.m VRMLps.m VRMLca.m VRMLpa.m VRMLpg.m VRMLra.m
% Version 1.2.1 Copyright Craig Sayers and WHOI, 1996,97.

if nargin == 0
  disp(' ');
  disp(' VRMLplot takes a list of 3D coordinates and an optional series of');
  disp('          axis labels.  The resulting file contains an interactive');
  disp('          VRML 2.0 graph or animation.')
  disp('          Calling VRMLplot(x,y,z) generates a graph reminiscent of that')
  disp('          created by plot3(x,y,z).  Calling VRMLplot(Z) generates a');
  disp('          surface plot reminiscent of mesh(Z) and calling VRMLplot(x,y,z,t)')
  disp('          generates an animation showing motion of x,y,z over time.')
  disp('          In addition, VRMLplot can animate models of vehicles or')
  disp('          articulated figures.')
  disp(' ');
  disp('          NOTE - to view the output files you must have a VRML *2.0*')
  disp('          compatible viewer - we recommend using Netscape and');
  disp('          Silicon Graphics'' CosmoPlayer plugin on an SGI machine.')
  disp('          You can try an example from:');
  disp('          http://www.dsl.whoi.edu/~sayers/VRMLplot');
  disp('          to see if your browser is compatible.');
  disp(' ');
  disp('   usage: VRMLplot');
  disp('          VRMLplot(Z)');
  disp('          VRMLplot(Z,options)');
  disp('          VRMLplot(X,Y,Z)');
  disp('          VRMLplot(X,Y,Z,options)');
  disp('          VRMLplot(X,Y,Z,C)');
  disp('          VRMLplot(X,Y,Z,C,options)');
  disp('          VRMLplot(x,y,z)');
  disp('          VRMLplot(x,y,z,t)');
  disp('          VRMLplot(x,y,z,options)');
  disp('          VRMLplot(x,y,z,t,options)');
  disp('          VRMLplot(L,options)');
  disp(' ');
  disp('          X,Y,Z,C,L are matrices; x,y,z and t are vectors');
  disp(' ');
  disp('          options is a string in the form: ''opt1=val1; opt2=val2 ... optN=valN''');
  disp('          current options supported are:');
  disp('          xlabel, xmin, xstep, xmax, xscale,');
  disp('          ylabel, ymin, ystep, ymax, yscale,');
  disp('          zlabel, zmin, zstep, zmax, zscale,');
  disp('          tlabel, tmin, tstep, tmax, tscale.');
  disp('          title, append, animation, text, shadow, mesh');
  disp('          spotcolor, linecolor, modelcolor, meshcolor, color0, color1');
  disp('          labelsize, spotsize, linesize');
  disp(' simple');
  disp(' example: >> t=[0:0.1:6]; x=sin(2*t); y=cos(t); z=sin(t);');
  disp('          >> VRMLplot(x, y, z, t, ''title=test graph'') ');
  disp('          ans =');
  disp('          out.wrl');
  disp(' ');
  disp('          This creates a file out.wrl which you can view using netscape :')
  disp('          >> ! netscape out.wrl &')
  disp('          (The trailing ampersand may not work on non-unix machines)');
  disp('          After the first time you can just hit reload rather than');
  disp('          restarting Netscape for each new graph.');
  disp(' complex');
  disp(' example: >> L=[ 0.0 0.0 0.0; 1.0 pi/2 0.0; 2.0 pi/2 pi/2; 4.0 0.0 0.0 ];');
  disp('          >> VRMLplot(L, ''animation=robotTemplate.wrl'') ')
  disp('          ans =');
  disp('          out.wrl');
  disp(' ');
  disp(' Additional help and a copy of this code is available free of charge from:');
  disp('          http://www.dsl.whoi.edu/~sayers/VRMLplot');
  disp('          Version 1.2.1 copyright Craig Sayers and WHOI 1996,97');
  disp(' ');
  clear outfile;
  return;
end

NUM=0;
options=[];
outfile = 'out.wrl';
xtitle = ['X (meters)'];
ytitle = ['Y (meters)']; 
ztitle = ['Z (meters)'];
ttitle = ['T (seconds)'];
title = ['Created using Matlab and VRMLplot v1.2.1'];
xscale=-1;
yscale=-1;
zscale=-1;
tscale=1;
xmin=NaN;xstep=NaN;xmax=NaN;
ymin=NaN;ystep=NaN;ymax=NaN;
zmin=NaN;zstep=NaN;zmax=NaN;
tmin=NaN;tstep=NaN;tmax=NaN;
animatewrl=[];
coldefs=[];
spotsize=NaN;
linesize=NaN;
labelsize=NaN;
modelcolor = [0.4 0.5 0.6];
linecolor = [0.1 0.7 0.1];
spotcolor = [0.1 0.9 0.1];
meshcolor = [ 0.1 0.1 0.1];
color1 = [0.4 0.4 0.7];
color0 = color1 .* 0.05;

LINE=3; ANIMATEPOINT=4; SURFACE=6; ANIMATEWRL=7; ANIMATEVIEW=8;

stylemode = LINE;
appendmode=0;
textmode=1;
controlbarmode=1;
shadowmode=1;
meshmode=0;

global FORMAT_TIME; 
global FORMAT_TRANSX;
global FORMAT_TRANSY;
global FORMAT_TRANSZ;
global FORMAT_TRANSXYZ;
global FORMAT_ROTX;
global FORMAT_ROTY;
global FORMAT_ROTZ;
global FORMAT_SCALAR;

FORMAT_TIME=1; 
FORMAT_TRANSX=2;
FORMAT_TRANSY=3;
FORMAT_TRANSZ=4;
FORMAT_TRANSXYZ=5;
FORMAT_ROTX=6;
FORMAT_ROTY=7;
FORMAT_ROTZ=8;
FORMAT_SCALAR=9;

formatDescriptions = [ 'one column for time                         ';
                       'one column for a 1-D translation            ';
                       'one column for a 1-D translation            ';
                       'one column for a 1-D translation            ';
                       'three columns for a 3-D translation         ';
                       'one column for a rotation about a fixed axis';
                       'one column for a rotation about a fixed axis';
                       'one column for a rotation about a fixed axis';
                       'one column for a scalar                     ';];
%
% each axis is described by a vector containing:
% note all values are in original units - multiply by scale
% to get world coordinate units.
MIN=1;
STEP=2;
MAX=3;
SIZE=4;
SCALE=5;

NEEDTIMEBAR=0;

if nargin > 5
  disp(' ');
  disp(['VRMLplot error - invalid number of arguments'])
  disp(' ');
  VRMLplot;
  clear outfile;
  return;
elseif nargin == 1
  Z=a;C=[];
  [m,n] = size(Z);
  x = [1:n];
  y = [1:m];
  [X,Y] = meshgrid(x,y);
  z = [min(min(Z)) max(max(Z))];
  stylemode=SURFACE;  
elseif nargin == 2
  Z=a;C=[];
  [m,n] = size(Z);
  options=b;
  x = [1:n];
  y = [1:m];
  [X,Y] = meshgrid(x,y);
  z = [min(min(Z)) max(max(Z))];
  stylemode=SURFACE;  
elseif nargin == 3
  [m,n] = size(c);
  if (m > 1 & n > 1)
    Z=c;C=[];
    if ( size(a,1)==1 & size(b,1) == 1 )
      [X,Y] = meshgrid(a,b);
    else
      X=a;Y=b;
    end
    x = [min(min(X)) max(max(X))];
    y = [min(min(Y)) max(max(Y))];
    z = [min(min(Z)) max(max(Z))];
    stylemode=SURFACE;  
  else
    x=a; y=b; z=c;
  end
elseif nargin == 4
  [m,n] = size(c);
  if (m > 1 & n > 1)
    Z=c;C=[];
    if ( size(a,1)==1 & size(b,1) == 1 )
      [X,Y] = meshgrid(a,b);
    else
      X=a;Y=b;
    end
    x = [min(min(X)) max(max(X))];
    y = [min(min(Y)) max(max(Y))];
    z = [min(min(Z)) max(max(Z))];
    stylemode=SURFACE;  
    if isstr(d)
      options=d;
    else
      C=d;
    end
  else
    x=a; y=b; z=c;
    if isstr(d)
      options=d;
    else
      t=d;
      NEEDTIMEBAR=1;
      stylemode=ANIMATEPOINT;
    end
  end
elseif nargin == 5
  [m,n] = size(c);
  if (m > 1 & n > 1)
    Z=c;C=d;
    if ( size(a,1)==1 & size(b,1) == 1 )
      [X,Y] = meshgrid(a,b);
    else
      X=a;Y=b;
    end
    x = [min(min(X)) max(max(X))];
    y = [min(min(Y)) max(max(Y))];
    z = [min(min(Z)) max(max(Z))];
    stylemode=SURFACE; 
    options=e;
  else
    x=a; y=b; z=c; t=d;
    options=e;
    NEEDTIMEBAR=1;
    stylemode=ANIMATEPOINT;
  end
end

%
% Check types and sizes of input parameters
%

[cx,rx] = size(x);
[cy,ry] = size(y);
[cz,rz] = size(z);
if isstr(x) | isstr(y) | isstr(z)
  disp(' ');
  disp(['VRMLplot error - x,y and z must contain numeric data (not strings).'])
  clear outfile;
  return;
elseif stylemode==ANIMATEPOINT & isstr(t)
  disp(' ');
  disp(['VRMLplot error - t must contain numeric data (not strings).'])
  clear outfile;
  return;
elseif stylemode == LINE & ( cx ~= 1 | rx < 2 )
  disp(' ');
  disp(['VRMLplot error - x data values must be of size [1,n] where n >= 2']);
  clear outfile;
  return;
elseif ( stylemode == LINE | stylemode == ANIMATEPOINT) & (cx ~= cy | rx ~= ry | cx ~= cz | rx ~= rz )
  disp(' ');
  disp(['VRMLplot error - x,y and z data values must be of equal size'])
  clear outfile;
  return;
elseif stylemode == ANIMATEPOINT & length(t) ~= rx
  disp(' ');
  disp(['VRMLplot error - x,y,z and t vectors must be of equal length.'])
  clear outfile;
  return;
elseif stylemode == SURFACE & ( size(Z,1)<2 | size(Z,2)<2 )
  disp(' ');
  disp(['VRMLplot error - Z matrix must have at least 2 rows and columns.'])
  clear outfile;
  return;
elseif stylemode == SURFACE & ( size(X,1) ~= size(Z,1) | size(X,2)~=size(Z,2))
  disp(' ');
  disp(['VRMLplot error - X and Z matrix sizes don''t match.'])
  clear outfile;
  return;
elseif stylemode == SURFACE & ( size(Y,1) ~= size(Z,1) | size(Y,2)~=size(Z,2))
  disp(' ');
  disp(['VRMLplot error - Y and Z matrix sizes don''t match.'])
  clear outfile;
  return;
end

%
% Parse option list
%
token=[]; value=[];
TOKEN=0; VALUE=1; type=TOKEN;
parseError=0;

for i=1:length(options)
  if type == TOKEN;
    if options(i) == '='
      type = VALUE;
    elseif options(i) == ';' | options(i) == ','
      disp(' ')
      disp('VRMLplot error reading option list');
      disp(['   "' token '" was not assigned a value']);
      disp('  correct form is ''option1=value1; option2=value2'' ');
      parseError=1;
      break;
    elseif options(i) ~= ' '
      token = [token options(i)];
    end
  else
    if options(i) == ';' | i == length(options)
      if i == length(options) & options(i) ~= ';'
        value = [value options(i)];
      end
      if isempty(token)
        disp(' ')
        disp('VRMLplot error reading option list');
        disp(['  "= ' value '" was not preceeded by any option label']);
        disp('  correct form is ''option1=value1; option2=value2'' ');
        parseError=1;
        break;
      elseif isempty(value)
        disp(' ')
        disp('VRMLplot error reading option list');
        disp(['   "' token ' =" was not followed by any option value']);
        disp('  correct form is ''option1=value1; option2=value2'' ');
        parseError=1;
        break;
      end
      %
      % Now set options
      %
      if strcmp(token,'animation') == 1
        if stylemode ~= SURFACE
           disp(' ')
           disp('VRMLplot error - an animation option was specified but the')
           disp('      input parameters are not consitent with an animation.')
           disp('      run VRMLplot; for help.')
           parseError=1;
           break;
         end
         NEEDTIMEBAR=1;
         stylemode=ANIMATEWRL;
         animatewrl=value;
      elseif strcmp(token,'viewpoint') == 1
        if stylemode ~= SURFACE
           disp(' ')
           disp('VRMLplot error - an animated viewpoint was specified but the')
           disp('      input parameters are not consitent with an animation.')
           disp('      run VRMLplot; for help.')
           parseError=1;
           break;
         end
         stylemode=ANIMATEVIEW;
         NEEDTIMEBAR=1;
         animateview=value;
      elseif strcmp(token,'xlabel') == 1
         xtitle=value;
      elseif strcmp(token,'ylabel') == 1
         ytitle=value;
      elseif strcmp(token,'zlabel') == 1
         ztitle=value;
      elseif strcmp(token,'tlabel') == 1
         ttitle=value;
      elseif strcmp(token,'title') == 1
         title=value;
      elseif strcmp(token,'xscale') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         if str2num(value) <= 0
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be greater than zero.']);
           parseError=1;
           break;
         end
         xscale=str2num(value);
      elseif strcmp(token,'yscale') == 1
         if isempty(str2num(value)) 
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         if str2num(value) <= 0
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be greater than zero.']);
           parseError=1;
           break;
         end
         yscale=str2num(value);
      elseif strcmp(token,'zscale') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         if str2num(value) <= 0
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be greater than zero.']);
           parseError=1;
           break;
         end
         zscale=str2num(value);
      elseif strcmp(token,'tscale') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         if str2num(value) <= 0
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be greater than zero.']);
           parseError=1;
           break;
         end
         tscale=str2num(value);
      elseif strcmp(token,'xmin') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         xmin=str2num(value);
      elseif strcmp(token,'ymin') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         ymin=str2num(value);
      elseif strcmp(token,'zmin') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         zmin=str2num(value);
      elseif strcmp(token,'tmin') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         tmin=str2num(value);
      elseif strcmp(token,'xmax') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         xmax=str2num(value);
      elseif strcmp(token,'ymax') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         ymax=str2num(value);
      elseif strcmp(token,'zmax') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         zmax=str2num(value);
      elseif strcmp(token,'tmax') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         tmax=str2num(value);
      elseif strcmp(token,'xstep') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         xstep=str2num(value);
      elseif strcmp(token,'ystep') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         ystep=str2num(value);
      elseif strcmp(token,'zstep') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         zstep=str2num(value);
      elseif strcmp(token,'tstep') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         tstep=str2num(value);
      elseif strcmp(token,'append') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         appendmode=str2num(value);
      elseif strcmp(token,'shadow') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         shadowmode=str2num(value);
      elseif strcmp(token,'mesh') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         meshmode=str2num(value);
      elseif strcmp(token,'text') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         textmode=str2num(value);
      elseif strcmp(token,'controlbar') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         controlbarmode=str2num(value);
      elseif strcmp(token,'labelsize') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         labelsize=str2num(value);
      elseif strcmp(token,'spotsize') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         spotsize=str2num(value);
      elseif strcmp(token,'linesize') == 1
         if isempty(str2num(value))
           disp(' ')
           disp('VRMLplot error reading option list');
           disp(['  value for option: ' token ' must be a number.']);
           parseError=1;
           break;
         end
         linesize=str2num(value);
      elseif strcmp(token,'modelcolor') == 1 | strcmp(token,'modelcolour') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         modelcolor = c;
      elseif strcmp(token,'linecolor') == 1 | strcmp(token,'linecolour') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         linecolor = c;
      elseif strcmp(token,'meshcolor') == 1 | strcmp(token,'meshcolour') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         meshcolor = c;
      elseif strcmp(token,'spotcolor') == 1 | strcmp(token,'spotcolour') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         spotcolor = c;
      elseif strcmp(token,'color0') == 1 | strcmp(token,'colour0') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         color0 = c;
      elseif strcmp(token,'color1') == 1 | strcmp(token,'colour1') == 1
         [c, count] = sscanf(value,'[%g %g %g]',[1 3]);
         if count ~= 3
           disp(' ')
           disp(['VRMLplot error reading option: ' token]);
           disp(['  expected format is: ' token '=[0.1 0.2 0.3]']);
           parseError=1;
           break;
         end
         color1 = c;
      else
        disp(' ')
        disp('VRMLplot error reading option list');
        disp(['  option: ' token ' not recognized.']);
        parseError=1;
        break;
      end
      token=[];value=[];
      type = TOKEN;
    else
      value = [value options(i)];
      if options(i) == ','
        disp(' ')
        disp(['VRMLplot warning - the value of option:' token ' contains a ","']);
        disp('  this is legal, but may not be what you intend.');
        disp('  usual form is ''option1=value1; option2=value2'' ');
      end
    end
  end
end
if ~isempty(token) & parseError == 0
  disp('VRMLplot error reading option list');
  disp(['  No value was assigned to option "' token '"']);
  disp('  correct form is ''option1=value1; option2=value2'' ');
  parseError=1;
end

if (stylemode == ANIMATEWRL | stylemode == ANIMATEVIEW ) & parseError==0
  if isnan(xmin) xmin=-2; end
  if isnan(ymin) ymin=-2; end
  if isnan(zmin) zmin=0; end
  if isnan(xstep) xstep=1; end
  if isnan(ystep) ystep=1; end
  if isnan(zstep) zstep=1; end
  if isnan(xmax) xmax=2; end
  if isnan(ymax) ymax=2; end
  if isnan(zmax) zmax=1; end
  if xscale==-1 xscale=1; end
  if yscale==-1 yscale=1; end
  if zscale==-1 zscale=1; end
  x = [];
  y = [];
  z = [];
  NEEDTIMEBAR=1;
  t=Z(:,1);
end

if parseError==1
  clear outfile;
  return;
end

%
% Compute suitable axes
%

if ~isempty(x) & ~isempty(y) & ~isempty(z)
  xaxis = VRMLca(x);
  yaxis = VRMLca(y,xaxis(STEP));
  zaxis = VRMLca(z,yaxis(STEP));
  xaxis = VRMLca(x,zaxis(STEP));
  yaxis = VRMLca(y,xaxis(STEP));
  zaxis = VRMLca(z,yaxis(STEP));
end

if( ~ isnan(xmin) )
  xaxis(MIN) = xmin;
end
if( ~ isnan(xstep) )
  xaxis(STEP) = xstep;
end
if( ~ isnan(xmax) )
  if( xmax <= xmin )
    disp(' ')
    disp(' VRMLplot - error specified xmax must be greater than xmin ')
    clear outfile;
    return
  end
  xaxis(MAX) = xmax;
end

if( ~ isnan(ymin) )
  yaxis(MIN) = ymin;
end
if( ~ isnan(ystep) )
  yaxis(STEP) = ystep;
end
if( ~ isnan(ymax) )
  if( ymax <= ymin )
    disp(' ')
    disp(' VRMLplot - error specified ymax must be greater than ymin ')
    clear outfile;
    return
  end
  yaxis(MAX) = ymax;
end

if( ~ isnan(zmin) )
  zaxis(MIN) = zmin;
end
if( ~ isnan(zstep) )
  zaxis(STEP) = zstep;
end
if( ~ isnan(zmax) )
  if( zmax <= zmin )
    disp(' ')
    disp(' VRMLplot - error specified zmax must be greater than zmin ')
    clear outfile;
    return
  end
  zaxis(MAX) = zmax;
end

if xscale == -1
   xaxis = [ xaxis (xaxis(MAX)-xaxis(MIN)) 1/(xaxis(MAX)-xaxis(MIN)) ];
else
   xaxis = [ xaxis (xaxis(MAX)-xaxis(MIN)) xscale ];
end

if yscale == -1
  yaxis = [ yaxis (yaxis(MAX)-yaxis(MIN)) 1/(yaxis(MAX)-yaxis(MIN)) ];
else
  yaxis = [ yaxis (yaxis(MAX)-yaxis(MIN)) yscale];
end

if zscale == -1
  zaxis = [ zaxis (zaxis(MAX)-zaxis(MIN)) 1/(zaxis(MAX)-zaxis(MIN)) ];
else
  zaxis = [ zaxis (zaxis(MAX)-zaxis(MIN)) zscale];
end

if( NEEDTIMEBAR==1 )
  taxis = VRMLca(t);
  if( ~ isnan(tmin) )
    taxis(MIN) = tmin;
  end
  if( ~ isnan(tstep) )
    taxis(STEP) = tstep;
  end
  if( ~ isnan(tmax) )
    taxis(MAX) = tmax;
  end
  diff = (taxis(MAX)-taxis(MIN));
  if tscale == -1
     taxis = [ taxis diff 1/diff ];
  else
     taxis = [ taxis diff tscale ];
  end
else
  taxis = [NaN NaN NaN NaN NaN];
end

if( xaxis(SIZE)*xaxis(SCALE) < 0.05 )
  disp(' ')
  disp(' VRMLplot warning - xsize and xscale values are such that the resulting')
  disp(' graph will be tiny in the x dimension - navigation/viewing may be')
  disp(' difficult - recommend setting larger scale values.')
end

if( yaxis(SIZE)*yaxis(SCALE) < 0.05 )
  disp(' ')
  disp(' VRMLplot warning - ysize and yscale values are such that the resulting')
  disp(' graph will be tiny in the y dimension - navigation/viewing may be')
  disp(' difficult - recommend setting larger scale values.')
end

if( zaxis(SIZE)*zaxis(SCALE) < 0.05 )
  disp(' ')
  disp(' VRMLplot warning - zsize and zscale values are such that the resulting')
  disp(' graph will be tiny in the z dimension - navigation/viewing may be')
  disp(' be difficult - recommend setting larger scale values.')
end

if( xaxis(SIZE)*xaxis(SCALE) > 200 )
  disp(' ')
  disp(' VRMLplot warning - xsize and xscale values are such that the resulting')
  disp(' graph will be huge in the x dimension - navigation/viewing may be')
  disp(' difficult - recommend setting smaller scale values.')
end

if( yaxis(SIZE)*yaxis(SCALE) > 200 )
  disp(' ')
  disp(' VRMLplot warning - ysize and yscale values are such that the resulting')
  disp(' graph will be huge in the y dimension - navigation/viewing may be')
  disp(' difficult - recommend setting smaller scale values.')
end

if( zaxis(SIZE)*zaxis(SCALE) > 200 )
  disp(' ')
  disp(' VRMLplot warning - zsize and zscale values are such that the resulting')
  disp(' graph will be huge in the z dimension - navigation/viewing may be')
  disp(' difficult - recommend setting smaller scale values.')
end

if( xaxis(SIZE)/xaxis(STEP) > 100 )
  disp(' ')
  disp(' VRMLplot warning - graph will require more than 100 grid lines in the x')
  disp(' direction recommend setting a larger xstep size.')
end

if( yaxis(SIZE)/yaxis(STEP) > 100 )
  disp(' ')
  disp(' VRMLplot warning - graph will require more than 100 grid lines in the y')
  disp(' direction - recommend setting a larger ystep size.')
end

if( zaxis(SIZE)/zaxis(STEP) > 100 )
  disp(' ')
  disp(' VRMLplot warning - graph will require more than 100 grid lines in the z')
  disp(' direction - recommend setting a larger zstep size.')
end

%
% If we're appending then open existing file and find out what we're
% appending to.
%
if appendmode==1
  [fid,errmsg] = fopen(outfile,'r');
  if fid == -1
    disp(' ');
    disp(['VRMLplot error - unable to open ' outfile ' for reading.'])
    clear outfile;
    return;
  end
  % Check for correct VRML string
  [vString, count] = fread(fid, 15, 'char');
  if( strcmp(setstr(vString'),'#VRML V2.0 utf8') == 0)
    disp(' ');
    disp(['VRMLplot error - append file:' outfile ' doesn''t start with "#VRML V2.0 utf8"']);
    error = -1;
    return;
  end
  c = 0;
  while( c ~= 10);
    [c, count] = fread(fid, 1, 'char');
  end;
  %
  % Check for VRMLplotA string
  %
  [vString, count] = fread(fid, 9, 'char');
  if( strcmp(setstr(vString'),'#VRMLplot') == 0)
    start = setstr(vString')
    disp(' ');
    disp(['VRMLplot warning - append file:' filename ' was not created with the latest']);
    disp(['                   version of VRMLplot.  You may need to manually specify']);
    disp(['                   axis scales.']);
  else
    c = 0;
    while( c ~= 10);
      [c, count] = fread(fid, 1, 'char');
    end;
    [xaxis, count] = fscanf(fid,'%*s %g %g %g %g %g',[5,1]);
    [yaxis, count] = fscanf(fid,'%*s %g %g %g %g %g',[5,1]);
    [zaxis, count] = fscanf(fid,'%*s %g %g %g %g %g',[5,1]);
    [taxis, count] = fscanf(fid,'%*s %g %g %g %g %g',[5,1]);
    if( ~isempty(taxis) )
      NEEDTIMEBAR=0;
    elseif NEEDTIMEBAR==1
        disp(' ');
        disp('VRMLplot error');
        disp(['  Sorry, can''t append an animation here (but you could create a']);
        disp(['  series of animations first and then append other things to them.)']);
        clear outfile;
        return;
    end
    %
    % now go to end of file and see how many graphs have already been added
    %
    fseek(fid,-18,1);
    [prev, count] = fscanf(fid,'%d %d',[2,1]);
    if count ~= 2
      disp('VRMLplot warning - end of existing out.wrl file doesn''t match expected')
      disp(' format.  It may not have been correctly written.');
      NUM=2;
    else
      NUM = prev(1)+1;
    end
  end
  fclose(fid);
end

x = x*xaxis(SCALE);
y = y*yaxis(SCALE);
z = z*zaxis(SCALE);

if isnan( spotsize ) == 1
spotsize = min([(xaxis(MAX)-xaxis(MIN))*xaxis(SCALE)/3,(yaxis(MAX)-yaxis(MIN))*yaxis(SCALE)/3,(zaxis(MAX)-zaxis(MIN))*zaxis(SCALE)/3,xaxis(STEP)*xaxis(SCALE),yaxis(STEP)*yaxis(SCALE),zaxis(STEP)*zaxis(SCALE)])/8;
end

epsilon = 0.005*min([(xaxis(MAX)-xaxis(MIN))*xaxis(SCALE),(yaxis(MAX)-yaxis(MIN))*yaxis(SCALE),(zaxis(MAX)-zaxis(MIN))*zaxis(SCALE),xaxis(STEP)*xaxis(SCALE),yaxis(STEP)*yaxis(SCALE),zaxis(STEP)*zaxis(SCALE)]);

%
% Now open and initialise file
%
if (appendmode==0)
  [fid,errmsg] = fopen(outfile,'w');
  if fid == -1
    disp(' ');
    disp(['VRMLplot error - unable to open ' outfile ' for writing.'])
    clear outfile;
    return;
  end
  fprintf(fid,'#VRML V2.0 utf8\n');
  fprintf(fid,'#VRMLplotA\n');
  fprintf(fid,'#X %g %g %g %g %g\n',xaxis(MIN),xaxis(STEP),xaxis(MAX),xaxis(SIZE),xaxis(SCALE));
  fprintf(fid,'#Y %g %g %g %g %g\n',yaxis(MIN),yaxis(STEP),yaxis(MAX),yaxis(SIZE),yaxis(SCALE));
  fprintf(fid,'#Z %g %g %g %g %g\n',zaxis(MIN),zaxis(STEP),zaxis(MAX),zaxis(SIZE),zaxis(SCALE));
  fprintf(fid,'#T %g %g %g %g %g\n',taxis(MIN),taxis(STEP),taxis(MAX),taxis(SIZE),taxis(SCALE));
  fprintf(fid,'# \n');
  fprintf(fid,'# Do not edit the above lines - VRMLplot needs them!\n');
  fprintf(fid,'# \n');
  fprintf(fid,'# IF YOU CAN READ THIS THEN:\n');
  fprintf(fid,'# 1) Your browser may not support VRML 2.0 - we recommend using the\n');
  fprintf(fid,'#  CosmoPlayer plugin which is free from http://vrml.sgi.com\n');
  fprintf(fid,'# 2) The webserver on which the file exists may not be correctly\n');
  fprintf(fid,'#  configured for VRML 2.0 files\n');
  fprintf(fid,'# 3) This file may not be correctly named - it should end in .wrl\n');
  fprintf(fid,'#\n');
  fprintf(fid,'# This file was generated using Matlab and VRMLplot version 1.2.1\n');
  fprintf(fid,'# VRMLplot is available free of charge from http://www.dsl.whoi.edu/~sayers/VRMLplot\n');
  fprintf(fid,'# VRMLplot is Copyright Craig Sayers and WHOI 1996,97.\n');
  fprintf(fid,'#\n');
  fprintf(fid,'WorldInfo\n');
  fprintf(fid,'{');
  fprintf(fid,'title "%s"\n',title);
  fprintf(fid,'info\n');
  fprintf(fid,'[');
  fprintf(fid,'"This file was generated using Matlab and VRMLplot version 1.2.1"\n');
  fprintf(fid,']');
  fprintf(fid,'}');
else
  [fid,errmsg] = fopen(outfile,'a');
  if fid == -1
    disp(' ');
    disp(['VRMLplot error - unable to open ' outfile ' for appending.'])
    clear outfile;
    return;
  end
end

fprintf(fid,'Transform\n');
fprintf(fid,'{');
fprintf(fid,'children \n');
fprintf(fid,'[');

if appendmode==0
  %
  % Compute suitable viewpoints
  %
  viewx = (xaxis(MIN)+xaxis(MAX))/2*xaxis(SCALE);
  viewy = (yaxis(MIN)+yaxis(MAX))/2*yaxis(SCALE);
  viewz = (zaxis(MIN)+zaxis(MAX))/2*zaxis(SCALE);
  viewDistD = (2.2+NEEDTIMEBAR*0.22)*mean([xaxis(SIZE)*xaxis(SCALE),yaxis(SIZE)*yaxis(SCALE),zaxis(SIZE)*zaxis(SCALE)]);
  viewDistX = (2.2+NEEDTIMEBAR*0.22)*mean([yaxis(SIZE)*yaxis(SCALE),zaxis(SIZE)*zaxis(SCALE)]);
  viewDistY = (2.2+NEEDTIMEBAR*0.22)*mean([xaxis(SIZE)*xaxis(SCALE),zaxis(SIZE)*zaxis(SCALE)]);
  viewDistZ = (2.2+NEEDTIMEBAR*0.22)*mean([xaxis(SIZE)*xaxis(SCALE),yaxis(SIZE)*yaxis(SCALE)]);
  %
  % Add viewpoint transforms
  %
  fprintf(fid,'DEF viewDefault Viewpoint\n');
  fprintf(fid,'{');
  fprintf(fid,'orientation -0.497412 -0.850208 -0.172416  0.850023\n');
  fprintf(fid,'position %g %g %g\n',-viewDistD/2.2*1.5708+viewx,viewz+viewDistD/2.2*(0.95+NEEDTIMEBAR*0.05),-viewy+viewDistD/2.2*1.75);
  fprintf(fid,'fieldOfView 0.785398\n');
  fprintf(fid,'description "Default View YX"\n');
  fprintf(fid,'}');
  fprintf(fid,'DEF viewDefault2 Viewpoint\n');
  fprintf(fid,'{');
  fprintf(fid,'orientation	-0.416081 0.880749 0.226179  1.12297\n');
  fprintf(fid,'position %g %g %g\n',viewDistD/2.2*1.97+viewx,viewDistD/2.2*1.1*(1+NEEDTIMEBAR*0.05)+viewz,viewDistD/2.2*1.2-viewy);
  fprintf(fid,'fieldOfView 0.785398\n');
  fprintf(fid,'description "Default View XY"\n');
  fprintf(fid,'}');
  fprintf(fid,'DEF viewX Viewpoint\n');
  fprintf(fid,'{');
  fprintf(fid,'orientation 0 1 0 1.5708\n');
  fprintf(fid,'position %g %g %g\n',(1+NEEDTIMEBAR*0.05)*viewDistX+viewx,viewz+NEEDTIMEBAR*0.05*viewDistX,-viewy);
  fprintf(fid,'fieldOfView 0.785398\n');
  fprintf(fid,'description "View down X axis"\n');
  fprintf(fid,'}');
  fprintf(fid,'DEF viewY Viewpoint\n');
  fprintf(fid,'{');
  fprintf(fid,'orientation 1 0 0 0\n');
  fprintf(fid,'position %g %g %g\n',viewx,viewz+NEEDTIMEBAR*0.05*viewDistY,-viewy+(1+0.05*NEEDTIMEBAR)*viewDistY);
  fprintf(fid,'fieldOfView 0.785398\n');
  fprintf(fid,'description "View down -Y axis"\n');
  fprintf(fid,'}');
  fprintf(fid,'DEF viewZ Viewpoint\n');
  fprintf(fid,'{');
  fprintf(fid,'orientation -1 0 0 1.5708\n');
  fprintf(fid,'position %g %g %g\n',viewx,(1.1-NEEDTIMEBAR*0.05)*viewDistZ+viewz,-viewy-NEEDTIMEBAR*0.125);
  fprintf(fid,'fieldOfView 0.785398\n');
  fprintf(fid,'description "View down Z axis"\n');
  fprintf(fid,'}');
  fprintf(fid,'NavigationInfo { headlight FALSE type "EXAMINE" avatarSize [0.25 1.6 0.75] }');
end

if ( NEEDTIMEBAR==1 )
  fprintf(fid,'DEF TimeSource TimeSensor { cycleInterval %g}\n',(taxis(MAX)-taxis(MIN))*taxis(SCALE));
  fprintf(fid,'DEF InitTime Script\n');
  fprintf(fid,'{ \n');
  fprintf(fid,'  eventIn SFTime worldCreated\n');
  fprintf(fid,'  eventOut SFFloat reset\n');
  fprintf(fid,'  url "vrmlscript: function worldCreated() { reset=0; }"\n');
  fprintf(fid,'}\n');
  fprintf(fid,'DEF InitSensor ProximitySensor { center %g %g %g size %g %g %g } \n',viewx, viewz, -viewy, 4*viewDistD,4*viewDistD,4*viewDistD);
  fprintf(fid,'Group \n');
  fprintf(fid,'{ \n');
  fprintf(fid,'  ROUTE InitSensor.enterTime TO InitTime.worldCreated \n');
  fprintf(fid,'}\n');
end

fprintf(fid,'DirectionalLight { direction 0 -0.9539 0.3 ambientIntensity 0.25 intensity 0.9682}');
fprintf(fid,'Transform\n');
fprintf(fid,'{');
fprintf(fid,'rotation 1 0 0 -1.5708\n');
fprintf(fid,'children \n');
fprintf(fid,'[');

%
% Plot interactive axes
%
if appendmode==0
  VRMLps(fid,textmode,xaxis,xtitle,yaxis,ytitle,zaxis,ztitle,labelsize);
end

%
% Now plot points in graph
%

if( stylemode==LINE | stylemode == ANIMATEPOINT )

  fprintf(fid,'Group\n');
  fprintf(fid,'{');
  fprintf(fid,'PROTO Spot_%d []\n',NUM);
  fprintf(fid,'{\n');
  fprintf(fid,'  LOD\n');
  fprintf(fid,'  {\n');
  fprintf(fid,'    center 0 0 0\n');
  fprintf(fid,'    range [ %g ]\n',spotsize*140);
  fprintf(fid,'    level\n');
  fprintf(fid,'    [\n');
  fprintf(fid,'      Shape\n');
  fprintf(fid,'      {\n');
  fprintf(fid,'        geometry Sphere { radius %g}\n',spotsize);
  fprintf(fid,'        appearance Appearance\n');
  fprintf(fid,'        {\n');
  fprintf(fid,'          material Material { diffuseColor %g %g %g emissiveColor %g %g %g}\n',spotcolor(1),spotcolor(2),spotcolor(3),0.05*spotcolor(1),0.05*spotcolor(2),0.05*spotcolor(3));
  fprintf(fid,'        }\n');
  fprintf(fid,'      }\n');
  fprintf(fid,'      Shape\n');
  fprintf(fid,'      {\n');
  fprintf(fid,'        geometry IndexedFaceSet\n');
  fprintf(fid,'        {\n');
  fprintf(fid,'          coord Coordinate\n');
  fprintf(fid,'          { point [ 0 %g 0,-%g 0 0,0 0 %g,\n',spotsize,spotsize,spotsize);
  fprintf(fid,'          %g 0 0, 0 0 -%g, 0 -%g 0 ] }\n',spotsize,spotsize,spotsize);
  fprintf(fid,'          coordIndex	[ 0, 1, 2, -1, 0, 2, 3, -1,\n');
  fprintf(fid,'          0, 3, 4, -1, 0, 4, 1, -1,\n');
  fprintf(fid,'          5, 2, 1, -1, 5, 3, 2, -1,\n');
  fprintf(fid,'          5, 4, 3, -1, 5, 1, 4, -1 ]\n');
  fprintf(fid,'          creaseAngle 0.5\n');
  fprintf(fid,'        }\n');
  fprintf(fid,'        appearance Appearance\n');
  fprintf(fid,'        {\n');
  fprintf(fid,'          material Material { diffuseColor %g %g %g emissiveColor %g %g %g}\n',spotcolor(1),spotcolor(2),spotcolor(3),0.05*spotcolor(1),0.05*spotcolor(2),0.05*spotcolor(3));
  fprintf(fid,'        }\n');
  fprintf(fid,'      }\n');
  fprintf(fid,'    ]\n');
  fprintf(fid,'  }\n');
  fprintf(fid,'}\n');

  if shadowmode~=0  
    fprintf(fid,'PROTO Shadow_%d []\n',NUM);
    fprintf(fid,'{\n');
    fprintf(fid,'  LOD\n');
    fprintf(fid,'  {\n');
    fprintf(fid,'    center 0 0 0\n');
    fprintf(fid,'    range [ %g ]\n',spotsize*140);
    fprintf(fid,'    level\n');
    fprintf(fid,'    [\n');
    for faces=[20 4]
      fprintf(fid,'      Shape\n');
      fprintf(fid,'      {\n');
      fprintf(fid,'        geometry IndexedFaceSet\n');
      fprintf(fid,'        {\n');
      fprintf(fid,'          coord Coordinate\n');
      fprintf(fid,'          { point [\n');
      for v=[0:2*pi/faces:2*pi-0.001]
        fprintf(fid,'               %g %g 0,\n',cos(v)*spotsize,sin(v)*spotsize);
      end
      fprintf(fid,'          ] }\n');
      fprintf(fid,'          coordIndex	[\n');
      for v=[0:faces-1]
        fprintf(fid,'          %g\n',v);
      end
      fprintf(fid,'          0 -1 ]\n',v);
      fprintf(fid,'          \n');
      fprintf(fid,'          creaseAngle 0.5\n');
      fprintf(fid,'        }\n');
      fprintf(fid,'        appearance Appearance\n');
      fprintf(fid,'        {\n');
      fprintf(fid,'          material Material { diffuseColor 0.01 0.01 0.01 transparency 0.6 }\n');
      fprintf(fid,'        }\n');
      fprintf(fid,'      }\n');
    end
    fprintf(fid,'    ]\n');
    fprintf(fid,'  }\n');
    fprintf(fid,'}\n');
  end 
  fprintf(fid,'}\n');

  if linesize ~= 0.0
    fprintf(fid,'Transform\n');
    fprintf(fid,'{');
    fprintf(fid,'children\n');
    fprintf(fid,'[');
    for s=1:100:length(x)
      fprintf(fid,'Shape\n');
      fprintf(fid,'{');
      fprintf(fid,'geometry IndexedLineSet');
      fprintf(fid,'{');
      fprintf(fid,'colorPerVertex FALSE\n');
      fprintf(fid,'coord Coordinate\n');
      fprintf(fid,'{');
      fprintf(fid,'point\n');
      fprintf(fid,'[');
      for i=s:min(s+101,length(x))
       fprintf(fid,' %g %g %g,\n',x(i),y(i),z(i)+epsilon);
      end
      fprintf(fid,']');
      fprintf(fid,'}');
      fprintf(fid,'coordIndex\n');
      fprintf(fid,'[');
      for i=0:min(100,length(x)-s)
       fprintf(fid,'%g\n',i);
      end
      fprintf(fid,'-1\n');
      fprintf(fid,']');
      fprintf(fid,'color Color { color [ %g %g %g]}',linecolor(1),linecolor(2),linecolor(3));
      fprintf(fid,'colorIndex\n');
      fprintf(fid,'[');
      fprintf(fid,'0\n');
      fprintf(fid,']');
      fprintf(fid,'}');
      fprintf(fid,'}');

      if shadowmode~=0  
        fprintf(fid,'Shape\n');
        fprintf(fid,'{');
        fprintf(fid,'geometry IndexedLineSet');
        fprintf(fid,'{');
        fprintf(fid,'colorPerVertex FALSE\n');
        fprintf(fid,'coord Coordinate\n');
        fprintf(fid,'{');
        fprintf(fid,'point\n');
        fprintf(fid,'[');
        for i=s:min(s+101,length(x))
         fprintf(fid,' %g %g %g,\n',x(i),y(i),zaxis(MIN)*zaxis(SCALE)+epsilon);
        end
        fprintf(fid,']');
        fprintf(fid,'}');
        fprintf(fid,'coordIndex\n');
        fprintf(fid,'[');
        for i=0:min(100,length(x)-s)
         fprintf(fid,'%g\n',i);
        end
        fprintf(fid,'-1\n');
        fprintf(fid,']');
        fprintf(fid,'color Color { color [ 0.05 0.05 0.05]}');
        fprintf(fid,'colorIndex\n');
        fprintf(fid,'[');
        fprintf(fid,'0\n');
        fprintf(fid,']');
        fprintf(fid,'}');
        fprintf(fid,'}');
      end
    end
    fprintf(fid,']');
    fprintf(fid,'}');
  end
  if stylemode~=ANIMATEPOINT
    if spotsize > 0
      for i=1:length(x)
        fprintf(fid,'Transform\n');
        fprintf(fid,'{');
        fprintf(fid,'translation %g %g %g ',x(i),y(i),z(i));
        fprintf(fid,'children [ Spot_%d {} ]\n',NUM);
        fprintf(fid,'}');
      end
      if shadowmode ~= 0
        for i=1:length(x)
          if( z(i) > epsilon+zaxis(MIN)*zaxis(SCALE) )
            fprintf(fid,'Transform\n');
            fprintf(fid,'{');
            fprintf(fid,'translation %g %g %g\n',x(i),y(i),zaxis(MIN)*zaxis(SCALE)+epsilon);
            fprintf(fid,'children [ Shadow_%d {} ]\n',NUM);
            fprintf(fid,'}\n');
          end
        end
      end
    end
  else
    fprintf(fid,'DEF SpotTransform_%d Transform\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'translation %g %g %g\n',x(1),y(1),z(1));
    fprintf(fid,'children\n');
    fprintf(fid,'[');
    fprintf(fid,'DEF SpotTransform2_%d Transform\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'children\n');
    fprintf(fid,'[');
    fprintf(fid,'DEF viewSpot_%d Viewpoint\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'orientation 1 0 0 1.5708\n');
    fprintf(fid,'position %g %g %g\n',0,-spotsize*15,0);
    if NUM==0
      fprintf(fid,'description "View from spot"\n');
    else
      fprintf(fid,'description "View from spot %d"\n',NUM);
    end
    fprintf(fid,'}');
    if spotsize > 0
      fprintf(fid,'DEF Spot_%d Shape\n',NUM);
      fprintf(fid,'{ \n');
      fprintf(fid,'geometry Sphere { radius %g } \n',spotsize);
      fprintf(fid,'appearance Appearance\n');
      fprintf(fid,'{');
      fprintf(fid,'          material Material { diffuseColor %g %g %g emissiveColor %g %g %g}\n',spotcolor(1),spotcolor(2),spotcolor(3),0.05*spotcolor(1),0.05*spotcolor(2),0.05*spotcolor(3));
      fprintf(fid,'}');
      fprintf(fid,'}');
    end
    fprintf(fid,'DEF Animation_%d PositionInterpolator\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'key [');
    for i=1:length(x)
      fprintf(fid,'%g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
    end
    fprintf(fid,']');
    fprintf(fid,'keyValue [');
    for i=1:length(x)
      fprintf(fid,'%g %g %g\n',x(i),y(i),z(i));
    end
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,'DEF spotPlayTS_%d TouchSensor {},\n',NUM);
    fprintf(fid,'DEF AnimatePan_%d OrientationInterpolator\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'key [');
    for i=1:length(x)-1
      fprintf(fid,'%g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
    end
    fprintf(fid,']');
    fprintf(fid,'keyValue [');
    for i=1:length(x)-1
      fprintf(fid,'%g %g %g %g\n',0,0,1,-pi/2+atan2((y(i+1)-y(i)),(x(i+1)-x(i))));
    end
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,'DEF AnimateTilt_%d OrientationInterpolator\n',NUM);
    fprintf(fid,'{');
    fprintf(fid,'key [');
    for i=1:length(x)-1
      fprintf(fid,'%g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
    end
    fprintf(fid,']');
    fprintf(fid,'keyValue [');
    angle=0;
    for i=1:length(x)-1
      d = sqrt(((x(i+1)-x(i))*1)^2+((y(i+1)-y(i))*1)^2);
      if d ~= 0
        angle = atan((z(i+1)-z(i))/d);
      end
      zpos = (z(i+1)-zaxis(MIN)*zaxis(SCALE))*1-15*spotsize*sin(angle);
      if zpos < spotsize*4
        angle = asin( (spotsize*4-(z(i+1)-zaxis(MIN)*zaxis(SCALE))*1)/(-15*spotsize));
      end
      fprintf(fid,'%g %g %g %g\n',1,0,0,angle);
    end
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,']');
    fprintf(fid,'}');
    if spotsize > 0
      if shadowmode ~= 0
        fprintf(fid,'DEF ShadowTransform_%d Transform\n',NUM);
        fprintf(fid,'{');
        fprintf(fid,'translation %g %g %g\n',x(1),y(1),zaxis(MIN)*zaxis(SCALE)+epsilon);
        fprintf(fid,'scale %g %g %g\n',1 - 0.3*(z(1)/zaxis(SCALE)-zaxis(MIN))/(zaxis(MAX)-zaxis(MIN)),1 - 0.3*(z(1)/zaxis(SCALE)-zaxis(MIN))/(zaxis(MAX)-zaxis(MIN)),0.00001);
    
        fprintf(fid,'children\n');
        fprintf(fid,'[');
        fprintf(fid,'Shape\n');
        fprintf(fid,'{ \n');
        fprintf(fid,'geometry Sphere { radius %g}\n',spotsize);
        fprintf(fid,'appearance Appearance\n');
        fprintf(fid,'{');
        fprintf(fid,'material Material { diffuseColor 0.1 0.1 0.1 transparency 0.6 }');
        fprintf(fid,'}');
        fprintf(fid,'}');
        fprintf(fid,'DEF ShadowAnimation_%d PositionInterpolator\n',NUM);
        fprintf(fid,'{');
        fprintf(fid,'key [');
        for i=1:length(x)
          fprintf(fid,'%g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
        end
        fprintf(fid,']');
        fprintf(fid,'keyValue [');
        for i=1:length(x)
          fprintf(fid,'%g %g %g\n',x(i),y(i),zaxis(MIN)*zaxis(SCALE)+epsilon);
        end
        fprintf(fid,']');
        fprintf(fid,'}');
        fprintf(fid,'DEF ShadowRadius_%d PositionInterpolator\n',NUM);
        fprintf(fid,'{');
        fprintf(fid,'key [');
        for i=1:length(x)
          fprintf(fid,'%g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
        end
        fprintf(fid,']');
        fprintf(fid,'keyValue [');
        for i=1:length(x)
          fprintf(fid,'%g %g %g\n',1 - 0.3*(z(i)/zaxis(SCALE)-zaxis(MIN))/(zaxis(MAX)-zaxis(MIN)),1 - 0.3*(z(i)/zaxis(SCALE)-zaxis(MIN))/(zaxis(MAX)-zaxis(MIN)),epsilon);
        end
        fprintf(fid,']');
        fprintf(fid,'}');
        fprintf(fid,']');
        fprintf(fid,'}');
      end
    end
  end

elseif stylemode==ANIMATEWRL

  fprintf(fid,'Transform\n');
  fprintf(fid,'{');
  fprintf(fid,'  translation 0 0 %g\n',epsilon);
  fprintf(fid,'  scale %g %g %g',xaxis(SCALE),yaxis(SCALE),zaxis(SCALE));
  fprintf(fid,'  children\n');
  fprintf(fid,'  [');
  % construct name for prototype in animatewrl file - assume same name as file
  prototype = [];
  for i=length(animatewrl)-4:-1:1
    if animatewrl(i)=='/' | animatewrl(i) == '\'
       break;
    end
    prototype = [ animatewrl(i) prototype ];
  end
  % Copy file describing world to be animated into the output file.
  [error,colDefTypes,colDefNames] = VRMLcf(fid,animatewrl,prototype);
  if error ~= 0
    clear outfile;
    return;
  end;
  fprintf(fid,'    DEF VRMLplotModel_%d \n',NUM);
  fprintf(fid,'        %s { color %g %g %g transparency 0.0 }\n',setstr(prototype),modelcolor(1),modelcolor(2),modelcolor(3));

  col=1;
  for d=1:length(colDefTypes)
    col = col+1;
    if( size(Z,2) < col )
      disp(' ')
      disp([' VRMLplot error - matrix has only ' num2str(size(Z,2)) ' columns']);
      disp([' from file:' animatewrl ' it was expected there would be:']);
      disp(['    ' formatDescriptions(1,:)]);
      for i=1:length(colDefTypes)
        disp(['    ' formatDescriptions(colDefTypes(i),:)]);
      end
      clear outfile;
      return;
    end
    if colDefTypes(d) == FORMAT_TRANSXYZ | colDefTypes(d) == FORMAT_TRANSX | colDefTypes(d) == FORMAT_TRANSY | colDefTypes(d) == FORMAT_TRANSZ
      fprintf(fid,'      DEF Animation%g_%d PositionInterpolator\n',d,NUM);
      fprintf(fid,'      {\n');
      fprintf(fid,'        key [\n');
      for i=1:length(t)
        fprintf(fid,'        %g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
      end
      fprintf(fid,'        ]\n');
      fprintf(fid,'        keyValue [\n');
      if colDefTypes(d) == FORMAT_TRANSXYZ
        if( size(Z,2) < col+2 )
          disp(' ');
          disp([' VRMLplot error - matrix has only ' num2str(size(Z,2)) ' columns']);
          disp([' from file:' animatewrl ' it was expected there would be:']);
          disp(['    ' formatDescriptions(1,:)]);
          for i=1:length(colDefTypes)
            disp(['    ' formatDescriptions(colDefTypes(i),:)]);
          end
          clear outfile;
          return;
        end
        zinit = [ num2str(Z(1,col)) ' ' num2str(Z(1,col+1)) ' ' num2str(Z(1,col+2))];
        for i=1:length(t)
          fprintf(fid,'        %g %g %g \n',Z(i,col),Z(i,col+1),Z(i,col+2));
        end
      elseif colDefTypes(d) == FORMAT_TRANSX
        zinit = [ num2str(Z(1,col)) ' 0 0'];
        for i=1:length(t)
          fprintf(fid,'        %g 0 0 \n',Z(i,col));
        end
      elseif colDefTypes(d) == FORMAT_TRANSY
        zinit = [ '0 ' num2str(Z(1,col)) ' 0'];
        for i=1:length(t)
          fprintf(fid,'        0 %g 0 \n',Z(i,col));
        end
      else
        zinit = [ '0 0 ' num2str(Z(1,col))];
        for i=1:length(t)
          fprintf(fid,'        0 0 %g \n',Z(i,col));
        end
      end
      fprintf(fid,'        ]');
      fprintf(fid,'      }');
      fprintf(fid,'DEF InitAnim%g_%d Script { field SFVec3f initVal %s eventOut SFVec3f value url "vrmlscript: function initialize() { value=initVal; }"}',d,NUM,zinit);
    elseif colDefTypes(d) == FORMAT_ROTX | colDefTypes(d) == FORMAT_ROTY | colDefTypes(d) == FORMAT_ROTZ
      fprintf(fid,'      DEF Animation%g_%d OrientationInterpolator\n',d,NUM);
      fprintf(fid,'      {\n');
      fprintf(fid,'        key [\n');
      for i=1:length(t)
        fprintf(fid,'        %g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
      end
      fprintf(fid,'        ]\n');
      fprintf(fid,'        keyValue [\n');
      if colDefTypes(d) == FORMAT_ROTX
        zinit = [ '1 0 0 ' num2str(Z(1,col))];
        for i=1:length(t)
          fprintf(fid,'        1 0 0 %g\n',Z(i,col));
        end
      elseif colDefTypes(d) == FORMAT_ROTY
        zinit = [ '0 1 0 ' num2str(Z(1,col))];
        for i=1:length(t)
          fprintf(fid,'        0 1 0 %g\n',Z(i,col));
        end
      else
        zinit = [ '0 0 1 ' num2str(Z(1,col))];
        for i=1:length(t)
          fprintf(fid,'        0 0 1 %g\n',Z(i,col));
        end
      end
      fprintf(fid,'        ]');
      fprintf(fid,'      }');
      fprintf(fid,'DEF InitAnim%g_%d Script { field SFRotation initVal %s eventOut SFRotation value url "vrmlscript: function initialize() { value=initVal; }"}',d,NUM,zinit);
    elseif colDefTypes(d) == FORMAT_SCALAR
      fprintf(fid,'      DEF Animation%g_%d ScalarInterpolator\n',d,NUM);
      fprintf(fid,'      {\n');
      fprintf(fid,'        key [\n');
      for i=1:length(t)
        fprintf(fid,'        %g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
      end
      fprintf(fid,'        ]\n');
      fprintf(fid,'        keyValue [\n');
      zinit = [ num2str(Z(1,col))];
      for i=1:length(t)
        fprintf(fid,'        %g\n',Z(i,col));
      end
      fprintf(fid,'        ]');
      fprintf(fid,'      }');
      fprintf(fid,'DEF InitAnim%g_%d Script { field SFFloat initVal %s eventOut SFFloat value url "vrmlscript: function initialize() { value=initVal; }"}',d,NUM,zinit);
    end
    fprintf(fid,'Group{ROUTE Animation%g_%d.value_changed TO VRMLplotModel_%d.%s\n',d,NUM,NUM,colDefNames(d,:));
    fprintf(fid,'ROUTE InitAnim%g_%d.value TO VRMLplotModel_%d.%s\n',d,NUM,NUM,colDefNames(d,:));
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO Animation%g_%d.set_fraction\n',d,NUM);
    fprintf(fid,'ROUTE InitTime.reset TO Animation%g_%d.set_fraction}\n',d,NUM);
    if colDefTypes(d) == FORMAT_TRANSXYZ
      col = col+2;
    end
  end
  if col ~= size(Z,2)
    disp(' ')
    disp(['VRMLplot warning - ' num2str(col) ' columns were expected but the input matrix'])
    disp([' contains ' num2str(size(Z,2)) '. Extra columns will be ignored.'])
    disp(' ')
    disp([' From file:' animatewrl ' it was expected there would be:']);
    disp(['    ' formatDescriptions(1,:)]);
    for i=1:length(colDefTypes)
      disp(['    ' formatDescriptions(colDefTypes(i),:)]);
    end
  end
  fprintf(fid,'  ]');
  fprintf(fid,'}');

elseif stylemode==ANIMATEVIEW

  fprintf(fid,'Transform\n');
  fprintf(fid,'{');
  fprintf(fid,'  translation 0 0 %g\n',epsilon);
  fprintf(fid,'  scale %g %g %g',xaxis(SCALE),yaxis(SCALE),zaxis(SCALE));
  fprintf(fid,'  children\n');
  fprintf(fid,'  [');
  fprintf(fid,'    DEF VRMLplotViewT_%d Transform ',NUM);
  fprintf(fid,'    {\n');
  fprintf(fid,'      translation 0 0 0\n');
  fprintf(fid,'      rotation 0 0 1 0\n');
  fprintf(fid,'      children DEF VRMLplotView_%d Viewpoint\n',NUM);
  fprintf(fid,'      {\n');
  fprintf(fid,'        position 0 0 0\n');
  fprintf(fid,'        orientation 0 0 1 0\n');
  fprintf(fid,'        fieldOfView  0.785398\n');
  fprintf(fid,'        description "%s"\n',animateview);
  fprintf(fid,'      }\n');
  fprintf(fid,'    }\n');
  if( size(Z,2) < 8 )
    disp(' ')
    disp([' VRMLplot error - matrix has only ' num2str(size(Z,2)) ' columns']);
    disp([' for controlling camera viewpoint it was expected there would be 8.']);
    clear outfile;
    return;
  end
  fprintf(fid,'      DEF AnimViewTrans_%d PositionInterpolator\n',NUM);
  fprintf(fid,'      {\n');
  fprintf(fid,'        key [\n');
  for i=1:length(t)
    fprintf(fid,'        %g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
  end
  fprintf(fid,'        ]\n');
  fprintf(fid,'        keyValue [\n');
  zinit = [ num2str(Z(1,2)) ' ' num2str(Z(1,3)) ' ' num2str(Z(1,4))];
    for i=1:length(t)
      fprintf(fid,'        %g %g %g \n',Z(i,2),Z(i,3),Z(i,4));
    end
  fprintf(fid,'        ]');
  fprintf(fid,'      }');
  fprintf(fid,'DEF InitAnimViewTrans_%d Script { field SFVec3f initVal %s eventOut SFVec3f value url "vrmlscript: function initialize() { value=initVal; }"}',NUM,zinit);
  fprintf(fid,'      DEF AnimViewRot_%d OrientationInterpolator\n',NUM);
  fprintf(fid,'      {\n');
  fprintf(fid,'        key [\n');
  for i=1:length(t)
    fprintf(fid,'        %g,\n',(t(i)-taxis(MIN))/(taxis(MAX)-taxis(MIN)));
  end
  fprintf(fid,'        ]\n');
  fprintf(fid,'        keyValue [\n');
  zinit = [ num2str(Z(1,5)) ' ' num2str(Z(1,6)) ' ' num2str(Z(1,7)) ' ' num2str(Z(1,8))];
    for i=1:length(t)
      fprintf(fid,'        %g %g %g %g\n',Z(i,5),Z(i,6),Z(i,7),Z(i,8));
    end
  fprintf(fid,'        ]');
  fprintf(fid,'      }');
  fprintf(fid,'DEF InitAnimViewRot_%d Script { field SFRotation initVal %s eventOut SFRotation value url "vrmlscript: function initialize() { value=initVal; }"}',NUM,zinit);
  fprintf(fid,'Group{ROUTE AnimViewTrans_%d.value_changed TO VRMLplotViewT_%d.set_translation\n',NUM,NUM);
  fprintf(fid,'ROUTE InitAnimViewTrans_%d.value TO VRMLplotViewT_%d.set_translation\n',NUM,NUM);
  fprintf(fid,'ROUTE TimeSource.fraction_changed TO AnimViewTrans_%d.set_fraction\n',NUM);
  fprintf(fid,'ROUTE InitTime.reset TO AnimViewTrans_%d.set_fraction}\n',NUM);
  fprintf(fid,'Group{ROUTE AnimViewRot_%d.value_changed TO VRMLplotViewT_%d.set_rotation\n',NUM,NUM);
  fprintf(fid,'ROUTE InitAnimViewRot_%d.value TO VRMLplotViewT_%d.set_rotation\n',NUM,NUM);
  fprintf(fid,'ROUTE TimeSource.fraction_changed TO AnimViewRot_%d.set_fraction\n',NUM);
  fprintf(fid,'ROUTE InitTime.reset TO AnimViewRot_%d.set_fraction}\n',NUM);
  fprintf(fid,'  ]');
  fprintf(fid,'}');

elseif stylemode==SURFACE

  disp(' VRMLplot: generating surface plot, this may take a while...');
  %
  % If graph is a surface and no colors were specified, then compute them
  % now using height as fraction of Z axis to choose coloring
  %
  if isempty(C)
    for j=1:size(Z,2)
      for i=1:size(Z,1)
        C(i,j) = (Z(i,j)-zaxis(MIN))/(zaxis(MAX)-zaxis(MIN));
      end
    end
  end

  % Scale points in graph
  X = X * xaxis(SCALE);
  Y = Y * yaxis(SCALE);
  Z = Z * zaxis(SCALE);

  disp('           (computing surface normals)');

  % Now compute normals for each face, we do it here because:
  % we want to break surface up into several patches and this way the
  % colors will be smooth across the joints.

  Nx = zeros(size(Z));
  Ny = zeros(size(Z));
  Nz = zeros(size(Z));

  for j=1+1:size(Z,2)-1
    for i=1+1:size(Z,1)-1
      p11 = [ X(i,j) Y(i,j) Z(i,j) ];
      p12 = [ X(i,j+1) Y(i,j+1) Z(i,j+1) ];
      p21 = [ X(i+1,j) Y(i+1,j) Z(i+1,j) ];
      p10 = [ X(i,j-1) Y(i,j-1) Z(i,j-1) ];
      p01 = [ X(i-1,j) Y(i-1,j) Z(i-1,j) ];
      p1 = p12-p11;
      p2 = p21-p11;
      p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
      p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
      n1 = cross(p1,p2);
      p1 = p10-p11;
      p2 = p01-p11;
      p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
      p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
      n2 = cross(p1,p2);
      n = (n1+n2)/2;
      n = n ./ sqrt( sum( n .* n ) );
      Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);
    end

    i=1;
    p11 = [ X(i,j) Y(i,j) Z(i,j) ];
    p12 = [ X(i,j+1) Y(i,j+1) Z(i,j+1) ];
    p21 = [ X(i+1,j) Y(i+1,j) Z(i+1,j) ];
    p1 = p12-p11;
    p2 = p21-p11;
    p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
    p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
    n = cross(p1,p2);
    Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);

    i=size(Z,1);
    p11 = [ X(i,j) Y(i,j) Z(i,j) ];
    p10 = [ X(i,j-1) Y(i,j-1) Z(i,j-1) ];
    p01 = [ X(i-1,j) Y(i-1,j) Z(i-1,j) ];
    p1 = p10-p11;
    p2 = p01-p11;
    p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
    p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
    n = cross(p1,p2);
    Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);
  end

  for i=1+1:size(Z,1)-1
    j=size(Z,2);
    p11 = [ X(i,j) Y(i,j) Z(i,j) ];
    p10 = [ X(i,j-1) Y(i,j-1) Z(i,j-1) ];
    p01 = [ X(i-1,j) Y(i-1,j) Z(i-1,j) ];
    p1 = p10-p11;
    p2 = p01-p11;
    p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
    p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
    n = cross(p1,p2);
    Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);

    j=1;
    p11 = [ X(i,j) Y(i,j) Z(i,j) ];
    p12 = [ X(i,j+1) Y(i,j+1) Z(i,j+1) ];
    p21 = [ X(i+1,j) Y(i+1,j) Z(i+1,j) ];
    p1 = p12-p11;
    p2 = p21-p11;
    p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
    p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
    n = cross(p1,p2);
    Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);
  end

  i=1;j=1;
  p11 = [ X(i,j) Y(i,j) Z(i,j) ];
  p12 = [ X(i,j+1) Y(i,j+1) Z(i,j+1) ];
  p21 = [ X(i+1,j) Y(i+1,j) Z(i+1,j) ];
  p1 = p12-p11;
  p2 = p21-p11;
  p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
  p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
  n = cross(p1,p2);
  Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);

  i=size(Z,1);  j=size(Z,2);
  p11 = [ X(i,j) Y(i,j) Z(i,j) ];
  p10 = [ X(i,j-1) Y(i,j-1) Z(i,j-1) ];
  p01 = [ X(i-1,j) Y(i-1,j) Z(i-1,j) ];
  p1 = p10-p11;
  p2 = p01-p11;
  p1 = p1./sqrt(max(sum(p1.*p1),0.0001));
  p2 = p2./sqrt(max(sum(p2.*p2),0.0001));
  n = cross(p1,p2);
  Nx(i,j) = n(1); Ny(i,j) = n(2); Nz(i,j) = n(3);

  Nx(1,j) = Nx(2,j-1); Ny(1,j) = Ny(2,j-1); Nz(1,j) = Nz(2,j-1);
  Nx(i,1) = Nx(i-1,2); Ny(i,1) = Ny(i-1,2); Nz(i,1) = Nz(i-1,2);

  extent = sqrt( ( max(max(X))-min(min(X)) )^2 + ( max(max(Y))-min(min(Y)) )^2  + ( max(max(Z))-min(min(Z)) )^2);

  fprintf(fid,'    LOD\n');
  fprintf(fid,'    {');
  fprintf(fid,'    center %g %g %g\n',mean(mean(X)),mean(mean(Y)),mean(mean(Z)));
  fprintf(fid,'    range [\n');
  for level=2:ceil(log(max(size(Z)))/log(6))
    fprintf(fid,'    %g \n', extent*(1.75)^(level-1));
  end
  fprintf(fid,'    ] \n');

  fprintf(fid,'    level [');

  for level=1:ceil(log(max(size(Z)))/log(6))
    lod = 2^(level-1);

    if floor((size(Z,1)-1)/lod) ~= (size(Z,1)-1)/lod | floor((size(Z,2)-1)/lod) ~= (size(Z,2)-1)/lod
      disp(['           (can''t generate any more levels of detail since']);
      disp(['            number of ploygons is not a multiple of ' num2str(lod)]);
      disp(['            in each direction)']);
    break;
    end
    disp(['           (generating level of detail #' num2str(level) ')']);

    fprintf(fid,'Transform\n');
    fprintf(fid,'{');
    fprintf(fid,'  children\n');
    fprintf(fid,'  [');

    sx=1:16*lod:size(Z,1);
    if size(Z,1) - sx(length(sx)) < 2*lod
      sx = sx(1:length(sx)-1);
    end
    sx = [ sx size(Z,1) ];
    
    sy=1:16*lod:size(Z,2);
    if size(Z,2) - sy(length(sy)) < 2*lod
      sy = sy(1:length(sy)-1);
    end
    sy = [ sy size(Z,2) ];
    
    for m=1:length(sx)-1
      for n=1:length(sy)-1
        SX = X(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SY = Y(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SZ = Z(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SC = C(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SNx = Nx(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SNy = Ny(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
        SNz = Nz(sx(m):lod:sx(m+1),sy(n):lod:sy(n+1));
  
        fprintf(fid,'    Shape\n');
        fprintf(fid,'    {');
        fprintf(fid,'      appearance        Appearance {\n');
        fprintf(fid,'        material        Material { emissiveColor 0 0 0 ambientIntensity 0.1}\n');
        fprintf(fid,'      }\n');
        fprintf(fid,'      geometry IndexedFaceSet');
        fprintf(fid,'      {');
        fprintf(fid,'        colorPerVertex  TRUE\n');
        fprintf(fid,'        normalPerVertex TRUE\n');
        fprintf(fid,'        solid FALSE\n');
        fprintf(fid,'        coord DEF COORDS Coordinate\n');
        fprintf(fid,'        {');
        fprintf(fid,'          point\n');
        fprintf(fid,'          [');
        for j=1:size(SZ,2)
          for i=1:size(SZ,1)
           fprintf(fid,'           %g %g %g\n',SX(i,j),SY(i,j),SZ(i,j) );
          end
        end
        fprintf(fid,'          ]');
        fprintf(fid,'        }');
        fprintf(fid,'        coordIndex\n');
        fprintf(fid,'        [');
        for j=1:size(SZ,2)-1
          for i=1:size(SZ,1)-1
              fprintf(fid,'%g %g %g -1\n',(j-1)*size(SZ,1)+i-1,j*size(SZ,1)+i-1,j*size(SZ,1)+i);
              fprintf(fid,'%g %g %g -1\n',(j-1)*size(SZ,1)+i-1,j*size(SZ,1)+i,(j-1)*size(SZ,1)+i);
          end
        end
        fprintf(fid,'        ]');
        fprintf(fid,'        color Color\n');
        fprintf(fid,'        {');
        fprintf(fid,'          color\n');
        fprintf(fid,'          [');
        red = color1(1) - color0(1);
        green = color1(2) - color0(2);
        blue = color1(3) - color0(3);
        for j=1:size(SZ,2)
          for i=1:size(SZ,1)
            fprintf(fid,'%g %g %g\n',color0(1)+red*SC(i,j),color0(2)+green*SC(i,j),color0(3)+blue*SC(i,j));
          end
        end
        fprintf(fid,'          ]');
        fprintf(fid,'        }');
        fprintf(fid,'        normal Normal\n');
        fprintf(fid,'        {');
        fprintf(fid,'          vector\n');
        fprintf(fid,'          [');
        for j=1:size(SZ,2)
          for i=1:size(SZ,1)
           fprintf(fid,'           %g %g %g\n',SNx(i,j), SNy(i,j), SNz(i,j));
          end
        end
        fprintf(fid,'          ]');
        fprintf(fid,'        }');
        fprintf(fid,'      }');
        fprintf(fid,'    }');
        
        if meshmode~= 0
          fprintf(fid,'    Shape\n');
          fprintf(fid,'    {');
          fprintf(fid,'      appearance        Appearance {\n');
          fprintf(fid,'        material        Material { diffuseColor %g %g %g emissiveColor %g %g %g }\n',meshcolor(1),meshcolor(2),meshcolor(3),meshcolor(1)*0.05,meshcolor(2)*0.05,meshcolor(3)*0.05);
          fprintf(fid,'      }\n');
          fprintf(fid,'      geometry IndexedLineSet');
          fprintf(fid,'      {');
          fprintf(fid,'        coord DEF COORDS Coordinate\n');
          fprintf(fid,'        {');
          fprintf(fid,'          point\n');
          fprintf(fid,'          [');
          for j=1:size(SZ,2)
            for i=1:size(SZ,1)
             fprintf(fid,'           %g %g %g\n',SX(i,j)+2*epsilon*SNx(i,j),SY(i,j)+2*epsilon*SNy(i,j),SZ(i,j)+2*epsilon*SNz(i,j) );
            end
          end
          fprintf(fid,'          ]');
          fprintf(fid,'        }');
          fprintf(fid,'        coordIndex\n');
          fprintf(fid,'        [');
          for j=1:size(SZ,2)
            for i=1:size(SZ,1)
              fprintf(fid,'%g\n',(j-1)*size(SZ,1)+i-1);
            end
            fprintf(fid,'-1\n');
          end
          for i=1:size(SZ,1)
            for j=1:size(SZ,2)
              fprintf(fid,'%g\n',(j-1)*size(SZ,1)+i-1);
            end
            fprintf(fid,'-1\n');
          end
          fprintf(fid,'        ]');
          fprintf(fid,'      }');
          fprintf(fid,'    }');
        end
      end
    end
    fprintf(fid,'    ]'); % transform inside lod level
    fprintf(fid,'  }'); % children inside lod level
    
  end
  fprintf(fid,'  ]'); % lod level
  fprintf(fid,'}'); % lod
  disp('           (surface completed)');
  
end
fprintf(fid,']');
fprintf(fid,'}');

fprintf(fid,']');
fprintf(fid,'}');
% 
% Create a command button space along top edge of display
% Measure viewer posn and have command buttons track viewer
%
if( controlbarmode ~= 0 & appendmode==0 )
  fprintf(fid,'    Transform\n');
  fprintf(fid,'    {\n');
  fprintf(fid,'children \n'); 
  fprintf(fid,'[\n');
  fprintf(fid,'DEF viewer ProximitySensor { center %g %g %g size %g %g %g } \n',viewx, viewz, -viewy, 4*viewDistD,4*viewDistD,4*viewDistD);
  fprintf(fid,']\n');
  fprintf(fid,'    }\n');

  fprintf(fid,'DEF buttonDock Transform\n');
  fprintf(fid,'{\n');
  fprintf(fid,'translation %g %g %g\n',-viewDistD/2.2*1.5708+viewx,viewz+viewDistD/2.2*(0.95+NEEDTIMEBAR*0.05),-viewy+viewDistD/2.2*1.75);
  fprintf(fid,'rotation -0.497412 -0.850208 -0.172416  0.850023\n');
  fprintf(fid,'  children \n'); 
  fprintf(fid,'  [\n');
  fprintf(fid,'    DirectionalLight { direction 0 -0.3 -0.9539}');
  fprintf(fid,'    DEF buttonBar Transform\n');
  fprintf(fid,'    {\n');
  fprintf(fid,'      translation %g %g %g\n',0, 0.36, -1.0);
  fprintf(fid,'      rotation 1 0 0 0.75\n');
  fprintf(fid,'      scale 0.1 0.1 0.1\n');
  fprintf(fid,'      children \n'); 
  fprintf(fid,'      [\n');
  %fprintf(fid,'        DEF aboveButtons VisibilitySensor\n');
  %fprintf(fid,'        {\n');
  %fprintf(fid,'          center 0 0.5 0\n');
  %fprintf(fid,'          size   100 0.01 0.01\n');
  %fprintf(fid,'          enabled TRUE\n');
  %fprintf(fid,'        }\n');
  %fprintf(fid,'        DEF belowButtons VisibilitySensor\n');
  %fprintf(fid,'        {\n');
  %fprintf(fid,'          center 0 0.4 0\n');
  %fprintf(fid,'          size   100 0.01 0.01\n');
  %fprintf(fid,'          enabled TRUE\n');
  %fprintf(fid,'        }\n');
  %fprintf(fid,'        DEF controlBarTime TimeSensor\n');
  %fprintf(fid,'        {\n');
  %fprintf(fid,'          loop TRUE\n');
  %fprintf(fid,'          cycleInterval 10\n');
  %fprintf(fid,'        }\n');
  %
  % Now draw a control bar which rotates to follow the viewer
  %
  if NEEDTIMEBAR==1
    fprintf(fid,'DEF controls Transform\n');
    fprintf(fid,'{');
    fprintf(fid,'translation 0 0 0.01\n');
    fprintf(fid,'rotation 0 0 1 0\n');
    fprintf(fid,'scale 4 4 4\n');
    fprintf(fid,'children \n'); 
    fprintf(fid,'[');
    fprintf(fid,'DEF controlsTilt Transform\n');
    fprintf(fid,'{');
    fprintf(fid,'translation %g %g %g\n',0,0,0);
    %fprintf(fid,'rotation 1 0 0 %g\n',pi/2-axangle);
    %fprintf(fid,'axisOfRotation 0 0 0\n');
    fprintf(fid,'children\n');
    fprintf(fid,'[');
    fprintf(fid,'Transform\n');
    fprintf(fid,'{');
    %fprintf(fid,'translation %g %g %g\n',0,-0.05*2.5,-0.05*0.5);
    %fprintf(fid,'rotation 1 0 0 0\n');
    fprintf(fid,'children \n');
    fprintf(fid,'[');
    fprintf(fid,'Shape\n');
    fprintf(fid,'{');
    fprintf(fid,' geometry IndexedFaceSet\n');
    fprintf(fid,' {');
    fprintf(fid,' coord Coordinate\n');
    fprintf(fid,' {');
    fprintf(fid,' point\n');
    fprintf(fid,' [');
    fprintf(fid,'  %g %g 0\n',-1.0,-0.05*3);
    fprintf(fid,'  %g %g 0\n',1.0,-0.05*3);
    fprintf(fid,'  %g %g 0\n',1.0, 0.05*3);
    fprintf(fid,'  %g %g 0\n',-1.0, 0.05*3);
    fprintf(fid,' ]');
    fprintf(fid,' }');
    fprintf(fid,' coordIndex\n');
    fprintf(fid,' [');
    fprintf(fid,' 0 1 2 3 -1\n');
    fprintf(fid,' ]');
    fprintf(fid,' }');
    fprintf(fid,' appearance Appearance\n');
    fprintf(fid,' {');
    fprintf(fid,' material Material { diffuseColor 0.2 0.2 0.2 emissiveColor 0 0 0 }');
    fprintf(fid,' }');
    fprintf(fid,'}');
    if(textmode ~=0 )
    VRMLpa(fid,ttitle,[taxis(MIN),taxis(STEP),taxis(MAX)],[-0.7,0.025,0.01],[0.7,0.025,0.01],[0,-1,0],0,0.07)
    end
    fprintf(fid,'Shape\n');
    fprintf(fid,'{');
    fprintf(fid,' geometry IndexedFaceSet\n');
    fprintf(fid,' {');
    fprintf(fid,' coord Coordinate\n');
    fprintf(fid,' {');
    fprintf(fid,' point\n');
    fprintf(fid,' [');
    fprintf(fid,'  -0.7 0.022 0.01\n');
    fprintf(fid,'  0.7 0.022 0.01\n');
    fprintf(fid,'  0.7 0.032 0.01\n');
    fprintf(fid,'  -0.7 0.032 0.01\n');
    fprintf(fid,' ]');
    fprintf(fid,' }');
    fprintf(fid,' coordIndex\n');
    fprintf(fid,' [');
    fprintf(fid,' 0 1 2 3 -1\n');
    fprintf(fid,' ]');
    fprintf(fid,' }');
    fprintf(fid,' appearance Appearance\n');
    fprintf(fid,' {');
    fprintf(fid,' material Material { diffuseColor 0.5 0.05 0.05 emissiveColor 0.3 0 0 }');
    fprintf(fid,' }');
    fprintf(fid,'}');
    fprintf(fid,'DEF TimeCone Transform\n');
    fprintf(fid,'{');
    fprintf(fid,' translation %g %g %g\n',-0.7, 0.025, 0.02);
    fprintf(fid,' rotation 1 0 0 1.5708\n');
    fprintf(fid,' children');
    fprintf(fid,' [');
    fprintf(fid,' Shape\n');
    fprintf(fid,' { \n');
    fprintf(fid,' geometry Cone { height %g bottomRadius %g } \n',0.05/2,0.05/4);
    fprintf(fid,' appearance Appearance\n');
    fprintf(fid,' {');
    fprintf(fid,' material Material { diffuseColor 0 0.3 0 emissiveColor 0.3 0.3 0}');
    fprintf(fid,' }');
    fprintf(fid,' }');
    fprintf(fid,' DEF AnimateTime PositionInterpolator\n');
    fprintf(fid,' {');
    fprintf(fid,' key [ 0.0 1.0 ]');
    fprintf(fid,' keyValue [%g %g %g,\n',-0.7,0.025,0.02);
    fprintf(fid,'  %g %g %g]',0.7,0.025,0.02);
    fprintf(fid,' }');
    fprintf(fid,' ]');
    fprintf(fid,'}');
    fprintf(fid,'Transform\n');
    fprintf(fid,'{');
    fprintf(fid,' translation -0.85 0 0.005\n');
    fprintf(fid,' scale 0.16 0.16 0.16\n');
    fprintf(fid,' children \n');
    fprintf(fid,' [');
    fprintf(fid,'    Transform {\n');
    fprintf(fid,'      children	Shape {\n');
    fprintf(fid,'	appearance	Appearance {\n');
    fprintf(fid,'	  material	Material {\n');
    fprintf(fid,'	    ambientIntensity	0.406487\n');
    fprintf(fid,'	    diffuseColor	0.158116 0.393617 0.101884\n');
    fprintf(fid,'	    specularColor	0.111109 0.276596 0.0715944\n');
    fprintf(fid,'	    emissiveColor	0.144311 0.297872 0.118095\n');
    fprintf(fid,'	    shininess	0.276596\n');
    fprintf(fid,'	    transparency	0\n');
    fprintf(fid,'	  }\n');
    fprintf(fid,'\n');
    fprintf(fid,'	}\n');
    fprintf(fid,'\n');
    fprintf(fid,'	geometry	IndexedFaceSet {\n');
    fprintf(fid,'	  coord	Coordinate {\n');
    fprintf(fid,'	    point	[ 6.41066 3.52363 0,\n');
    fprintf(fid,'		      5.236 0 0,\n');
    fprintf(fid,'		      8.82492 1.13374 0 ]\n');
    fprintf(fid,'	  }\n');
    fprintf(fid,'\n');
    fprintf(fid,'	  coordIndex	[ 0, 1, 2, -1 ]\n');
    fprintf(fid,'	  texCoord	TextureCoordinate {\n');
    fprintf(fid,'	    point	[ 0.238 0.141,\n');
    fprintf(fid,'		      0.238 0,\n');
    fprintf(fid,'		      0.384 0 ]\n');
    fprintf(fid,'	  }\n');
    fprintf(fid,'\n');
    fprintf(fid,'	  texCoordIndex	[ 0, 1, 2, -1 ]\n');
    fprintf(fid,'	  creaseAngle	0.5\n');
    fprintf(fid,'	}\n');
    fprintf(fid,'\n');
    fprintf(fid,'      }\n');
    fprintf(fid,'\n');
    fprintf(fid,'      translation	0.645284 -0.413136 0.0108076\n');
    fprintf(fid,'      rotation	0.00035907 -0.000878925 1  2.35658\n');
    fprintf(fid,'      scale	0.108173 0.108173 0.108173\n');
    fprintf(fid,'      scaleOrientation	-0.865515 -0.172855 -0.470111  0.0631931\n');
    fprintf(fid,'    }\n');
    fprintf(fid,'    Transform {\n');
    fprintf(fid,'      children	Shape {\n');
    fprintf(fid,'	appearance	Appearance {\n');
    fprintf(fid,'	  material	Material {\n');
    fprintf(fid,'	    ambientIntensity	0.884706\n');
    fprintf(fid,'	    diffuseColor	0.0791243 0.180851 0.0484903\n');
    fprintf(fid,'	    specularColor	0.144285 0.329787 0.0884234\n');
    fprintf(fid,'	    emissiveColor	0.00556273 0.0212766 0.00355372\n');
    fprintf(fid,'	    shininess	0.117021\n');
    fprintf(fid,'	    transparency	0\n');
    fprintf(fid,'	  }\n');
    fprintf(fid,'\n');
    fprintf(fid,'	}\n');
    fprintf(fid,'\n');
    fprintf(fid,'	geometry	Sphere {\n');
    fprintf(fid,'	  radius	0.1\n');
    fprintf(fid,'	}\n');
    fprintf(fid,'\n');
    fprintf(fid,'      }\n');
    fprintf(fid,'\n');
    fprintf(fid,'      translation	0.00440004 0.0137029 -0.0413103\n');
    fprintf(fid,'      rotation	0 1 0  1.5708\n');
    fprintf(fid,'      scale	0.5 4.9135 4.9135\n');
    fprintf(fid,'      scaleOrientation	0 0 1  0\n');
    fprintf(fid,'    }\n');
    
    fprintf(fid,' DEF playTS TouchSensor {},\n');
    fprintf(fid,' ]');
    fprintf(fid,'}');
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,']');
    fprintf(fid,'}');
    fprintf(fid,']');
    fprintf(fid,'}');
  end

  fprintf(fid,'        Transform\n');
  fprintf(fid,'        {\n');
  fprintf(fid,'          translation %g %g %g\n',3.45, 0, 0.1);
  fprintf(fid,'          scale 0.6 0.6 0.6\n');
  fprintf(fid,'          children\n');
  fprintf(fid,'          [\n');
  fprintf(fid,'            Anchor\n');
  fprintf(fid,'            {\n');
  fprintf(fid,'              url "http://www.dsl.whoi.edu/~sayers/VRMLplot/help.html"\n');
  fprintf(fid,'              description "Help viewing VRMLplot files"\n');
  fprintf(fid,'              children\n');
  fprintf(fid,'              [\n');
  fprintf(fid,'    Transform {\n');
  fprintf(fid,'      children	Shape {\n');
  fprintf(fid,'	appearance	Appearance {\n');
  fprintf(fid,'	  material	Material {\n');
  fprintf(fid,'	    ambientIntensity	0.406487\n');
  fprintf(fid,'	    diffuseColor	0.158116 0.393617 0.101884\n');
  fprintf(fid,'	    specularColor	0.111109 0.276596 0.0715944\n');
  fprintf(fid,'	    emissiveColor	0.144311 0.297872 0.118095\n');
  fprintf(fid,'	    shininess	0.276596\n');
  fprintf(fid,'	    transparency	0\n');
  fprintf(fid,'	  }\n');
  fprintf(fid,'	}\n');
  fprintf(fid,'	geometry	IndexedFaceSet {\n');
  fprintf(fid,'	  coord	Coordinate {\n');
  fprintf(fid,'	    point	[ 8.228 4.576 0,\n');
  fprintf(fid,'		      8.536 6.248 0,\n');
  fprintf(fid,'		      8.932 11.22 0,\n');
  fprintf(fid,'		      9.57 7.26 0,\n');
  fprintf(fid,'		      9.922 15.268 0,\n');
  fprintf(fid,'		      11.528 9.064 0,\n');
  fprintf(fid,'		      11.528 13.86 0,\n');
  fprintf(fid,'		      12.232 11.308 0,\n');
  fprintf(fid,'		      4.422 10.846 0,\n');
  fprintf(fid,'		      4.422 10.868 0,\n');
  fprintf(fid,'		      3.058 14.85 0,\n');
  fprintf(fid,'		      4.906 12.518 0,\n');
  fprintf(fid,'		      6.6 15.994 0,\n');
  fprintf(fid,'		      6.798 13.398 0,\n');
  fprintf(fid,'		      8.206 12.958 0,\n');
  fprintf(fid,'		      1.804 13.266 0,\n');
  fprintf(fid,'		      1.32 10.846 0,\n');
  fprintf(fid,'		      7.568 9.042 0,\n');
  fprintf(fid,'		      5.698 7.062 0,\n');
  fprintf(fid,'		      5.324 4.576 0,\n');
  fprintf(fid,'		      5.236 3.102 0,\n');
  fprintf(fid,'		      5.236 0 0,\n');
  fprintf(fid,'		      8.448 0 0,\n');
  fprintf(fid,'		      8.448 3.102 0 ]\n');
  fprintf(fid,'	  }\n');
  fprintf(fid,'	  coordIndex	[ 0, 1, 2, -1, 1, 3, 2, -1,\n');
  fprintf(fid,'		    2, 3, 4, -1, 3, 5, 4, -1,\n');
  fprintf(fid,'		    4, 5, 6, -1, 5, 7, 6, -1,\n');
  fprintf(fid,'		    8, 9, 10, -1, 9, 11, 10, -1,\n');
  fprintf(fid,'		    10, 11, 12, -1, 11, 13, 12, -1,\n');
  fprintf(fid,'		    12, 13, 4, -1, 13, 14, 4, -1,\n');
  fprintf(fid,'		    4, 14, 2, -1, 15, 16, 8, -1,\n');
  fprintf(fid,'		    15, 8, 10, -1, 0, 2, 17, -1,\n');
  fprintf(fid,'		    0, 17, 18, -1, 0, 18, 19, -1,\n');
  fprintf(fid,'		    20, 21, 22, -1, 20, 22, 23, -1 ]\n');
  fprintf(fid,'	  creaseAngle	0.5\n');
  fprintf(fid,'	}\n');
  fprintf(fid,'      }\n');
  fprintf(fid,'      translation	-0.200129 -0.216878 0.011145\n');
  fprintf(fid,'      rotation	0.976728 -0.00477745 0.214426  0.00169146\n');
  fprintf(fid,'      scale	0.0306318 0.0306318 0.0306318\n');
  fprintf(fid,'      scaleOrientation	0.59073 -0.519894 0.617048  0.163806\n');
  fprintf(fid,'    }\n');
  fprintf(fid,'    Transform {\n');
  fprintf(fid,'      children	Shape {\n');
  fprintf(fid,'	appearance	Appearance {\n');
  fprintf(fid,'	  material	Material {\n');
  fprintf(fid,'	    ambientIntensity	0.884706\n');
  fprintf(fid,'	    diffuseColor	0.0791243 0.180851 0.0484903\n');
  fprintf(fid,'	    specularColor	0.144285 0.329787 0.0884234\n');
  fprintf(fid,'	    emissiveColor	0.00556273 0.0212766 0.00355372\n');
  fprintf(fid,'	    shininess	0.117021\n');
  fprintf(fid,'	    transparency	0\n');
  fprintf(fid,'	  }\n');
  fprintf(fid,'	}\n');
  fprintf(fid,'	geometry	Sphere {\n');
  fprintf(fid,'	  radius	0.1\n');
  fprintf(fid,'	}\n');
  fprintf(fid,'\n');
  fprintf(fid,'      }\n');
  fprintf(fid,'\n');
  fprintf(fid,'      translation	0.00440004 0.0137029 -0.0413103\n');
  fprintf(fid,'      rotation	0 1 0  1.5708\n');
  fprintf(fid,'      scale	0.5 4.9135 4.9135\n');
  fprintf(fid,'      scaleOrientation	0 0 1  0\n');
  fprintf(fid,'    }\n');
  fprintf(fid,'              ]\n');
  fprintf(fid,'            }\n');
  fprintf(fid,'          ]\n');
  fprintf(fid,'        }\n');
  fprintf(fid,'      ]\n');
  fprintf(fid,'    }\n');
  fprintf(fid,'  ]\n');
  fprintf(fid,'}\n');
  
  fprintf(fid,'Group\n');
  fprintf(fid,'{');
  fprintf(fid,'  ROUTE viewer.position_changed TO buttonDock.set_translation\n');
  fprintf(fid,'  ROUTE viewer.orientation_changed TO buttonDock.set_rotation\n');
  fprintf(fid,'}');
  %fprintf(fid,'DEF controlBarScript Script');
  %fprintf(fid,'{');
  %fprintf(fid,'  eventIn  SFBool  topVisible\n');
  %fprintf(fid,'  eventIn  SFBool  bottomVisible\n');
  %fprintf(fid,'  eventIn  SFFloat fractionIn\n');
  %fprintf(fid,'  eventOut SFVec3f posnOut\n');
  %fprintf(fid,'  field    SFVec3f posn 0 0.36 -1.0\n');
  %fprintf(fid,'  field    SFBool  top FALSE\n');
  %fprintf(fid,'  field    SFBool  bot FALSE\n');
  %fprintf(fid,'  url "vrmlscript:\n');
  %fprintf(fid,'    function fractionIn()\n');
  %fprintf(fid,'      {\n');
  %fprintf(fid,'        if( !bot )\n');
  %fprintf(fid,'          {\n');
  %fprintf(fid,'            posn[1]-=0.02;\n');
  %fprintf(fid,'            posnOut=posn;\n');
  %fprintf(fid,'          }\n');
  %fprintf(fid,'        else\n');
  %fprintf(fid,'          {\n');
  %fprintf(fid,'            if (bot && top)\n');
  %fprintf(fid,'            {\n');
  %fprintf(fid,'              posn[1]+=0.0075;\n');
  %fprintf(fid,'              posnOut=posn;\n');
  %fprintf(fid,'            }\n');
  %fprintf(fid,'          }\n');
  %fprintf(fid,'      }\n');
  %fprintf(fid,'    function topVisible(a,t) { top=a;}\n');
  %fprintf(fid,'    function bottomVisible(a,t) { bot=a;}"\n');
  %fprintf(fid,'}');
  %fprintf(fid,'Group\n');
  %fprintf(fid,'{');
  %fprintf(fid,'  ROUTE controlBarTime.fraction_changed TO controlBarScript.fractionIn\n');
  %fprintf(fid,'  ROUTE aboveButtons.isActive TO controlBarScript.topVisible\n');
  %fprintf(fid,'  ROUTE belowButtons.isActive TO controlBarScript.bottomVisible\n');
  %fprintf(fid,'  ROUTE controlBarScript.posnOut TO buttonBar.set_translation\n');
  %fprintf(fid,'}');
end

if ( NEEDTIMEBAR==1 )
  fprintf(fid,'Group');
  fprintf(fid,'{');
  if controlbarmode==1
    fprintf(fid,'ROUTE playTS.touchTime TO TimeSource.startTime\n');
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO AnimateTime.set_fraction\n');
    fprintf(fid,'ROUTE AnimateTime.value_changed TO TimeCone.set_translation\n');
  end
  fprintf(fid,'}');
end

if stylemode==ANIMATEPOINT
  fprintf(fid,'Group');
  fprintf(fid,'{');
    fprintf(fid,'ROUTE spotPlayTS_%d.touchTime TO TimeSource.startTime\n',NUM);
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO Animation_%d.set_fraction\n',NUM);
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO AnimatePan_%d.set_fraction\n',NUM);
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO AnimateTilt_%d.set_fraction\n',NUM);
  if spotsize > 0 & shadowmode ~= 0
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO ShadowAnimation_%d.set_fraction\n',NUM);
    fprintf(fid,'ROUTE TimeSource.fraction_changed TO ShadowRadius_%d.set_fraction\n',NUM);
    fprintf(fid,'ROUTE ShadowAnimation_%d.value_changed TO ShadowTransform_%d.set_translation\n',NUM,NUM);
    fprintf(fid,'ROUTE ShadowRadius_%d.value_changed TO ShadowTransform_%d.set_scale\n',NUM,NUM);
  end
    fprintf(fid,'ROUTE Animation_%d.value_changed TO SpotTransform_%d.set_translation\n',NUM,NUM);
    fprintf(fid,'ROUTE AnimatePan_%d.value_changed TO SpotTransform_%d.set_rotation\n',NUM,NUM);
    fprintf(fid,'ROUTE AnimateTilt_%d.value_changed TO SpotTransform2_%d.set_rotation\n',NUM,NUM);
    fprintf(fid,'ROUTE viewSpot_%d.isBound TO minusxScript.goDown\n',NUM);
    fprintf(fid,'ROUTE viewSpot_%d.isBound TO plusyScript.goDown\n',NUM);
    fprintf(fid,'ROUTE viewSpot_%d.isBound TO minusyScript.goDown\n',NUM);
    fprintf(fid,'ROUTE viewSpot_%d.isBound TO plusxScript.goDown\n',NUM);
  fprintf(fid,'}');
end

if stylemode==ANIMATEVIEW
  fprintf(fid,'Group');
  fprintf(fid,'{');
    fprintf(fid,'ROUTE VRMLplotView_%d.isBound TO minusxScript.goDown\n',NUM);
    fprintf(fid,'ROUTE VRMLplotView_%d.isBound TO plusyScript.goDown\n',NUM);
    fprintf(fid,'ROUTE VRMLplotView_%d.isBound TO minusyScript.goDown\n',NUM);
    fprintf(fid,'ROUTE VRMLplotView_%d.isBound TO plusxScript.goDown\n',NUM);
  fprintf(fid,'}');
end

if stylemode==ANIMATEWRL & shadowmode ~= 0
  fprintf(fid,'Transform\n');
  fprintf(fid,'{');
  fprintf(fid,'children \n');
  fprintf(fid,'[');
  fprintf(fid,'DirectionalLight { direction 0 0.3 -0.9539 intensity 0.1}');
  fprintf(fid,'Transform\n');
  fprintf(fid,'{');
  fprintf(fid,'rotation 1 0 0 -1.5708\n');
  fprintf(fid,'children \n');
  fprintf(fid,'[');
  fprintf(fid,'Transform\n');
  fprintf(fid,'{');
  fprintf(fid,'  translation 0 0 %g\n',zaxis(MIN)*zaxis(SCALE)+epsilon);
  fprintf(fid,'  scale %g %g %g',xaxis(SCALE),yaxis(SCALE),0.0001*epsilon);
  fprintf(fid,'  children\n');
  fprintf(fid,'    DEF VRMLplotShadow_%d \n',NUM);
  fprintf(fid,'        %s { color 0.01 0.01 0.01 transparency 0.6 }\n',setstr(prototype));
  fprintf(fid,'}');

  for d=1:length(colDefTypes)
    fprintf(fid,'Group{');
    fprintf(fid,'ROUTE Animation%g_%d.value_changed TO VRMLplotShadow_%d.%s\n',d,NUM,NUM,colDefNames(d,:));
    fprintf(fid,'ROUTE InitAnim%g_%d.value TO VRMLplotShadow_%d.%s\n',d,NUM,NUM,colDefNames(d,:));
    fprintf(fid,'}\n');
  end
  fprintf(fid,']');
  fprintf(fid,'}');
  fprintf(fid,']');
  fprintf(fid,'}');
end
%
% Print a comment at the end of the file, so we can append things more
% easily.
fprintf(fid,'\n# Do not edit the following line - VRMLplot needs it!\n');
fprintf(fid,'# %8d %8d\n',NUM,stylemode);
fclose(fid);

return
