//////////////////////////////////
//  Imaging and Informatics Lab
//  Department of Electrical and Computer Engineering
//  University of Massachusetts Lowell
//  Parallel-cone backprojection
//  Dec. 22, 2015
//////////////////////////////////

#include <mex.h>
#include <math.h>
#include <complex>
#include <vector>
#define DOUBLE_PRECISION
#define TYPE double
const static double pi = 3.14159265358979;
static const double *geom[4];
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    TYPE ObjR,SO,DO,YLC,ZLC,XNC,YNC,ZNC,DecWidth,DecHeigh,h,dYL,dZL,dx,dy,dz,DeltaFai,BetaS,HSCoef;
	int  YL,ZL,XN,YN,ZN,N_Circle,N_2pi,delta,N_pi,PN,i,j,k;	
    TYPE *ctimage,*w;
    const TYPE *fp;
	//std::vector<TYPE> f;
	/* Check for proper number of arguments */
    if (nrhs != 3) {
        mexErrMsgTxt("Backward projection need 3 inputs.");
    }
    if (nlhs != 0) {
        mexErrMsgTxt("Backward projection does not need any output.");
    }
    //Parallel_FDK_Helical_2DWeighting(ScanGeom,ctimage);
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
    N_2pi         = int(geom[1][3]+0.5);
    
    geom[2] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 2));
    ObjR          =     geom[2][0];
    XN            = int(geom[2][1]+0.5);
    YN            = int(geom[2][2]+0.5);
    ZN            = int(geom[2][3]+0.5);
    XNC           =     geom[2][4]-1;
    YNC           =     geom[2][5]-1; 
    ZNC           =     geom[2][6]-1;
    
    geom[3] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 3));
    delta         = int(geom[3][0]+0.5);   
    HSCoef        =     geom[3][1];// It is the value of Half_Scan/2*pi;
     
	fp            =     mxGetPr(prhs[1]);
    ctimage       =     mxGetPr(prhs[2]);
   
    N_pi = N_2pi/2;
    dx  = 2*ObjR/XN;
	dy  = 2*ObjR/YN;
    dz  = 2*ObjR/ZN;
    dYL = DecWidth/YL;
    dZL = DecHeigh/ZL;
   
    DeltaFai = 2*pi/N_2pi;   
            
    w = new TYPE[N_2pi];
    if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
	{
        mexErrMsgTxt("Single precision is not supported in this version.\n");
		return;
	} 
	else 
	{         
     //////begin of the  main code
     TYPE x,y,z,Dey,Dez,touying,UU,U1,V1,Beta0,Yr,Zr,View,weight;
     int ProjInd,xi,yi,zi,U,V,s0,s1,s2,d1,d2,L,Shift;
     
	 for(zi = 0; zi<ZN; zi++)
	 {
		 ///compute the projection position for every grid on the image plane
         z = (zi-ZNC) * dz;
         Beta0 = 2 * pi * z / h;
         s0 = ceil((Beta0 -BetaS) / DeltaFai-0.5);
         s1 = s0-ceil(N_pi*HSCoef);       
         s2 = s0+ceil(N_pi*HSCoef)-1;    
         
         if ((s1<PN)||(s2>0))
         {
           if (s1 < 0)  {s1 = 0;}
           if (s2 > PN-1) {s2 = PN-1;}
         //////////////////////////////////////////
         ////Producing the weighting function
         for (int k=0;k<N_2pi;k++)
           { w[k] = 0;}
         L = s2-s1+1;
         Shift = N_pi - (s0-s1);
         if (L<2*delta)
         {
             for (int k=0;k<L;k++)
               w[k+Shift]= pow(cos((pi/2)*(2*k-L+1)/L),2);           
         }
         else
         {
           for (int k=0;k<L;k++)
           {
             if (0 <= k && k<delta)
                 w[k+Shift]= pow(cos((pi/2)*(delta-k-0.5)/delta),2);
             else if(L-delta<=k && k < L)
                 w[k+Shift]= pow(cos((pi/2)*(k-(L-delta)+0.5)/delta),2);
             else
               w[k+Shift] = 1;
          }
         }//if(L<2*delta) 
               
         for (ProjInd = s1; ProjInd <= s2; ProjInd++ )
         {
             View = BetaS + ProjInd * DeltaFai;
             d1   = N_pi-(s0-ProjInd); //d1 = ProjInd;
             if (ProjInd < s0)
             {
                 d2 = d1+N_pi;
             }
             else //(ProjInd >= s0)
             {
                 d2 = d1-N_pi;               
             }
             weight = w[d1]/(w[d1]+w[d2]);
                                                   
             for(yi=0;yi<YN;yi++)
             {
                 y = (yi-YNC)*dy;
                 for(xi=0;xi<XN;xi++)
                 {				
                    x  = (xi-XNC)*dx;
                    UU = -x*cos(View)-y*sin(View);
				    Yr = -x*sin(View)+y*cos(View);
                    Zr = (z-h*View/(2.0*pi))*(SO*(SO+DO))/(UU*sqrt(SO*SO-Yr*Yr)+SO*SO-Yr*Yr);
                    U1 = Yr/dYL+YLC;
                    U  = ceil(U1);
                    V1 = Zr/dZL+ZLC;
                    V  = ceil(V1);
                    Dey = U-U1;
                    Dez = V-V1; 
                    //Linear interploate
                    if ((U>0)&&(U<YL)&&(V>0)&&(V<ZL))
                    {
                          touying = Dey*Dez*fp[((V-1)*YL+(U-1))*PN+ProjInd]
                                    +Dey*(1-Dez)*fp[((V)*YL+(U-1))*PN+ProjInd]
                                   +(1-Dey)*Dez*fp[((V-1)*YL+(U))*PN+ProjInd]
                                   +(1-Dey)*(1-Dez)*fp[((V)*YL+(U))*PN+ProjInd];                                      
                          ctimage[(zi*YN+yi)*XN+xi]=ctimage[(zi*YN+yi)*XN+xi]+weight*touying*DeltaFai;
                    }                    
                 }// for xi			             
			 }// for yi
         }//for ProjInd
         }//if ((s1<PN)||(s2>0))
	 } //zi
     //////end of the main code  
    }/// if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
    
    delete[] w;    
}

