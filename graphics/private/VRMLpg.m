function VRMLpg(fid,xlabels, xstart, xfinish, xscale, ylabels, ystart, yfinish, yscale, labelSize)
%
% Function to plot a grid of lines in VRML 2.0 format
%
% Copyright Craig Sayers and WHOI 1996.
%

xdirn = (xfinish-xstart)/norm(xfinish-xstart);
ydirn = (yfinish-ystart)/norm(yfinish-ystart);

fprintf(fid,'Shape\n');
fprintf(fid,'{');
fprintf(fid,'geometry IndexedLineSet');
fprintf(fid,'{');
fprintf(fid,'colorPerVertex FALSE ');
fprintf(fid,'coord Coordinate');
fprintf(fid,'{');
fprintf(fid,'point\n');
fprintf(fid,'[');

% Begin by drawing lines parallel to the y axis
for x=xlabels(1):xlabels(2):xlabels(3)
 a = ystart + (x-xlabels(1))*xscale * xdirn;
 b = yfinish + (x-xlabels(1))*xscale * xdirn;
 fprintf(fid,'%g %g %g,', a(1),a(2),a(3));
 fprintf(fid,'%g %g %g,\n', b(1),b(2),b(3));
end
if x ~=xlabels(3)
 x = xlabels(3);
 a = ystart + (x-xlabels(1))*xscale * xdirn;
 b = yfinish + (x-xlabels(1))*xscale * xdirn;
 fprintf(fid,'%g %g %g,', a(1),a(2),a(3));
 fprintf(fid,'%g %g %g,\n', b(1),b(2),b(3));
end

% Now draw lines parallel to the x axis
for y=ylabels(1):ylabels(2):ylabels(3)
 a = xstart + (y-ylabels(1))*yscale * ydirn;
 b = xfinish + (y-ylabels(1))*yscale * ydirn;
 fprintf(fid,'%g %g %g,', a(1),a(2),a(3));
 fprintf(fid,'%g %g %g,\n', b(1),b(2),b(3));
end
if y ~= ylabels(3)
 y = ylabels(3);
 a = xstart + (y-ylabels(1))*yscale * ydirn;
 b = xfinish + (y-ylabels(1))*yscale * ydirn;
 fprintf(fid,'%g %g %g,', a(1),a(2),a(3));
 fprintf(fid,'%g %g %g,\n', b(1),b(2),b(3));
end
fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'coordIndex\n');
fprintf(fid,'[');

% Index lines parallel to the y axis
count=0;
for x=xlabels(1):xlabels(2):xlabels(3)
 fprintf(fid,'%g %g -1\n',count,count+1);
 count = count+2;
end
if x ~=xlabels(3)
 fprintf(fid,'%g %g -1\n',count,count+1);
 count = count+2;
end
% Index lines parallel to the x axis
for y=ylabels(1):ylabels(2):ylabels(3)
 fprintf(fid,'%g %g -1\n',count,count+1);
 count = count+2;
end
if y ~= ylabels(3)
 fprintf(fid,'%g %g -1\n',count,count+1);
 count = count+2;
end

fprintf(fid,']');
fprintf(fid,'color Color { color [ 1.0 0.0 0.0]}');
fprintf(fid,'colorIndex');
fprintf(fid,'[');

% Color lines parallel to the y axis
for x=xlabels(1):xlabels(2):xlabels(3)
 fprintf(fid,'0\n',count);
end
if x ~=xlabels(3)
 fprintf(fid,'0\n',count);
end

% Color lines parallel to the x axis
for y=ylabels(1):ylabels(2):ylabels(3)
 fprintf(fid,'0\n',count);
end
if y ~= ylabels(3)
 fprintf(fid,'0\n',count);
end

fprintf(fid,']');
fprintf(fid,'}');
fprintf(fid,'}\n');
