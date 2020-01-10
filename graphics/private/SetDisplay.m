function SetDisplay(arg,handles,varargin)

  switch arg
   case 'ShowPoint'
    set(handles.ShowPoint,'Value',varargin{1});
    
   case 'ShowGraph'
    set(handles.ShowGraph,'Value',varargin{1});
   
   case 'Windowing'
    value = GetValue(varargin{1});
    set(handles.Limits,{'Value'},value);
    value{1} = num2str(value{1});
    value{2} = num2str(value{2});
    set(handles.LimTxt,{'String'},value);
    if nargin>3
      set(handles.Limits,{'Min','Max'},GetValue(varargin{2}));
    end

   case 'Point'
    set(handles.Point,{'Value'},GetValue(varargin{1}));
  end

  UpdateDisplay(handles);
  
  
% --------------------------------------------------------------------
function value = GetValue(value)
  
  if ~iscell(value), value = num2cell(value); end
