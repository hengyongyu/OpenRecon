function UpdateDisplay(hobj,evdt)
  
  if nargin==1
    handles = hobj;
  else
    handles = guidata(hobj);
  end
  
  lowhigh = cell2mat(get(handles.Range,'Value'));
  if length(handles.ImagePanel)==1
    DisplayImage(handles.ImagePanel,handles.data,lowhigh);
    return;
  end
  
  [ny,nx,nz] = size(handles.data);
  point = get(handles.Point,'Value');
  [sx,sy,sz] = deal(point{:});
  [sx,sy,sz] = deal(round(sx),round(sy),round(sz));
  sy = ny-sy+1;
  
  data = DisplayData(handles.data,'x',sx);
  DisplayImage(handles.ImagePanel(1),data,lowhigh);
  set(handles.ImageLine(1,1),'XData',[sz sz]);
  set(handles.ImageLine(1,2),'YData',[sy sy]);
  set(handles.PointText(1),'String',num2str(sx));
  
  data = DisplayData(handles.data,'y',sy);
  DisplayImage(handles.ImagePanel(2),data,lowhigh);
  set(handles.ImageLine(2,1),'XData',[sx sx]);
  set(handles.ImageLine(2,2),'YData',[sz sz]);
  set(handles.PointText(2),'String',num2str(sy));
  
  data = DisplayData(handles.data,'z',sz);
  DisplayImage(handles.ImagePanel(3),data,lowhigh);
  set(handles.ImageLine(3,1),'XData',[sx sx]);
  set(handles.ImageLine(3,2),'YData',[sy sy]);
  set(handles.PointText(3),'String',num2str(sz));

  
% --------------------------------------------------------------------
function DisplayImage(h,data,range)
  
  set(h,'UserData',double(data));
  nlev = size(colormap,1);
  if diff(range)
    data = 1+(nlev-1)*(data-range(1))/(range(2)-range(1));
  end
  set(h,'CData',data);
  
  
% --------------------------------------------------------------------
function data = DisplayData(data,type,indx)
  
  switch type
   case 'x'
    data = permute(data(:,indx,:),[1,3,2]);
   case 'y'
    data = permute(data(indx,:,:),[3,2,1]);
   case 'z'
    data = data(:,:,indx);
  end
