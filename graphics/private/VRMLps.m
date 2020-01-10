function VRMLps(fid,textmode,xaxis,xtitle,yaxis,ytitle,zaxis,ztitle,labelSize)
% VRMLps - plot surrounding axes for graph
% 
% Version 1.1 Copyright Craig Sayers and WHOI, 1996.
%
% note all axis values are in original units - multiply by scale
% to get world coordinate units.
% each axis is described by a vector containing:
MIN=1;
STEP=2;
MAX=3;
SIZE=4;
SCALE=5;

axangle = 60/180*pi;

if( nargin > 7 )
  XYZT=1;
else
  XYZT=0;
end

if isnan(labelSize)
labelSize = min([(xaxis(MAX)-xaxis(MIN))*xaxis(SCALE)/3,(yaxis(MAX)-yaxis(MIN))*yaxis(SCALE)/3,(zaxis(MAX)-zaxis(MIN))*zaxis(SCALE)/3,xaxis(STEP)*xaxis(SCALE),yaxis(STEP)*yaxis(SCALE),zaxis(STEP)*zaxis(SCALE)])/3.75;
end

epsilon=0.05*labelSize;

%
% Compute extent of axes
%
axmin = [ xaxis(MIN)*xaxis(SCALE), yaxis(MIN)*yaxis(SCALE), zaxis(MIN)*zaxis(SCALE)];
axmax = [ xaxis(MAX)*xaxis(SCALE), yaxis(MAX)*yaxis(SCALE), zaxis(MAX)*zaxis(SCALE)];

axmins = axmin-epsilon;
axmaxs = axmax+epsilon;
axmino = axmins - 2.4*labelSize*sin(axangle);
axmaxo = axmaxs + 2.4*labelSize*sin(axangle);
axmind = axmins - 2.4*labelSize*cos(axangle);
axmaxd = axmaxs + 2.4*labelSize*cos(axangle);

fprintf(fid,'Group {');
fprintf(fid,'PROTO largeTickShape []');
fprintf(fid,'{');
fprintf(fid,'Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,'%g %g %g,\n', -labelSize/20, 0, 0);
fprintf(fid,'%g %g %g,\n', -labelSize/20, -labelSize/5, 0);
fprintf(fid,'%g %g %g,\n', labelSize/20, -labelSize/5,0);
fprintf(fid,'%g %g %g,\n', labelSize/20,0,0);
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material\n');
fprintf(fid,'{');
fprintf(fid,'diffuseColor 1.0 0 0\n');
fprintf(fid,'emissiveColor 0.3 0 0\n');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');

if( textmode ~= 0 )
fprintf(fid,'Group {');
fprintf(fid,'PROTO labelShape [ field MFString label "" field MFString just "MIDDLE" field SFFloat size 0.1]\n');
fprintf(fid,'{');
fprintf(fid,'Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry Text \n');
fprintf(fid,'{');
fprintf(fid,'string IS label\n');
fprintf(fid,'	 fontStyle FontStyle\n');
fprintf(fid,'{');
fprintf(fid,'size IS size\n');
fprintf(fid,'justify IS just\n');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material\n');
fprintf(fid,'{');
fprintf(fid,'diffuseColor 1.0 0 0\n');
fprintf(fid,'emissiveColor 0.3 0 0\n');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
end
%
% Now draw semi-transparent surfaces on which to print axes labels
%

fprintf(fid,'Transform\n');
fprintf(fid,'{');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
%fprintf(fid,'0 4 5 1 -1\n');
%fprintf(fid,'1 5 6 2 -1\n');
%fprintf(fid,'2 6 7 3 -1\n');
%fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,'7 6 5 4 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 }');
fprintf(fid,'}');
fprintf(fid,'}');
VRMLpg(fid,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmin(2),axmin(3)],[axmax(1),axmin(2),axmin(3)],xaxis(SCALE),[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmin(1),axmin(2),axmin(3)],[axmin(1),axmax(2),axmin(3)],yaxis(SCALE),labelSize)
fprintf(fid,']');
fprintf(fid,'}');

