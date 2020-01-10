%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to demonstrate the applicaiton of analytic cone-beam reconstrution with flat-plane detector. 
% The codes were developed by Huihua Kong and Hengyong Yu, Department of
% Electrical and Computer Engineering, University of Massachusetts Lowell.
%  Email: hengyong-yu@ieee.org
% Version 2, Dec. 21, 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
time = cputime;
% Rebinning (Convert conebeam to parallel beam)
% The following lines 13-23 are used to define the helical scanning geometry for a micro-CT 
SO = 10;          % The distance from source to object (cm)
DO = 5;           % The distance from detector to object (cm)
YL = 350;         % Detector cell number along the horizontal direction of detector array
YLC= (1+YL)*0.5;  % Detector center along the horizontal direction of detector array
ZL = 20;          % Detector cell number along the vertical direction of detector array
ZLC= (1+ZL)*0.5;  % Detector center along the vertical direction of detector array
DecWidth = 3.5;   % Detector array width along the horizontal direction (cm)
DecHeigh = 0.2;   % Detector array height along the vertical direction (cm)
N_Turn   = 3;     % The number of turns for the whole helical scan 
N_2pi    = 360;   % The projections/views number for each turn of scan
h        = 1;     % Helical pitch related to detector height
%The following line 25-28 are used to define the reconstruction paramters
WtInd    = 3;     %1:Redundancy weighting; 2:2D weigthing; 3: 3D weighting 
k1       = 5;     % The order to define the 3D weighting function
delta    = 60;    % The range to define smoothness of 2D weigthing function 
HSCoef   = 0.6;   % This is used to define the half-scan range              

ObjR  = 1.1;      % Diameter of imaginh object
SSO   = 64;       % Define the size of the reconstructed image
XN    = 2*SSO;
YN    = 2*SSO;
ZN    = 2*SSO;
XC    = (XN+1)*0.5;
YC    = (YN+1)*0.5;
ZC    = (ZN+1)*0.5;
BetaS = -N_Turn*pi;
BetaE =  N_Turn*pi;
ViewN =  N_Turn*N_2pi+1;
dYL   =  DecWidth/YL;
dZL   =  DecHeigh/ZL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanGeom = struct( 'ScDet',  [SO DO YL ZL DecWidth DecHeigh YLC ZLC h],  ...
                   'Proj',   [BetaS BetaE ViewN N_2pi], ...
                   'Obj',    [ObjR XN YN ZN XC YC ZC], ...
                   'Rec',    [delta HSCoef k1]);            
% Generating projections or load the projections
disp('Generating the cone beam projections');
[ScPos Proj] = Conebeam_Flat_CreateProj_CB_Helical_Spectrum(ScanGeom);
%load SpectralProjections;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rebinning conebeam to parallel beam 
disp('Paralllel rebinning from the conebeam projections');
Proj = Parallel_Rebinning_CB_Flat(Proj,ScanGeom);
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
disp('BackProjection the filtered projection');
ctimage = zeros(XN,YN,ZN);
switch(WtInd)
    case 1 %1/2 redundancy weigthing
        Parallel_FDK_Helical_NOWeighting(ScanGeom,fpwd,ctimage);
        save RecResNoW ctimage;
    case 2 % 2D weighting
        Parallel_FDK_Helical_2DWeighting(ScanGeom,fpwd,ctimage);
        save RecRes2DW ctimage;
    case 3 %3D weighting
        Parallel_FDK_Helical_3DWeighting(ScanGeom,fpwd,ctimage);
        save RecRes3DW ctimage;
    otherwise %1/2 redundancy weigthing
        Parallel_FDK_Helical_NOWeighting(ScanGeom,fpwd,ctimage);
        save RecResNoW ctimage;
end;
imdisp(ctimage)

time =cputime-time


