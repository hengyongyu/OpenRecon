function PProj = Parallel_Rebinning_CB_Flat(Proj,ScanGeom)
% Rebin the spiral cone-beam projections into cone-parallel geometry
%ScanGeom = struct( 'ScDet',  [SO DO YL ZL DecWidth DecHeigh YLC ZLC h],  ...
%                   'Proj',   [BetaS BetaE ViewN N_2pi], ...
%                   'Obj',    [ObjR XN YN ZN XC YC ZC]...
%                   'Rec',    [delta HSCoef k1]); 

SO = ScanGeom.ScDet(1);
DO = ScanGeom.ScDet(2);
YL = ScanGeom.ScDet(3);
ZL = ScanGeom.ScDet(4);
dYL= ScanGeom.ScDet(5)/YL;
YLC= ScanGeom.ScDet(7);

ViewN   = ScanGeom.Proj(3);
DeltaFai= (ScanGeom.Proj(2)-ScanGeom.Proj(1))/(ViewN-1);
DeltaTheta = DeltaFai;
DeltaT     = dYL;

PProj    = zeros(ViewN,YL,ZL);
 for i=1:ViewN
    Theta=(i-1)*DeltaTheta;                   % the view for the parallel projection 
        for j=1:YL
            t      = (j-YLC)*DeltaT;     % the distance from origin to ray for parallel beam 
            Beta   = asin(t/(SO));            % the fan_angle for cone_beam projection
            Fai    = Theta+Beta;              % the view for cone_beam projecton
            a      = (SO+DO)*t/sqrt(SO^2-t^2);% the position of this ray on the flat detector
            FaiIndex        =  (Fai/DeltaFai)+1;% Matlab index begins with 1 instead of 0  
            UIndex          =  (a/dYL)+YLC; 
            FI              =  ceil(FaiIndex);  
            UI              =  ceil(UIndex); 
            coeXB           =  FI-FaiIndex;
            coeXU           =  1-coeXB;
            coeYB           =  UI-UIndex;
            coeYU           =  1-coeYB;
            if (FI<=1)
                IndexXU = 1;
                IndexXB = 1;
            elseif(FI> ViewN)
                IndexXU = ViewN;
                IndexXB = ViewN;
            else
                IndexXU = FI;
                IndexXB = FI-1;
            end;
            if (UI<=1)
                IndexYU = 1;
                IndexYB = 1;
            elseif(UI>YL)
                IndexYU = YL;
                IndexYB = YL;
            else
                IndexYU=UI;
                IndexYB=UI-1;
            end;
            PProj(i,j,:)=coeXB*coeYB*Proj(IndexXB,IndexYB,:)+coeXU*coeYB*Proj(IndexXU,IndexYB,:)+coeXB*coeYU*Proj(IndexXB,IndexYU,:)+coeXU*coeYU*Proj(IndexXU,IndexYU,:);
        end;% end for j
 end;% end for i=:ViewN
            
