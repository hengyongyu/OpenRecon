function [error,colDefTypes,colDefNames] = VRMLcf(fid,filename,protoname)
% Copy contents of VRML file (excluding the first line) to fid.

global FORMAT_TIME; 
global FORMAT_TRANSX;
global FORMAT_TRANSY;
global FORMAT_TRANSZ;
global FORMAT_TRANSXYZ;
global FORMAT_ROTX;
global FORMAT_ROTY;
global FORMAT_ROTZ;
global FORMAT_SCALAR;

[freadid,errmsg] = fopen(filename,'r');
if freadid == -1
  disp(' ');
  disp(['VRMLplot error - unable to open file:' filename ' for reading.']);
  error = -1;
  return;
end

%
% Check first line (which should contain the VRML header line
%
[vString, count] = fread(freadid, 15, 'char');
if count ~= 15
  disp(' ');
  disp(['VRMLplot error - unable to read file:' filename]);
  error = -1;
  return;
end
if( strcmp(setstr(vString'),'#VRML V2.0 utf8') == 0)
  disp(' ');
  disp(['VRMLplot error - file:' filename ' doesn''t start with "#VRML V2.0 utf8"']);
  error = -1;
  return;
end

%
% Skip remainder of first line
%
c = 0;
while( c ~= 10);
  [c, count] = fread(freadid, 1, 'char');
end;

%
% Now remember this spot in the file
%
start = ftell(freadid);

%
% read and copy every remaining line
%
[F,count] = fread(freadid,Inf,'uchar');
fwrite(fid,F,'uchar');
%
% Now search through file for PROTO definition
%
pos=1;
while pos < length(F)-7-length(protoname)
  if F(pos) == '#'
    while F(pos) ~= 10 & F(pos) ~= 13 & pos < length(F) 
      pos=pos+1; 
    end
  else
    test = setstr(F(pos:pos+5+length(protoname)))';
    if strcmp(test,[ 'PROTO ' protoname ]) == 1
      break;
    end
  end
  pos=pos+1;
end

if pos >= length(F)-7-length(protoname)
  disp(' ');
  disp(['VRMLplot error - unable to find "PROTO ' protoname '" in file:' filename]);
  error=-1;
  return;
end

for pos=pos:length(F)
  if F(pos) == '['
    break
  end
end

if pos >= length(F)
  disp(' ');
  disp(['VRMLplot error - unable to find "[" after "PROTO ' protoname '" in file:' filename]);
  error=-1;
  return;
end

% Now read definitions - assume each is on a separate line
% ( This is not optimal but neither are matlab's string functions! )
%
foundColor=0;
foundTransparency=0;
col=1;
space='                                                                      ';
while( F(pos) ~= ']' & pos < length(F) )
  if F(pos) == '#'
    while F(pos) ~= 10 & F(pos) ~= 13 & pos < length(F) pos=pos+1; end
  elseif strcmp(setstr(F(pos:pos+18))','field SFColor color') == 1
    pos=pos+18;
    foundColor=1;
  elseif strcmp(setstr(F(pos:pos+25))','field SFFloat transparency') == 1
    pos=pos+25;
    foundTransparency=1;
  elseif strcmp(setstr(F(pos:pos+6))','eventIn') == 1
    pos = pos+8;
    while ( F(pos) == 32 | F(pos) < 16 ) & pos < length(F) pos=pos+1; end
    eventType = [];
    while F(pos) ~=32 & F(pos) > 16 & pos < length(F)
      eventType = [ eventType F(pos) ];
      pos = pos+1; 
    end
    while ( F(pos) == 32 | F(pos) < 16 ) & pos < length(F) pos=pos+1; end
    eventName = [];
    while F(pos) ~=32 & F(pos) > 16 & pos < length(F) 
      eventName = [ eventName F(pos) ];
      pos = pos+1; 
    end
    eventType = setstr(eventType);
    eventName= setstr(eventName);
    colDefNames(col,:) = [ eventName space(1:32-length(eventName)) ];
    eventName = [ space(8) eventName ];
    if strcmp(eventType,'SFRotation')==1
      if strcmp(eventName(length(eventName)-3:length(eventName)),'rotx')
        colDefTypes(col) = FORMAT_ROTX;
      elseif strcmp(eventName(length(eventName)-3:length(eventName)),'roty')
        colDefTypes(col) = FORMAT_ROTY;
      elseif strcmp(eventName(length(eventName)-3:length(eventName)),'rotz')
        colDefTypes(col) = FORMAT_ROTZ;
      else                    
        disp(' ')
        disp(['VRMLplot error - unrecognized rotational event name in file:' filename])
        disp('  names of rotational events must end in rotx, roty or rotz')
        error=-1;
        return;
      end
    elseif strcmp(eventType,'SFVec3f')==1
      if strcmp(eventName(length(eventName)-7:length(eventName)),'transxyz')
        colDefTypes(col) = FORMAT_TRANSXYZ;
      elseif strcmp(eventName(length(eventName)-5:length(eventName)),'transx')
        colDefTypes(col) = FORMAT_TRANSX;
      elseif strcmp(eventName(length(eventName)-5:length(eventName)),'transy')
        colDefTypes(col) = FORMAT_TRANSY;
      elseif strcmp(eventName(length(eventName)-5:length(eventName)),'transz')
        colDefTypes(col) = FORMAT_TRANSZ;
      else                    
         disp(' ')
         disp(['VRMLplot error - unrecognized SFVec3f event name in file:' filename])
         disp('  names of translational events must end in transx, transy, transz or transxyz')
         error=-1;
         return;
      end
    elseif strcmp(eventType,'SFFloat')==1
      colDefTypes(col) = FORMAT_SCALAR;
    else
      disp(' ')
      disp(['VRMLplot - error reading eventIn ' eventName ' in file:' filename])
      disp('  currently only SFVec3f and SFRotation events are supported.')
      error=-1;
      return;
    end
    col = col+1;
  else
    pos=pos+1;
  end
end

if foundColor==0
  disp(' ')
  disp(['VRMLplot - error reading file:' filename])
  disp('  Prototype definition did not contain a color entry.')
  disp('  It should contain: field SFColor color 0.3 0.3 0.3.')
  error=-1;
  return;
end

if foundTransparency==0
  disp(' ')
  disp(['VRMLplot - error reading file:' filename])
  disp('  Prototype definition did not contain a transparency entry.')
  disp('  It should contain: field SFFloat transparency 0.0')
  error=-1;
  return;
end

%
fclose(freadid);
error=0;
