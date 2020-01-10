function h = imdisp(varargin)

  name = inputname(1);
  data = squeeze(varargin{1});
  if nargin>1
    displims = varargin{2};
  else
    displims = [];
  end
  
  [hfig,himgs,hline,hlines] = DispLayout(name,size(data));
  DisplayConsole(hfig,data,displims);
  handles = guihandles(hfig);
  handles.ImagePanel = himgs;
    handles.CrossLine = hline;
  if ~isempty(hlines)
    handles.ImageLine = hlines;
  end
  handles.data = data;

  guidata(hfig,handles);
  UpdateDisplay(handles);
  set(hfig,'Visible','on');
  if nargout, h = handles; end
  

% --------------------------------------------------------------------
function [hfig,himgs,hline,hlines] = DispLayout(name,dtsz)

  % Display figure
  uipos = get(0,'defaultfigurePosition');
  uipos = [624 390 920 710];
  set(0,'ShowHiddenHandles','on');
  hfig = figure(...
      'Name',name,...
      'BackingStore','on',...
      'Menubar','figure',...
      'Toolbar','figure',...
      'NumberTitle','off',...
      'Color',0.8*[1 1 1],...
      'Colormap', gray(256),...
      'DoubleBuffer','on',...
      'Position',uipos,...
      'ResizeFcn',{@ResizeCallback}',...
      'PaperPositionMode','auto',...
      'Visible','off',...
      'Tag','imfig');
  if isempty(name)
    set(hfig,'Name',['Imdisp No. ' num2str(hfig)]);
  end

  % Projection view
  uipos = get(hfig,'Position');
  [uipos,width,height] = PanelSize(0.235,uipos,dtsz);
  h = uipanel(...
      'BackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
      'Position',uipos,...
      'BorderWidth',0,...
      'Tag','DisplayPanel');

  % Image panels
  axes(...
      'Parent',h,...
      'Layer','top',...
      'Units','normalized',...
      'Position',[0 0 width(1) height(1)],...
      'Visible','off');

  himgs = image(zeros(dtsz(1),dtsz(2)));
  axis image off;
  set(himgs,'ButtonDownFcn',{@ButtonDownCallback,'z',dtsz});
  hold on;
  hline = plot([1 1],[1 dtsz(1)],'y');
  set(hline,'Visible','off',...
            'HitTest','off');

  if length(dtsz)==2
    hlines = [];
    hold off;
    return;
  end
  
  hlines(3,1) = plot([1 1],[1 dtsz(1)],'b');
  hlines(3,2) = plot([1 dtsz(2)],[1 1],'g');
  hold off;

  axes(...
      'Parent',h,...
      'Layer','top',...
      'Units','normalized',...
      'Position',[0 height(1) width(1) height(2)],...
      'Visible','off');
  himgs(3) = himgs;
  himgs(2) = image(zeros(dtsz(3),dtsz(2)),...
                   'ButtonDownFcn',{@ButtonDownCallback,'y',dtsz});
  axis image xy off;
  hold on;
  hlines(2,1) = plot([1 1],[1 dtsz(3)],'b');
  hlines(2,2) = plot([1 dtsz(2)],[1 1],'r');
  hold off;

  axes(...
      'Parent',h,...
      'Layer','top',...
      'Units','normalized',...
      'Position',[width(1) 0 width(2) height(1)],...
      'Visible','off');
  himgs(1) = image(zeros(dtsz(1),dtsz(3)),...
                   'ButtonDownFcn',{@ButtonDownCallback,'x',dtsz});
  axis image off;
  hold on;
  hlines(1,1) = plot([1 1],[1 dtsz(1)],'r');
  hlines(1,2) = plot([1 dtsz(3)],[1 1],'g');
  hold off;
  set(hlines,'HitTest','off');
  
  
% --------------------------------------------------------------------
function ButtonDownCallback(hobj,evdt,type,dtsz)
  
  handles = guidata(hobj);
  hline = handles.CrossLine;
  pos = get(gca,'CurrentPoint');
  pos = round(pos(1,1:2));

  if strcmp(get(gcf,'SelectionType'),'alt')
    % right button
    set(hline,'Visible','off');
    set(gcf,'WindowButtonMotionFcn',{@LineMotionCallback,hline,pos}, ...
            'WindowButtonUpFcn',{@LineStopCallback,hline,pos});

  else

    set(hline,'Visible','off');
    try
      cur = cell2mat(get(handles.Point,'Value'));
      switch type
       case 'x'
        pos(2) = dtsz(1)-pos(2)+1;
        cur([3 2]) = pos(:);
       case 'y'
        cur([1 3]) = pos(:);
       case 'z'
        pos(2) = dtsz(1)-pos(2)+1;
        cur([1 2]) = pos(:);
      end
      set(handles.Point,{'Value'},num2cell(cur));
    catch
    end
    UpdateDisplay(hobj,evdt);
  
  end
  
  
% --------------------------------------------------------------------
function cur = LineMotionCallback(hobj,evdt,hline,pos)

  cur = get(gca,'CurrentPoint');
  cur = round(cur(1,1:2));
  set(hline,'Parent',gca, ...
            'XData',[pos(1),cur(1)], ...
            'YData',[pos(2),cur(2)], ...
            'Visible','on');
  drawnow;


% --------------------------------------------------------------------
function LineStopCallback(hobj,evdt,hline,pos)

  set(gcf,'WindowButtonMotionFcn','', ...
          'WindowButtonUpFcn','');
  cur = LineMotionCallback(hobj,evdt,hline,pos);
  
  if pos(1)==cur(1) & pos(2)==cur(2)
    return;
  end
  
  h = findobj(get(hline,'Parent'),'type','image');
  data = get(h,'UserData');
  handles = guidata(hobj);
  
  figure;
  improfile(data,[pos(1),cur(1)],[pos(2),cur(2)]);
  grid on;
  

% --------------------------------------------------------------------
function [uipos,width,height] = PanelSize(uipos,fgpos,dtsiz)

  margin = 10/fgpos(3);
  uipos = uipos+margin;
  if length(dtsiz)==2
    uipos = [uipos margin 1-uipos-margin 1-2*margin];
    width = 1;
    height = 1;
  else
    width = dtsiz([2 3])+[0 2];
    height = dtsiz([1 3])+[0 2];
    sums = [sum(width) sum(height)];
    width = width/sums(1);
    height = height/sums(2);

    ratio = sums(1)/sums(2)*fgpos(4)/fgpos(3);
    horz = (1-uipos-margin)*[1,1/ratio];
    vert = (1-2*margin)*[ratio 1];
    wtht = min(horz,vert);
    uipos = [uipos margin];
    uipos = max(uipos,[uipos(1) 0]+(1-uipos-wtht)/2);
    uipos = [uipos wtht];
  end
  
  
% --------------------------------------------------------------------
function ResizeCallback(hobj,evdt)

  handles = guidata(hobj);
  if isempty(handles) return; end
  
  fgpos = get(handles.imfig,'Position');
  uipos = get(handles.ConsolePanel,'Position');
  if uipos(4)>fgpos(4)
    uipos(4) = fgpos(4)-20;
  else
    uipos(2) = fgpos(4)-uipos(4)-10;
    
  end
  set(handles.ConsolePanel,'Position',uipos);
  uipos = PanelSize(uipos(3)/fgpos(3),fgpos,size(handles.data));
  set(handles.DisplayPanel,'Position',uipos);
