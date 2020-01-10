%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to demonstrate the applicaiton of analytic cone-beam reconstrution withe curved detector. 
% The codes were developed by Hengyong Yu, Department of Electrical and Computer Engineering, University of Massachusetts Lowell.
% Email: hengyong-yu@ieee.org
% Version 2, Dec. 23, 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;


% dataFolder = 'D:\Yanbo\Data\From_Robert_20161013\p2\75536_Anonymous_CT__601_RAW_20161005_122612_353008_2016_10_12_16_35_03_864000_417921596_ptr\';
%dataFolder = 'D:\Yanbo\Data\From_Robert_20161013\p1\75536_Anonymous_CT__601_RAW_20161006_174339_292988_2016_10_12_16_27_45_094000_420600202_ptr\';
 dataFolder = 'D:\UML_Workspace\MatlabFiles\Yu_V1_04162016\75536_Anonymous_CT__601_RAW_20161006_174339_292988_2016_10_12_16_27_45_094000_420600202_ptr\';

load([dataFolder, 'dataInfo'])  
load([dataFolder, 'dataInfo_UID20'])  
load([dataFolder, 'dataInfo_UID50'])  

id_high_low = 1; % id_high_low: 1: high; 2: low
viewStart = 100;
viewEnd = 1800;
proj3D = zeros(viewEnd-viewStart+1, dataInfo.ModeParXML.Type.ChnNum(id_high_low), dataInfo.ModeParXML.ModePar.NoOfSlicesDMS);
j= 1;
for i = viewStart:viewEnd
projName = ['proj_', num2str(i)];
    headerName = ['header_', num2str(i)];
    load([dataFolder, projName], 'proj')
    proj=proj{id_high_low};
    proj=proj(end:-1:1,end:-1:1);
    proj3D(j, :, :) = proj;%{id_high_low};
%     proj3D(j, :, :) = flipud(fliplr(proj{id_high_low}));
%     proj3D(end-j+1, :, :) = (proj{id_high_low});
%     proj3D(end-j+1, :, :) = fliplr(proj{id_high_low});
%     proj3D(end-j+1, :, :) = flipud(proj{id_high_low});
%     proj3D(end-j+1, :, :) = flipud(proj{id_high_low});
%     proj3D(j, :, :) = flipud(proj{id_high_low});
    j = j+1;
end

Proj = proj3D;

time = cputime;
% Rebinning (Convert conebeam to parallel beam)
% The following lines 13-23 are used to define the helical scanning geometry for a micro-CT 
SO = 59.5;%57;%10;          % The distance from source to object (cm)
DO = 108.56-SO;%104-57;%5;           % The distance from detector to object center(cm)
YL = dataInfo.ModeParXML.Type.ChnNum(id_high_low);%350;         % Detector cell number along the horizontal direction of detector array
YLC= (1+YL)*0.5+1.0;  % Detector center along the horizontal direction of detector array
ZL = dataInfo.ModeParXML.ModePar.NoOfSlicesDMS;%20;          % Detector cell number along the vertical direction of detector array
ZLC= (1+ZL)*0.5;  % Detector center along the vertical direction of detector array
DecAngle = YL*0.10/(SO+DO);%YL*0.06/(SO+DO);%0.232; % Detector array beam angle along the horizontal direction (rad)
DecHeigh = ZL*0.06*(SO+DO)/SO;%0.2;   % Detector array height along the vertical direction (cm)

N_2pi    = 2*dataInfo.ScanDescr.FramesPerRotation;%360;   % The projections/views number for each turn of scan
N_Turn   = (viewEnd-viewStart+1)/N_2pi;%3;     % The number of turns for the whole helical scan

h =abs(dataInfo_UID20.TablePosition(N_2pi+1) - dataInfo_UID20.TablePosition(1))/1000/10/DecHeigh;
% h        = 1;     % Helical pitch related to detector height
%The following line 25-28 are used to define the reconstruction paramters
WtInd    = 3;     %1:Redundancy weighting; 2:2D weigthing; 3: 3D weighting 
k1       = 5;     % The order to define the 3D weighting function
delta    = 60;    % The range to define smoothness of 2D weigthing function 
HSCoef   = 0.65;   % This is used to define the half-scan range              

