function VRMLpa(fid, title, labels, start, finish, down, flip, labelSize)
%
% Function to plot graph axis in VRML 2.0 format
% Axis labels go [lables(1):labels(2):labels(3)
% Tick marks are located along a line from start to finish
% Axis labels are located beneath each tick mark with orientation
% determined by the down normal
% e.g. for a planar x,y graph the x axis would lie along the bottom
% of the graph and be the right way up for a viewer looking down the z axis
% if down was [ 0 -1 0 ].
%
% Copyright Craig Sayers and WHOI 1996.
%

axscale = norm(finish-start)/(labels(3)-labels(1));
%
% Compute rotation so that x axis goes from start to finish
% and y axis points up
%
x = [ finish(1)-start(1), finish(2)-start(2), finish(3)-start(3) ];
x = x / norm(x);
y = - down;

%
% Now rotate frame to align world x axis with label x axis
%
axis1 = cross([1,0,0],x);
angle1 = acos( x * [1;0;0]);

% Compute new y axis location
newX = VRMLra( axis1(1),axis1(2),axis1(3), angle1 ) * [1;0;0];
newY = VRMLra( axis1(1),axis1(2),axis1(3), angle1 ) * [0;1;0];

% Now rotate about x by cos(down, newY)
axis2 = [1,0,0];
angle2 = acos(-down * newY);
c = cross(newY,y) * newX;
if cross(newY,y) * newX < 0
 angle2 = -angle2;
end

% Begin by drawing the tick marks
%
fprintf(fid,'Transform');
fprintf(fid,'{');
fprintf(fid,'translation %g %g %g\n',start(1),start(2),start(3));
fprintf(fid,'children');
fprintf(fid,'[');
fprintf(fid,'Transform');
fprintf(fid,'{');
if angle1 ~= 0
 fprintf(fid,'rotation %g %g %g %g\n',axis1(1),axis1(2),axis1(3),angle1);
end
fprintf(fid,'children');
fprintf(fid,'[');
fprintf(fid,'Transform');
fprintf(fid,'{');
if angle2 ~= 0
 fprintf(fid,'rotation %g %g %g %g\n',axis2(1),axis2(2),axis2(3),angle2);
end
fprintf(fid,'children');
fprintf(fid,'[');
for i=labels(1):labels(2):labels(3)
 xpos = (i-labels(1))*axscale;
 fprintf(fid,'Transform');
 fprintf(fid,'{');
 fprintf(fid,'translation %g 0 0\n',xpos);
 if flip ~= 0
 fprintf(fid,'rotation 0 1 0 %g\n',pi);
 end
 fprintf(fid,'children');
 fprintf(fid,'[');
 fprintf(fid,'Shape\n');
 fprintf(fid,'{');
 fprintf(fid,'geometry IndexedLineSet');
 fprintf(fid,'{');
 fprintf(fid,'colorPerVertex FALSE ');
 fprintf(fid,'coord Coordinate');
 fprintf(fid,'{');
 fprintf(fid,'point\n');
 fprintf(fid,'[');
 fprintf(fid,' 0 0 %g, 0 %g %g',labelSize*0.02,-labelSize*0.2,labelSize*0.02);
 fprintf(fid,']');
 fprintf(fid,'}');
 fprintf(fid,'coordIndex\n');
 fprintf(fid,'[ 0 1 ]');
 fprintf(fid,'color Color { color [ 1.0 0.0 0.0]}');
 fprintf(fid,'colorIndex');
 fprintf(fid,'[ 0 ]');
 fprintf(fid,'}');
 fprintf(fid,'}');

 fprintf(fid,'Transform');
 fprintf(fid,'{');
 fprintf(fid,'translation 0 %g %g\n',-labelSize,labelSize*0.02);
 fprintf(fid,'children');
 fprintf(fid,'[');
 fprintf(fid,'labelShape');
 fprintf(fid,'{');
 fprintf(fid,'label "%g"\n',i);
 if i == labels(1) 
 if flip == 0
 fprintf(fid,'just "BEGIN"',i);
 else
 fprintf(fid,'just "END"',i);
 end
 elseif i == labels(3)
 if flip == 0
 fprintf(fid,'just "END"',i);
 else
 fprintf(fid,'just "BEGIN"',i);
 end
 else
 fprintf(fid,'just "MIDDLE"',i);
 end
 fprintf(fid,'size %g',labelSize);
 fprintf(fid,'}');
 fprintf(fid,']');
 fprintf(fid,'}');
 fprintf(fid,']');
 fprintf(fid,'}\n');
end
fprintf(fid,'Transform');
fprintf(fid,'{');
fprintf(fid,'translation %g %g 0\n',((labels(3)+labels(1))/2-labels(1))*axscale,-2*labelSize);
if flip ~= 0
 fprintf(fid,'rotation 0 1 0 %g\n',pi);
end
fprintf(fid,'children');
fprintf(fid,'[');
fprintf(fid,'Transform');
fprintf(fid,'{');
fprintf(fid,'translation 0 0 %g\n',labelSize*0.02);
fprintf(fid,'children');
fprintf(fid,'[');
fprintf(fid,'Shape');
fprintf(fid,'{ ');
fprintf(fid,'geometry Text \n');
fprintf(fid,'{');
fprintf(fid,'string "%s"\n',title);
fprintf(fid,'fontStyle FontStyle\n');
fprintf(fid,'{');
fprintf(fid,'size %g\n',labelSize);
fprintf(fid,'justify "MIDDLE"\n');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'appearance Appearance');
fprintf(fid,'{');
fprintf(fid,'material Material');
fprintf(fid,'{');
fprintf(fid,'diffuseColor 1 0 0\n');
fprintf(fid,'emissiveColor 0.3 0 0\n');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,'}');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,']');
fprintf(fid,'}\n');




