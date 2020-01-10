function [ScPos Proj] = Conebeam_Curve_CreateProj_CB_Helical_Spectrum(ScanGeom,Energy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is to generate spetral projections to simualte a helcial 
% CT scan with a curved detector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Energy1 = 15.5:1:56.5;
if (nargin<1)
    disp('Error!!! It requires at least 1 parameter to generate cone-beam projections!')
    ScPos =0;
    Proj  =0;
    return;
elseif(nargin<2)
 Energy = 60:62;   %Specify the Energy range for spectral projections
end;
%ScanGeom = struct( 'ScDet',  [SO DO YL ZL DecAngle DecHeigh YLC ZLC h],  ...
%                   'Proj',     [BetaS BetaE ViewN N_2pi], ...
%                   'Obj',[ObjR XN YN ZN XC YC ZC]);
ObjR     = ScanGeom.Obj(1);
SO = ScanGeom.ScDet(1)/ObjR;    %Normalzied distance from source to object
DO = ScanGeom.ScDet(2)/ObjR;    %Normalzied distance from detector to object
YL = ScanGeom.ScDet(3);              
ZL = ScanGeom.ScDet(4);              
DecAngle = ScanGeom.ScDet(5);  
DecHeigh = ScanGeom.ScDet(6)/ObjR;  % Normalized deecgtor array height
YLC      = ScanGeom.ScDet(7);
ZLC      = ScanGeom.ScDet(8);
N_2pi    = ScanGeom.Proj(4);      
h        = DecHeigh*ScanGeom.ScDet(9);
BetaS    = ScanGeom.Proj(1);
BetaE    = ScanGeom.Proj(2);
ViewN    = ScanGeom.Proj(3);
ScPos    = CreateSourcePosAry_CB_Helical(BetaS,BetaE,SO,h,ViewN);
load('PhotonIntensity.mat');% B: Spectrum of x-ray source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tomography_Channel = zeros(ViewN,YL,ZL);
Tomography_Blank   = zeros(ViewN,YL,ZL);
Proj               = zeros(ViewN,YL,ZL);
EnNum = max(size(Energy));
for En = 1: EnNum
    Index = ceil(Energy(En));
    EnValue = Energy(En)/1000;
    EnAttenuationCoef = zeros(1,14);
    Coef1 = PhotonAttenuation('SOFT TISSUE',EnValue,7);
    EnAttenuationCoef(1) = Coef1;
    Coef2 = PhotonAttenuation('Water',EnValue,7)-Coef1;
    EnAttenuationCoef(2) = Coef2;
    Coef3 = PhotonAttenuation('Blood',EnValue,7)-Coef1;
    EnAttenuationCoef(3) = Coef3;
    Alfa  = 0.002;
    Coef4 = Alfa*(PhotonAttenuation('Gold',EnValue,7)-Coef1)+(1-Alfa)*Coef3;
    EnAttenuationCoef(4) = Coef4;
    Alfa  = 0.003;
    Coef5 = Alfa*(PhotonAttenuation('Iodine',EnValue,7)-Coef1)+(1-Alfa)*Coef3;
    EnAttenuationCoef(5) = Coef5;
    Alfa  = 0.01;
    Coef6 = Alfa*(PhotonAttenuation('Barium',EnValue,7)-Coef1)+(1-Alfa)*Coef2;
    EnAttenuationCoef(6) = Coef6;
    Alfa  = 0.003;
    Coef7 = Alfa*(PhotonAttenuation('Gadolinium',EnValue,7)-Coef1)+(1-Alfa)*Coef3;
    EnAttenuationCoef(7) = Coef7;
    Alfa  = 0.1;
    Coef8 = Alfa*(PhotonAttenuation('Ca',EnValue,7)-Coef1)+(1-Alfa)*Coef2;
    EnAttenuationCoef(8)  = Coef8;
    EnAttenuationCoef(9)  = Coef8;
    EnAttenuationCoef(10) = Coef8;
    EnAttenuationCoef(11) = Coef8;
    EnAttenuationCoef(12) = Coef8;
    EnAttenuationCoef(13) = Coef8;
    EnAttenuationCoef(14) = Coef8;
    
    %computer the cone beam projections
    for ProjIndex=1:ViewN
         Sx = ScPos(ProjIndex,1);
         Sy = ScPos(ProjIndex,2);
         Sz = ScPos(ProjIndex,3);
         costheta=ScPos(ProjIndex,4);
         sintheta=ScPos(ProjIndex,5);
         SliceProjGeom = struct( 'Sc',  [Sx Sy Sz SO DO costheta sintheta],  ...
                                 'Det', [YL ZL DecAngle DecHeigh YLC ZLC]);
         Slice = CreateProjSlice_Helical_Curve(SliceProjGeom,EnAttenuationCoef);
         Proj(ProjIndex,:,:)= Slice;
    end;
         Proj = Proj*ObjR;
         Tomography_Channel = Tomography_Channel+B(Index)*exp(-Proj);
         Tomography_Blank   = Tomography_Blank+B(Index);

  end %%En
Proj = log(Tomography_Blank./Tomography_Channel);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save  SpectralProjections ScPos Proj;
