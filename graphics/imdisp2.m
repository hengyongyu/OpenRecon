function h = imdisp(varargin)

% h = imdisp([subplot], [xx], [yy], zz, [scale], [title])
%  show matrix zz as an image
%  options: choose subplot, show proper (x,y) axes, scale factor, title

% Copyright (C) 2000-2003 Shiying Zhao
% Copyright (C) 2004 CT/Micro-CT Laboratory
% Department of Radiology, University of Iowa

  DISP_COLORMAP = get(gcf,'colormap');
  if length(DISP_COLORMAP)<256, DISP_COLORMAP = gray(256); end
  
  scale = 1;
  titlestr = '';
  axisstr = 'image';
  xx = [];
  yy = [];
  isxy = 0;
  ii = 1;

  % subplot
  if length(varargin{1})==1
    if varargin{1}>111
      subplot(varargin{1})
    end
    ii = ii+1;
  end

  % xx, yy
  if ii>nargin, help(mfilename), error args; end
  if ndims(varargin{ii})==2 & min(size(varargin{ii}))==1
    xx = varargin{ii};
    ii = ii+1;
    if ii>nargin, help(mfilename), error 'need both xx,yy'; end
    if min(size(varargin{ii}))~=1, error 'both xx,yy need to be 1D'; end
    yy = varargin{ii};
    ii = ii+1;
    isxy = 1;
  end

  % zz
  if ii<=nargin
    zz = double(varargin{ii});
    ii = ii+1;
  else
    error 'no image?';
  end

  % title, scale
  while ii<=nargin
    arg = varargin{ii};
    if ischar(arg)
      if strcmp(arg,'equal')
	axisstr = arg;
      elseif strcmp(arg,'normal')
        ydirstr = arg;
      else
	titlestr = arg;
      end
    elseif isa(arg,'double')
      scale = arg;
      %if max(size(arg))~=1, error 'nonscalar scale?'; end
    else
      error 'unknown arg';
    end
    ii = ii+1;
  end

  if issparse(zz), zz = full(zz); end
  if any(size(zz)==1), zz = squeeze(zz); end

  if length(scale)==1
    zmin = min(zz(:));
    zmax = max(zz(:));
  else
    zmin = scale(1);
    zmax = scale(2);
    if length(scale)>2
      scale = scale(3);
    else
      scale = 1;
    end
  end
  
  if scale==0
    zmin = 0;
    scale = 1;
  elseif scale<0
    zmin = 0;
    scale = -scale;
  end
  if (zmax==zmin)
    fprintf('Uniform image %g [',zmin)
    fprintf(' %g',size(zz))
    fprintf(' ]\n')
    return
  end

  colormap(DISP_COLORMAP)
  n = size(colormap,1);
  zz = (n-1)*(zz-zmin)/(zmax-zmin);
  zz = 1+round(scale*zz);
  zz = min(zz,n);
  zz = max(zz,1);

  if ndims(zz)<3
    %zz = zz';
    if isxy
      hh = image(xx,yy,zz);
    else
      hh = image(zz);
    end
  else
    hh = image(Montage(zz));
  end

  set(gca,'TickDir','out')
  if exist('ydirstr','var'), set(gca,'YDir',ydirstr); end
  
  if nargout>0, h = hh; end

  axis(axisstr)
  xlabel(['Range: [' num2str(zmin) ', ' num2str(zmax) ']'])

  if ~isempty(titlestr), title(titlestr); end

  
function xo = Montage(xi)

%  Arrange 3d image slices as a 2d rectangular montage.

  if ndims(xi)>3, warning('4d not done'); end

  [nx,order] = sort(size(xi));
  %xi = permute(xi,[order(2:3),order(1)]);
  if order(1)~=3, xi = xi(end:-1:1,:,:); end
  
  % add white border
  %xi(:,end+1,:) = 256;
  %xi(end+1,:,:) = 256;
  
  [nx,ny,nz] = size(xi);
  if nx<ny
    mxx = ceil(sqrt(nz));
  else
    mxx = floor(sqrt(nz));
  end
  myy = ceil(nz/mxx);
  xo = zeros(nx*mxx,ny*myy);
  
  for iz=0:(nz-1)
    ixx = floor(iz/myy);
    iyy = iz-ixx*myy;
    xo([1:nx]+ixx*nx,[1:ny]+iyy*ny) = xi(:,:,iz+1);
  end