ObjR  = 20;%1.1;      % Diameter of imaginh object
SSO   = 128;       % Define the size of the reconstructed image
XN    = 2*SSO;
YN    = 2*SSO;
ZN    = SSO;%2*SSO;
XC    = (XN+1)*0.5;
YC    = (YN+1)*0.5;
ZC    = (ZN+1)*0.5;
BetaS =  -round((viewEnd-viewStart+1)/2)*2*pi/N_2pi;%-N_Turn*pi;
BetaE =  (viewEnd-viewStart )*2*pi/N_2pi+ BetaS; %N_Turn*pi;
ViewN = (viewEnd-viewStart+1);% N_Turn*N_2pi+1;

DecWidth = tan(DecAngle*0.5)*(SO+DO)*2;
dYL   =  DecWidth/YL;
dZL   =  DecHeigh/ZL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanGeom = struct( 'ScDet',  [SO DO YL ZL DecAngle DecHeigh YLC ZLC h],  ...
                   'Proj',   [BetaS BetaE ViewN N_2pi], ...
                   'Obj',    [ObjR XN YN ZN XC YC ZC], ...
                   'Rec',    [delta HSCoef k1]);            
% Generating projections or load the projections
disp('Generating the cone beam projections');
% [ScPos Proj] = Conebeam_Curve_CreateProj_CB_Helical_Spectrum(ScanGeom);
%load SpectralProjections;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rebinning conebeam to parallel beam 
disp('Paralllel rebinning from the conebeam projections');
Proj = Parallel_Rebinning_CB_Curve(Proj,ScanGeom);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preweighting the conebeam projections
disp('PreWeighting the cone beam projection');
%for i=1:ViewN
        for j=1:YL
          t=(j-YLC)*dYL;
            for k=1:ZL
              b=(k-ZLC)*dZL;
              Proj(:,j,k) = Proj(:,j,k)*SO*SO/sqrt(SO^4+(SO*b)^2-(b*t)^2);
            end
        end
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Perform Ramp filtering
disp('Filtering the cone beam projection');
n = -YL:YL;
hsl=-2./((pi^2)*(4*n.*n-1))/dYL;
%plot(n,hsl); 
NN = 2^ceil(log(YL*3)/log(2));
HS = zeros(1,NN);
HS(1:YL+1)= hsl(YL+1:2*YL+1);
HS(end-YL+1:end)=hsl(1:YL);
FtS = fft(HS);
fpwd = zeros(size(Proj));
for i=1:ViewN
    for k=1:ZL
     FtP = fft(Proj(i,:,k),NN);
     tep = ifft(FtS.*FtP);
     fpwd(i,:,k) = real(tep(1:YL)); 
    end
end
%save fpwd.mat fpwd;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Backproject the filtered data into the 3D space
ScanGeom.ScDet(5) = DecWidth;
disp('BackProjection the filtered projection');
ctimage = zeros(XN,YN,ZN);
switch(WtInd)
    case 1 %1/2 redundancy weigthing
        Parallel_FDK_Helical_NOWeighting(ScanGeom,fpwd,ctimage);
%         save RecResNoW ctimage;
    case 2 % 2D weighting
        Parallel_FDK_Helical_2DWeighting(ScanGeom,fpwd,ctimage);
%         save RecRes2DW ctimage;
    case 3 %3D weighting
        Parallel_FDK_Helical_3DWeighting(ScanGeom,fpwd,ctimage);
%         save RecRes3DW ctimage;
    otherwise %1/2 redundancy weigthing
        Parallel_FDK_Helical_NOWeighting(ScanGeom,fpwd,ctimage);
%         save RecResNoW ctimage;
end;
imdisp(ctimage)

time =cputime-time