%
% Now draw semi-transparent surfaces for -x axis which to print axes labels
%

fprintf(fid,'DEF minusxTop Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 0\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 }');
fprintf(fid,'}');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,ytitle,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmins(1),axmin(2),axmins(3)],[axmins(1),axmax(2),axmins(3)],[-sin(axangle),0,-cos(axangle)],1,labelSize)
end
fprintf(fid,'DEF minusxTopTouch TouchSensor {},\n');
fprintf(fid,'DEF minusxTopTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,']');
fprintf(fid,'}');

fprintf(fid,'DEF minusxFace Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 %g\n',axmind(3));
fprintf(fid,'scale 1 1 0.0001\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmaxd(3)-axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
fprintf(fid,'0 4 5 1 -1\n');
fprintf(fid,'1 5 6 2 -1\n');
fprintf(fid,'2 6 7 3 -1\n');
fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,'7 6 5 4 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 transparency 0.3}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'DEF minusxFaceTouch TouchSensor {},\n');
fprintf(fid,'DEF minusxFaceTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,'DEF minusxFaceDown PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 1 1 1 0.0001 ]');
fprintf(fid,'}');
fprintf(fid,'DEF minusxFaceUp PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 0.0001 1 1 1 ]');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,ytitle,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmins(1),axmin(2),axmaxs(3)-axmind(3)],[axmins(1),axmax(2),axmaxs(3)-axmind(3)],[-sin(axangle),0,cos(axangle)],1,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmins(1),axmins(2),axmin(3)-axmind(3)],[axmins(1),axmins(2),axmax(3)-axmind(3)],[-sin(pi/4),-cos(pi/4),0],1,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmins(1),axmaxs(2),axmin(3)-axmind(3)],[axmins(1),axmaxs(2),axmax(3)-axmind(3)],[-sin(pi/4),cos(pi/4),0],0,labelSize)
end
VRMLpg(fid,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmin(1),axmin(2),axmin(3)-axmind(3)],[axmin(1),axmax(2),axmin(3)-axmind(3)],yaxis(SCALE),[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmin(1),axmin(2),axmin(3)-axmind(3)],[axmin(1),axmin(2),axmax(3)-axmind(3)],zaxis(SCALE),labelSize)
fprintf(fid,']');
fprintf(fid,'}');

%
% Now draw semi-transparent surfaces for +x axis which to print axes labels
%

fprintf(fid,'DEF plusxTop Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 0\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'1 5 6 2 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 }');
fprintf(fid,'}');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,ytitle,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmaxs(1),axmin(2),axmins(3)],[axmaxs(1),axmax(2),axmins(3)],[sin(axangle),0,-cos(axangle)],0,labelSize)
end
fprintf(fid,'DEF plusxTopTouch TouchSensor {},\n');
fprintf(fid,'DEF plusxTopTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,']');
fprintf(fid,'}');

