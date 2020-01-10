function ret = imhdr(P,varargin)

%imhdr: Read or write ANALYZE compatible image header file.
  
  if nargin == 0
    ret = struct('dimens',  [1,1,1], ...
                 'voxel',   [1,1,1], ...
                 'scale',   1,       ...
                 'type',    2,       ...
                 'offset',  0,       ...
                 'origin',  [0,0,0], ...
                 'endian',  'B',     ...
                 'header',  0,       ...
                 'descrip', ['ANALYZE compatible']);
    return;
  end
  
  % ensure correct suffix {.hdr}
  P = deblank(P);
  q = length(P);
  if q >= 4 & P(q - 3) == '.', P = P(1:(q - 4)); end
  P = [P '.hdr'];

  if nargin == 1
    ret = ReadHeader(P);
  else
    ret = WriteHeader(P,varargin{:});
  end
%_______________________________________________________________________

  
function params = ReadHeader(P)
% reads a header
% FORMAT [DIM VOX SCALE TYPE OFFSET ORIGIN DESCRIP] = spm_hread(P);
%
% P       - filename       (e.g spm or spm.img)
% DIM     - image size       [i j k [l]] (voxels)
% VOX     - voxel size       [x y z [t]] (mm [secs])
% SCALE   - scale factor
% TYPE    - datatype (integer - see spm_type)
% OFFSET  - offset (bytes)
% ORIGIN  - origin [i j k]
% DESCRIP - description string
%___________________________________________________________________________
%
% spm_hread reads variables into working memory from a SPM/ANALYZE
% compatible header file.  If the header does not exist global defaults
% are used.  The 'originator' field of the ANALYZE format has been
% changed to ORIGIN in the SPM version of the header.  funused1 of the
% ANALYZE format is used for SCALE
%
% see also dbh.h (ANALYZE) spm_hwrite.m and spm_type.m
%
%__________________________________________________________________________
% @(#)spm_hread.m 2.7 99/10/29

  % open header file
  fid = fopen(P,'r','native');

  if fid == -1
    error(['Error opening the header file ' P '.']);
  end

  % read (struct) header_key
  fseek(fid,0,'bof');

  otherendian = 0;
  sizeof_hdr = fread(fid,1,'int32');
  if sizeof_hdr==1543569408,
    % Appears to be other-endian Re-open other-endian
    fclose(fid);
    [COMPUTER,MAXSIZE,ENDIAN] = computer;
    if ENDIAN == 'B'
      fid = fopen(P,'r','ieee-le');
    else,
      fid = fopen(P,'r','ieee-be');
    end;
    fseek(fid,0,'bof');
    sizeof_hdr = fread(fid,1,'int32');
    otherendian = 1;
  end;

  data_type     = SetString(fread(fid,10,'char'))';
  db_name       = SetString(fread(fid,18,'char'))';
  extents       = fread(fid,1,           'int32');
  session_error = fread(fid,1,           'int16');
  regular       = SetString(fread(fid,1, 'char'))';
  hkey_un0      = SetString(fread(fid,1, 'char'))';

  % read (struct) image_dimension
  fseek(fid,40,'bof');

  dim        = fread(fid,8,              'int16');
  vox_units  = SetString(fread(fid,4,    'char'))';
  cal_units  = SetString(fread(fid,8,    'char'))';
  unused1    = fread(fid,1,              'int16');
  datatype   = fread(fid,1,              'int16');
  bitpix     = fread(fid,1,              'int16');
  dim_un0    = fread(fid,1,              'int16');
  pixdim     = fread(fid,8,              'float');
  vox_offset = fread(fid,1,              'float');
  funused1   = fread(fid,1,              'float');
  funused2   = fread(fid,1,              'float');
  funused3   = fread(fid,1,              'float');
  cal_max    = fread(fid,1,              'float');
  cal_min    = fread(fid,1,              'float');
  compressed = fread(fid,1,              'int32');
  verified   = fread(fid,1,              'int32');
  glmax      = fread(fid,1,              'int32');
  glmin      = fread(fid,1,              'int32');

  % read (struct) data_history
  fseek(fid,148,'bof');

  descrip     = SetString(fread(fid,80,  'char'))';
  aux_file    = SetString(fread(fid,24,  'char'))';
  orient      = fread(fid,1,             'char');
  origin      = fread(fid,5,             'int16');
  generated   = SetString(fread(fid,10,  'char'))';
  scannum     = SetString(fread(fid,10,  'char'))';
  patient_id  = SetString(fread(fid,10,  'char'))';
  exp_date    = SetString(fread(fid,10,  'char'))';
  exp_time    = SetString(fread(fid,10,  'char'))';
  hist_un0    = SetString(fread(fid,3,   'char'))';
  views       = fread(fid,1,             'int32');
  vols_added  = fread(fid,1,             'int32');
  start_field = fread(fid,1,             'int32');
  field_skip  = fread(fid,1,             'int32');
  omax        = fread(fid,1,             'int32');
  omin        = fread(fid,1,             'int32');
  smax        = fread(fid,1,             'int32');
  smin        = fread(fid,1,             'int32');

  fclose(fid);

  if isempty(smin)
    error(['There is a problem with the header file ' P '.']);
  end
                
  params.dimens  = dim(2:4)';
  params.voxel   = pixdim(2:4)';
  params.scale   = ~funused1 + funused1;
  if otherendian == 1 & datatype ~= 2,
    params.type  = datatype*256;
  else
    params.type  = datatype;
  end;
  params.offset  = vox_offset;
  params.origin  = origin(1:3)';
  params.endian  = hkey_un0;
  params.header  = dim_un0;
  params.descrip = descrip(1:max(find(descrip)));
%_______________________________________________________________________


function out = SetString(in)
  tmp = find(in == 0);
  tmp = min([min(tmp) length(in)]);
  out = setstr(in(1:tmp));
%_______________________________________________________________________


function s = WriteHeader(P,DIM,VOX,SCALE,TYPE,OFFSET,ORIGIN,DESCRIP)
% writes a header
% FORMAT [s] = spm_hwrite(P,DIM,VOX,SCALE,TYPE,OFFSET,ORIGIN,DESCRIP);
%
% P       - filename         (e.g 'spm' or 'spm.img')
% DIM     - image size       [i j k [l]] (voxels)
% VOX     - voxel size       [x y z [t]] (mm [sec])
% SCALE   - scale factor
% TYPE    - datatype (integer - see spm_type)
% OFFSET  - offset (bytes)
% ORIGIN  - [i j k] of origin  (default = [0 0 0])
% DESCRIP - description string (default = 'spm compatible')
%
% s       - number of elements successfully written (should be 348)
%___________________________________________________________________________
%
% spm_hwrite writes variables from working memory into a SPM/ANALYZE
% compatible header file.  The 'originator' field of the ANALYZE format has
% been changed to ORIGIN in the SPM version of the header. funused1
% of the ANALYZE format is used for SCALE
%
% see also dbh.h (ANALYZE) spm_hread.m and spm_type.m
%
%__________________________________________________________________________
% @(#)spm_hwrite.m 2.2 99/10/29

  if nargin == 2
    params  = DIM;
    DIM     = params.dimens;
    VOX     = params.voxel;
    SCALE   = params.scale;
    TYPE    = params.type;
    OFFSET  = params.offset;
    ORIGIN  = params.origin;
    ENDIAN  = params.endian;
    DESCRIP = params.descrip;
  end

  % For byte swapped data-types, also swap the bytes around in the headers.
  mach = 'native';
  if 0
  if TYPE == 1,
    [COMPUTER,MAXSIZE,ENDIAN] = computer;
    if ENDIAN == 'B',
      mach = 'ieee-le';
    else,
      mach = 'ieee-be';
    end;
    %TYPE = spm_type(spm_type(TYPE));
  end;
  end
  fid = fopen(P,'w',mach);

  if (fid == -1),
    error(['Error opening ' P '. Check that you have write permission.']);
  end;
  data_type  = ['dsr      ' 0];

  P       = [P '                  '];
  db_name = [P(1:17) 0];

  % set header variables
  DIM        = DIM(:)'; if size(DIM,2) < 4; DIM = [DIM 1]; end
  VOX        = VOX(:)'; if size(VOX,2) < 4; VOX = [VOX 0]; end
  dim        = [4 DIM(1:4) 0 0 0]; 
  pixdim     = [0 VOX(1:4) 0 0 0];
  vox_offset = OFFSET;
  funused1   = SCALE;
  glmax      = 1;
  glmin      = 0;
  bitpix     = 0;
  descrip    = zeros(1,80);
  aux_file   = ['none                   ' 0];
  origin     = [0 0 0 0 0];

  if TYPE == 1;  bitpix = 1;  glmax = 1;        glmin = 0; end
  if TYPE == 2;  bitpix = 8;  glmax = 255;      glmin = 0; end
  if TYPE == 4;  bitpix = 16; glmax = 32767;    glmin = 0; end
  if TYPE == 8;  bitpix = 32; glmax = (2^31-1); glmin = 0; end
  if TYPE == 16; bitpix = 32; glmax = 1;        glmin = 0; end
  if TYPE == 64; bitpix = 64; glmax = 1;        glmin = 0; end

  if  exist('ORIGIN','var'),  origin = [ORIGIN(:)' 0 0]; end
  if ~exist('ENDIAN','var'),  ENDIAN = '0'; end
  if ~exist('DESCRIP','var'), DESCRIP = 'ANALYZE compatible'; end

  d          = 1:min([length(DESCRIP) 79]);
  descrip(d) = DESCRIP(d);

  fseek(fid,0,'bof');

  % write (struct) header_key
  fwrite(fid,348,       'int32');
  fwrite(fid,data_type, 'char' );
  fwrite(fid,db_name,   'char' );
  fwrite(fid,0,         'int32');
  fwrite(fid,0,         'int16');
  fwrite(fid,'r',       'char' );
  fwrite(fid,ENDIAN,    'char' );

  % write (struct) image_dimension
  fseek(fid,40,'bof');

  fwrite(fid,dim,       'int16');
  fwrite(fid,'mm',      'char' );
  fwrite(fid,0,         'char' );
  fwrite(fid,0,         'char' );

  fwrite(fid,zeros(1,8),'char' );
  fwrite(fid,0,         'int16');
  fwrite(fid,TYPE,      'int16');
  fwrite(fid,bitpix,    'int16');
  fwrite(fid,0,         'int16');
  fwrite(fid,pixdim,    'float');
  fwrite(fid,vox_offset,'float');
  fwrite(fid,funused1,  'float');
  fwrite(fid,0,         'float');
  fwrite(fid,0,         'float');
  fwrite(fid,0,         'float');
  fwrite(fid,0,         'float');
  fwrite(fid,0,         'int32');
  fwrite(fid,0,         'int32');
  fwrite(fid,glmax,     'int32');
  fwrite(fid,glmin,     'int32');

  % write (struct) image_dimension
  fwrite(fid,descrip,   'char');
  fwrite(fid,aux_file,  'char');
  fwrite(fid,0,         'char');
  fwrite(fid,origin,    'int16');
  if fwrite(fid,zeros(1,85), 'char')~=85
    fclose(fid);
    %spm_unlink(P);
    error(['Error writing ' P '. Check your disk space.']);
  end

  s = ftell(fid);
  fclose(fid);
