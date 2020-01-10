function handles = arrow( x1,y1,x2,y2,varargin )
%
% arrow - plots an arrow to the current plot
%
% format:   handles = arrow( x1,y1,x2,y2 [,options...] )
%
% input:    x1,y1   - starting point
%           x2,y2   - end point
%           options - come as pairs of "property","value" as defined for
%                     "line" and "patch" controls, see matlab help for
%                     listing of these properties. note that not all
%                     properties where added, one might add them at the
%                     end of this file.
%                     
%                     additional options are:
%                     'headwidth':  relative to complete arrow size,
%                     default value is 0.07 'headheight': relative to
%                     complete arrow size, default value is 0.15 (encoded
%                     are maximal values if pixels, for the case that the
%                     arrow is very long)
%
% output:   handles - handles of the graphical elements building the arrow
%
% Example:  arrow( -1,-1,15,12,'linewidth',2,'color',[0.5 0.5 0.5], ...
%                  'facecolor',[0.5 0.5 0.5] );
%           arrow( -1,-1,15,12,'linewidth',2,'colors',[0.5 0.5 0.5] );
%           arrow( 0,0,5,4,'linewidth',2,'headwidth',0.25,'headheight',0.33 );

  % =============================================
  % constants (can be edited)
  % =============================================
  alpha       = 0.15;   % head length
  beta        = 0.07;   % head width
  max_length  = 22;
  max_width   = 10;

  % =============================================
  % check if head properties are given
  % =============================================
  % if ratio is always fixed, this section can be removed!
  if ~isempty( varargin )
    for c = 1:floor(length(varargin)/2)
      try
        switch lower(varargin{c*2-1})
          % head properties - do nothing, since handled above already
         case 'headheight',alpha = max( min( varargin{c*2},1 ),0.01 );
         case 'headwidth', beta = max( min( varargin{c*2},1 ),0.01 );
        end
      catch
        fprintf( 'unrecognized property or value for: %s\n',varargin{c*2-1} );
      end
    end
  end

  % =============================================
  % calculate the arrow head coordinates
  % =============================================
  x = zeros(3,length(x1));
  y = x;
  z = x;
  for k=1:length(x1)
    [x(:,k),y(:,k),z(:,k)] = HeadCoords(x1(k),y1(k),x2(k),y2(k), ...
                                        alpha,beta,max_length,max_width);
  end
  
  % =============================================
  % plot arrow  (= line + patch of a triangle)
  % =============================================
  h1          = plot( [x1;x2],[y1;y2],'k' );
  h2          = patch( x,y,z );
  
  % =============================================
  % return handles
  % =============================================
  handles = [h1; h2];

  % =============================================
  % check if styling is required 
  % =============================================
  % if no styling, this section can be removed!
  if ~isempty( varargin )
    for c = 1:floor(length(varargin)/2)
      try
        switch lower(varargin{c*2-1})

          % only patch properties    
         case 'edgecolor'
          set( h2,'EdgeColor',varargin{c*2} );
         case 'facecolor'
          set( h2,'FaceColor',varargin{c*2} );
         case 'facelighting'
          set( h2,'FaceLighting',varargin{c*2} );
         case 'edgelighting'
          set( h2,'EdgeLighting',varargin{c*2} );
          
          % only line properties    
         case 'color'
          set( h1,'Color',varargin{c*2} );
          
          % all colors
         case 'colors'
          set( h2,'EdgeColor',varargin{c*2} );
          set( h2,'FaceColor',varargin{c*2} );
          set( h2,'FaceLighting',varargin{c*2} );
          set( h2,'EdgeLighting',varargin{c*2} );
          set( h1,'Color',varargin{c*2} );
          
          % shared properties    
         case 'linestyle'
          set( handles,'LineStyle',varargin{c*2} );
         case 'linewidth'
          set( handles,'LineWidth',varargin{c*2} );
         case 'parent'
          set( handles,'parent',varargin{c*2} );
          
          % head properties - do nothing, since handled above already
         case 'headwidth'
         case 'headheight'
          
        end
      catch
        fprintf( 'unrecognized property or value for: %s\n',varargin{c*2-1} );
      end
    end
  end

  
function [x,y,z] = HeadCoords(x1,y1,x2,y2,alpha,beta,max_length,max_width)
  
  den         = x2 - x1 + eps;         % make sure no devision by zero occurs
  teta        = atan( (y2-y1)/den ) + pi*(x2<x1) - pi/2;% angle of arrow
  cs          = cos(teta);                              % rotation matrix
  ss          = sin(teta);
  R           = [cs ss; -ss cs];
  line_length = sqrt( (y2-y1)^2 + (x2-x1)^2 );          % sizes
  head_length = min( line_length*alpha,max_length );
  head_width  = min( line_length*beta,max_length );
  x0          = x2*cs + y2*ss;                          % build head coordinats
  y0          = -x2*ss + y2*cs;
  y           = [x0              y0
                 x0+head_width/2 y0-head_length
                 x0-head_width/2 y0-head_length]*R;
  x           = y(:,1);
  y           = y(:,2);
  z           = [0;0;0];

  