fprintf(fid,'DEF plusxFace Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 %g\n',axmind(3));
fprintf(fid,'scale 1 1 1\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3)-axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
fprintf(fid,'0 4 5 1 -1\n');
fprintf(fid,'1 5 6 2 -1\n');
fprintf(fid,'2 6 7 3 -1\n');
fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,'7 6 5 4 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 transparency 0.3}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'DEF plusxFaceTouch TouchSensor {},\n');
fprintf(fid,'DEF plusxFaceTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,'DEF plusxFaceDown PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 1 1 1 0.0001 ]');
fprintf(fid,'}');
fprintf(fid,'DEF plusxFaceUp PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 0.0001 1 1 1 ]');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,ytitle,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmaxs(1),axmin(2),axmaxs(3)-axmind(3)],[axmaxs(1),axmax(2),axmaxs(3)-axmind(3)],[sin(axangle),0,cos(axangle)],0,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmaxs(1),axmins(2),axmin(3)-axmind(3)],[axmaxs(1),axmins(2),axmax(3)-axmind(3)],[sin(pi/4),-cos(pi/4),0],0,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmaxs(1),axmaxs(2),axmin(3)-axmind(3)],[axmaxs(1),axmaxs(2),axmax(3)-axmind(3)],[sin(pi/4),cos(pi/4),0],1,labelSize)
end
VRMLpg(fid,[yaxis(MIN),yaxis(STEP),yaxis(MAX)],[axmax(1),axmin(2),axmin(3)-axmind(3)],[axmax(1),axmax(2),axmin(3)-axmind(3)],yaxis(SCALE),[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmax(1),axmin(2),axmin(3)-axmind(3)],[axmax(1),axmin(2),axmax(3)-axmind(3)],zaxis(SCALE),labelSize)
fprintf(fid,']');
fprintf(fid,'}');

%
% Now draw semi-transparent surfaces for -y axis which to print axes labels
%

fprintf(fid,'DEF minusyTop Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 0\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 4 5 1 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 }');
fprintf(fid,'}');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,xtitle,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmins(2),axmins(3)],[axmax(1),axmins(2),axmins(3)],[0,-sin(axangle),-cos(axangle)],0,labelSize)
end
fprintf(fid,'DEF minusyTopTouch TouchSensor {},\n');
fprintf(fid,'DEF minusyTopTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,']');
fprintf(fid,'}');

fprintf(fid,'DEF minusyFace Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 %g\n',axmind(3));
fprintf(fid,'scale 1 1 0.0001\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmaxd(3)-axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
fprintf(fid,'0 4 5 1 -1\n');
fprintf(fid,'1 5 6 2 -1\n');
fprintf(fid,'2 6 7 3 -1\n');
fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,'7 6 5 4 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 transparency 0.3}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'DEF minusyFaceTouch TouchSensor {},\n');
fprintf(fid,'DEF minusyFaceTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,'DEF minusyFaceDown PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 1 1 1 0.0001 ]');
fprintf(fid,'}');
fprintf(fid,'DEF minusyFaceUp PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 0.0001 1 1 1 ]');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,xtitle,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmins(2),axmaxs(3)-axmind(3)],[axmax(1),axmins(2),axmaxs(3)-axmind(3)],[0,-sin(axangle),cos(axangle)],0,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmins(1),axmins(2),axmin(3)-axmind(3)],[axmins(1),axmins(2),axmax(3)-axmind(3)],[-sin(pi/4),-cos(pi/4),0],0,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmaxs(1),axmins(2),axmin(3)-axmind(3)],[axmaxs(1),axmins(2),axmax(3)-axmind(3)],[sin(pi/4),-cos(pi/4),0],1,labelSize)
end
VRMLpg(fid,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmin(2),axmin(3)-axmind(3)],[axmax(1),axmin(2),axmin(3)-axmind(3)],xaxis(SCALE),[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmin(1),axmin(2),axmin(3)-axmind(3)],[axmin(1),axmin(2),axmax(3)-axmind(3)],zaxis(SCALE),labelSize)
fprintf(fid,']');
fprintf(fid,'}');

%
% Now draw semi-transparent surfaces for +y axis which to print axes labels
%

fprintf(fid,'DEF plusyTop Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 0\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmins(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmins(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmino(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'2 6 7 3 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 }');
fprintf(fid,'}');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,xtitle,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmaxs(2),axmins(3)],[axmax(1),axmaxs(2),axmins(3)],[0,sin(axangle),-cos(axangle)],1,labelSize)
end
fprintf(fid,'DEF plusyTopTouch TouchSensor {},\n');
fprintf(fid,'DEF plusyTopTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,']');
fprintf(fid,'}');

