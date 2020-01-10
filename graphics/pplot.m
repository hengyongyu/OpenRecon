function pplot(p,varargin)

  c = 'g';
  if nargin==2, c = varargin{1}; end

  if nargin<3
    opts = { 'rs', ...
             'LineWidth',1, ...
             'MarkerEdgeColor','k', ...
             'MarkerFaceColor',c, ...
             'MarkerSize',5
           };
  else
    opts = varargin;
  end
  
  if size(p,1)==3
    plot3(p(1,:),p(2,:),p(3,:),opts{:});
  elseif size(p,2)==3
    plot3(p(:,1)',p(:,2)',p(:,3)',opts{:});
  else
    plot(p(1,:),p(2,:),opts{:});
  end
  