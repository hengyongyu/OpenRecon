function varargout = GetDisplay(arg,handles,varargin)

  switch arg
   case 'ShowPoint'
    varargout{1} = get(handles.ShowPoint,'Value');
   
   case 'ShowGraph'
    varargout{1} = get(handles.ShowGraph,'Value');
   
   case 'ShowTips'
    varargout{1} = get(handles.ShowTips,'Value');
   
   case 'Overlay'
    varargout{1} = get(handles.Display(4),'Value');
   
   case 'Windowing'
    lims = cell2mat(get(handles.Limits,'Value'));
    if nargout==1
      varargout{1} = lims;
    else
      [varargout{1:2}] = deal(lims(1),lims(2));
    end

   case 'Point'
    if isfield(handles,'Point')
      [varargout{1:nargout}] = GetSliders(handles.Point,@round);
    else
      [varargout{1:nargout}] = deal(0,0,0);
    end
  end

  
% --------------------------------------------------------------------
function varargout = GetSliders(hsldr,f)
  
  value = cell2mat(get(hsldr,'Value'));
  if nargin==2, value = feval(f,value); end
  if nargout==1
    varargout{1} = value;
  else
    [varargout{1:3}] = deal(value(1),value(2),value(3));
  end