fprintf(fid,'DEF plusyFace Transform\n');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 %g\n',axmind(3));
fprintf(fid,'scale 1 1 1\n');
fprintf(fid,'children\n');
fprintf(fid,'[');
fprintf(fid,'DEF faceBox Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedFaceSet\n');
fprintf(fid,'{');
fprintf(fid,'coord Coordinate\n');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxs(1),axmaxs(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmaxs(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmins(1),axmaxs(2),axmins(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmind(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmaxo(1),axmaxo(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmaxd(3)-axmind(3));
fprintf(fid,' %g %g %g,\n', axmino(1),axmaxo(2),axmind(3)-axmind(3));
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');
fprintf(fid,'0 1 2 3 -1\n');
fprintf(fid,'0 4 5 1 -1\n');
fprintf(fid,'1 5 6 2 -1\n');
fprintf(fid,'2 6 7 3 -1\n');
fprintf(fid,'3 7 4 0 -1\n');
fprintf(fid,'7 6 5 4 -1\n');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance\n');
fprintf(fid,'{');
fprintf(fid,'material Material { diffuseColor 0.2 0.05 0.05 emissiveColor 0.1 0 0 transparency 0.3}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'DEF plusyFaceTouch TouchSensor {},\n');
fprintf(fid,'DEF plusyFaceTime TimeSensor { cycleInterval %g },\n',1.5);
fprintf(fid,'DEF plusyFaceDown PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 1 1 1 0.0001 ]');
fprintf(fid,'}');
fprintf(fid,'DEF plusyFaceUp PositionInterpolator\n');
fprintf(fid,'{');
fprintf(fid,'key [ 0 1 ]');
fprintf(fid,'keyValue [ 1 1 0.0001 1 1 1 ]');
fprintf(fid,'}');
if( textmode ~= 0 )
VRMLpa(fid,xtitle,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmaxs(2),axmaxs(3)-axmind(3)],[axmax(1),axmaxs(2),axmaxs(3)-axmind(3)],[0,sin(axangle),cos(axangle)],1,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmins(1),axmaxs(2),axmin(3)-axmind(3)],[axmins(1),axmaxs(2),axmax(3)-axmind(3)],[-sin(pi/4),cos(pi/4),0],1,labelSize)
end
if( textmode ~= 0 )
VRMLpa(fid,ztitle,[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmaxs(1),axmaxs(2),axmin(3)-axmind(3)],[axmaxs(1),axmaxs(2),axmax(3)-axmind(3)],[sin(pi/4),cos(pi/4),0],0,labelSize)
end
VRMLpg(fid,[xaxis(MIN),xaxis(STEP),xaxis(MAX)],[axmin(1),axmax(2),axmin(3)-axmind(3)],[axmax(1),axmax(2),axmin(3)-axmind(3)],xaxis(SCALE),[zaxis(MIN),zaxis(STEP),zaxis(MAX)],[axmin(1),axmax(2),axmin(3)-axmind(3)],[axmin(1),axmax(2),axmax(3)-axmind(3)],zaxis(SCALE),labelSize)
fprintf(fid,']');
fprintf(fid,'}\n');

fprintf(fid,'DEF minusxScript Script\n');
fprintf(fid,'{');
fprintf(fid,'eventIn SFBool goUp\n');
fprintf(fid,'eventIn SFBool goDown\n');
fprintf(fid,'eventOut SFTime upTime\n');
fprintf(fid,'eventOut SFTime downTime\n');
fprintf(fid,'field SFBool isDown TRUE\n');
fprintf(fid,'url "vrmlscript:\n');
fprintf(fid,'function goUp(value,time) { if(value && isDown) {isDown=0; upTime=time;} }');
fprintf(fid,'function goDown(value,time) { if(value && (!isDown)) {isDown=1; downTime=time;} }');
fprintf(fid,'"\n');
fprintf(fid,'}');

fprintf(fid,'Group');
fprintf(fid,'{');
fprintf(fid,'ROUTE minusxTopTouch.isActive TO minusxScript.goUp\n');
fprintf(fid,'ROUTE minusxScript.upTime TO minusxTopTime.startTime\n');
fprintf(fid,'ROUTE minusxTopTime.fraction_changed TO minusxFaceUp.set_fraction\n');
fprintf(fid,'ROUTE minusxFaceTouch.isActive TO minusxScript.goDown\n');
fprintf(fid,'ROUTE minusxScript.downTime TO minusxFaceTime.startTime\n');
fprintf(fid,'ROUTE minusxFaceTime.fraction_changed TO minusxFaceDown.set_fraction\n');
fprintf(fid,'ROUTE minusxFaceDown.value_changed TO minusxFace.set_scale\n');
fprintf(fid,'ROUTE minusxFaceUp.value_changed TO minusxFace.set_scale\n');
fprintf(fid,'}');


fprintf(fid,'DEF plusxScript Script\n');
fprintf(fid,'{');
fprintf(fid,'eventIn SFBool goUp\n');
fprintf(fid,'eventIn SFBool goDown\n');
fprintf(fid,'eventOut SFTime upTime\n');
fprintf(fid,'eventOut SFTime downTime\n');
fprintf(fid,'field SFBool isDown FALSE\n');
fprintf(fid,'url "vrmlscript:\n');
fprintf(fid,'function goUp(value,time) { if(value && isDown) {isDown=0; upTime=time;} }');
fprintf(fid,'function goDown(value,time) { if(value && (!isDown)) {isDown=1; downTime=time;} }');
fprintf(fid,'"\n');
fprintf(fid,'}');

fprintf(fid,'Group');
fprintf(fid,'{');
fprintf(fid,'ROUTE plusxTopTouch.isActive TO plusxScript.goUp\n');
fprintf(fid,'ROUTE plusxScript.upTime TO plusxTopTime.startTime\n');
fprintf(fid,'ROUTE plusxTopTime.fraction_changed TO plusxFaceUp.set_fraction\n');
fprintf(fid,'ROUTE plusxFaceTouch.isActive TO plusxScript.goDown\n');
fprintf(fid,'ROUTE plusxScript.downTime TO plusxFaceTime.startTime\n');
fprintf(fid,'ROUTE plusxFaceTime.fraction_changed TO plusxFaceDown.set_fraction\n');
fprintf(fid,'ROUTE plusxFaceDown.value_changed TO plusxFace.set_scale\n');
fprintf(fid,'ROUTE plusxFaceUp.value_changed TO plusxFace.set_scale\n');
fprintf(fid,'}');


fprintf(fid,'DEF minusyScript Script\n');
fprintf(fid,'{');
fprintf(fid,'eventIn SFBool goUp\n');
fprintf(fid,'eventIn SFBool goDown\n');
fprintf(fid,'eventOut SFTime upTime\n');
fprintf(fid,'eventOut SFTime downTime\n');
fprintf(fid,'field SFBool isDown TRUE\n');
fprintf(fid,'url "vrmlscript:\n');
fprintf(fid,'function goUp(value,time) { if(value && isDown) {isDown=0; upTime=time;} }');
fprintf(fid,'function goDown(value,time) { if(value && (!isDown)) {isDown=1; downTime=time;} }');
fprintf(fid,'"\n');
fprintf(fid,'}');

fprintf(fid,'Group');
fprintf(fid,'{');
fprintf(fid,'ROUTE minusyTopTouch.isActive TO minusyScript.goUp\n');
fprintf(fid,'ROUTE minusyScript.upTime TO minusyTopTime.startTime\n');
fprintf(fid,'ROUTE minusyTopTime.fraction_changed TO minusyFaceUp.set_fraction\n');
fprintf(fid,'ROUTE minusyFaceTouch.isActive TO minusyScript.goDown\n');
fprintf(fid,'ROUTE minusyScript.downTime TO minusyFaceTime.startTime\n');
fprintf(fid,'ROUTE minusyFaceTime.fraction_changed TO minusyFaceDown.set_fraction\n');
fprintf(fid,'ROUTE minusyFaceDown.value_changed TO minusyFace.set_scale\n');
fprintf(fid,'ROUTE minusyFaceUp.value_changed TO minusyFace.set_scale\n');
fprintf(fid,'}');


fprintf(fid,'DEF plusyScript Script\n');
fprintf(fid,'{');
fprintf(fid,'eventIn SFBool goUp\n');
fprintf(fid,'eventIn SFBool goDown\n');
fprintf(fid,'eventOut SFTime upTime\n');
fprintf(fid,'eventOut SFTime downTime\n');
fprintf(fid,'field SFBool isDown FALSE\n');
fprintf(fid,'url "vrmlscript:\n');
fprintf(fid,'function goUp(value,time) { if(value && isDown) {isDown=0; upTime=time;} }');
fprintf(fid,'function goDown(value,time) { if(value && (!isDown)) {isDown=1; downTime=time;} }');
fprintf(fid,'"\n');
fprintf(fid,'}');

fprintf(fid,'Group');
fprintf(fid,'{');
fprintf(fid,'ROUTE plusyTopTouch.isActive TO plusyScript.goUp\n');
fprintf(fid,'ROUTE plusyScript.upTime TO plusyTopTime.startTime\n');
fprintf(fid,'ROUTE plusyTopTime.fraction_changed TO plusyFaceUp.set_fraction\n');
fprintf(fid,'ROUTE plusyFaceTouch.isActive TO plusyScript.goDown\n');
fprintf(fid,'ROUTE plusyScript.downTime TO plusyFaceTime.startTime\n');
fprintf(fid,'ROUTE plusyFaceTime.fraction_changed TO plusyFaceDown.set_fraction\n');
fprintf(fid,'ROUTE plusyFaceDown.value_changed TO plusyFace.set_scale\n');
fprintf(fid,'ROUTE plusyFaceUp.value_changed TO plusyFace.set_scale\n');

fprintf(fid,'ROUTE viewDefault.isBound TO minusxScript.goDown\n');
fprintf(fid,'ROUTE viewDefault.isBound TO plusyScript.goUp\n');
fprintf(fid,'ROUTE viewDefault.isBound TO minusyScript.goDown\n');
fprintf(fid,'ROUTE viewDefault.isBound TO plusxScript.goUp\n');

fprintf(fid,'ROUTE viewDefault2.isBound TO minusxScript.goUp\n');
fprintf(fid,'ROUTE viewDefault2.isBound TO plusyScript.goUp\n');
fprintf(fid,'ROUTE viewDefault2.isBound TO minusyScript.goDown\n');
fprintf(fid,'ROUTE viewDefault2.isBound TO plusxScript.goDown\n');

fprintf(fid,'ROUTE viewX.isBound TO minusxScript.goUp\n');
fprintf(fid,'ROUTE viewX.isBound TO plusyScript.goUp\n');
fprintf(fid,'ROUTE viewX.isBound TO minusyScript.goDown\n');
fprintf(fid,'ROUTE viewX.isBound TO plusxScript.goDown\n');

fprintf(fid,'ROUTE viewY.isBound TO minusxScript.goUp\n');
fprintf(fid,'ROUTE viewY.isBound TO plusyScript.goUp\n');
fprintf(fid,'ROUTE viewY.isBound TO minusyScript.goDown\n');
fprintf(fid,'ROUTE viewY.isBound TO plusxScript.goDown\n');

fprintf(fid,'ROUTE viewZ.isBound TO minusxScript.goUp\n');
fprintf(fid,'ROUTE viewZ.isBound TO plusyScript.goDown\n');
fprintf(fid,'ROUTE viewZ.isBound TO minusyScript.goUp\n');
fprintf(fid,'ROUTE viewZ.isBound TO plusxScript.goDown\n');

fprintf(fid,'}');




