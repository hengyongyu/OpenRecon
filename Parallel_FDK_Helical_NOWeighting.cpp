//////////////////////////////////
//  Imaging and Informatics Lab
//  Department of Electrical and Computer Engineering
//  University of Massachusetts Lowell
//  Parallel-cone backprojection
//  Nov. 14, 2015
//////////////////////////////////

#include <mex.h>
#include <math.h>
#include <complex>
#define DOUBLE_PRECISION
#define TYPE double
const static double pi = 3.14159265358979;
static const double *geom[4];
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    TYPE ObjR,XNC,YNC,ZNC,SO,DO,DecWidth,DecHeigh,h,dYL,dZL,YLC,ZLC,dx,dy,dz,DeltaFai,BetaS;
	int  YL,ZL,XN,YN,ZN,N_2pi,N_pi,PN,i,j,k;	
    TYPE *ctimage;
    const TYPE *fp;
    

    
	/* Check for proper number of arguments */
    if (nrhs != 3) {
        mexErrMsgTxt("Backward projection needs 3 inputs.");
    }
    if (nlhs != 0) {
        mexErrMsgTxt("Backward projection does not need any output.");
    }
    //Parallel_FDK_Helical_NOWeighting(ScanGeom,fpwd,ctimage);
    //     ScanGeom = struct( 'ScDet',  [SO DO YL ZL DecWidth DecHeigh YLC ZLC h],  ...
    //                        'Proj',   [BetaS BetaE ViewN N_2pi], ...
    //                        'Obj',    [ObjR XN YN ZN XC YC ZC], ...
    //                        'Rec',    [delta HSCoef k1]);
    geom[0] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 0)); 
    SO            =     geom[0][0];
    DO            =     geom[0][1];
    YL            = int(geom[0][2]+0.5);
    ZL            = int(geom[0][3]+0.5);
    DecWidth      =     geom[0][4];
    DecHeigh      =     geom[0][5];
    YLC           =     geom[0][6]-1;
    ZLC           =     geom[0][7]-1;
    h             =     geom[0][8]*DecHeigh;
          
    geom[1] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 1));
    BetaS         =     geom[1][0];
    PN            =     geom[1][2]; 
    N_2pi         = int(geom[1][3]);
    
    geom[2] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 2));
    ObjR          =     geom[2][0];
    XN            = int(geom[2][1]+0.5);
    YN            = int(geom[2][2]+0.5);
    ZN            = int(geom[2][3]+0.5);
    XNC           =     geom[2][4]-1;
    YNC           =     geom[2][5]-1; 
    ZNC           =     geom[2][6]-1;
     
	fp            =     mxGetPr(prhs[1]);
    ctimage       =     mxGetPr(prhs[2]);
   	
    N_pi = N_2pi/2;
    dx   = 2*ObjR/XN;
	dy   = 2*ObjR/YN;
    dz   = 2*ObjR/ZN;
    dYL  = DecWidth/YL;
    dZL  = DecHeigh/ZL;
   
    DeltaFai = 2*pi/N_2pi;
       
    if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
	{
        mexErrMsgTxt("Single precision is not supported in this version.\n");
		return;
	} 
	else 
	{
     //////begin of the  main code for backprojection
     TYPE x,y,z,Dey,Dez,touying,UU,U1,V1,Beta0,Yr,Zr,View,weight;
     int ProjInd,xi,yi,zi,U,V,s0,s1,s2,d1,d2;

	 for(zi = 0; zi<ZN; zi++)
	 {
		 ///compute the projection position for every grid on the image plane
         z = (zi-ZNC) * dz;
         Beta0 = 2 * pi * z / h;
         s0 = ceil((Beta0 -BetaS) / DeltaFai);     
         s1 = s0-N_pi;   //
         s2 = s0+N_pi-1; //
         if ((s1<PN)||(s2>0))
         {
           if (s1 < 0)  {s1 = 0;}
           if (s2 > PN-1) {s2 = PN-1;}
         for (ProjInd = s1; ProjInd <= s2; ProjInd++ )
         {
             View = BetaS + ProjInd* DeltaFai;
             for(yi=0;yi<YN;yi++)
             {
                 y = (yi-YNC)*dy;
                 for(xi=0;xi<XN;xi++)
                 {				
                    x  = (xi-XNC)*dx;
                    UU = -x*cos(View)-y*sin(View);
				    Yr = -x*sin(View)+y*cos(View);
                    Zr = (z-h*View/(2.0*pi))*((SO+DO)*SO)/(UU*sqrt(SO*SO-Yr*Yr)+SO*SO-Yr*Yr);
                    U1 = Yr/dYL+YLC;
                    U  = ceil(U1);
                    V1 = Zr/dZL+ZLC;
                    V  = ceil(V1);
                    Dey = U-U1;
                    Dez = V-V1; 
  
                    if ((U>0) && (U<YL) && (V>0) && (V<ZL))
                    {                              
                           touying = Dey*Dez*fp[((V-1)*YL+(U-1))*PN+ProjInd]
                                    +Dey*(1-Dez)*fp[((V)*YL+(U-1))*PN+ProjInd]
                                   +(1-Dey)*Dez*fp[((V-1)*YL+(U))*PN+ProjInd]
                                   +(1-Dey)*(1-Dez)*fp[((V)*YL+(U))*PN+ProjInd];
                           weight = 0.5;                  
                           ctimage[(zi*YN+yi)*XN+xi]=ctimage[(zi*YN+yi)*XN+xi]+weight*touying*DeltaFai; 
                    }
                                   
                 }// for xi			             
			 }//for yi
         }//ProjInd 
         }//if ((s1<PN)||(s2>0))
	 } //zi
    
     //////end of the main code  
    }/// if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
}

