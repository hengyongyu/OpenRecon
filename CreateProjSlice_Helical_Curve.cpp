/*
**  Imaging and Informatic Lab 
**  Department of Electrical and Computer Engineering
**  University of Massachusetts Lowell
**  Version of 2015.12.23
*/

#include <mex.h>
#include <math.h>
#define DOUBLE_PRECISION
#define TYPE double
#define PI 3.14159265358979
#define ZAV 0.2//100 
static const double *geom[2];
static const double PhPar[14][7] = {
{0.9000,  0.9000,  100,    0,        0,       0,     0},
{0.1500,  0.1500,  ZAV,    0,        0,       0,     0},
{0.1500,  0.1500,  ZAV,   0,        0.5,     0,     0},
{0.1500,  0.1500,  ZAV,    0.4330,   0.2500,  0,     0},
{0.1500,  0.1500,  ZAV,    0.4300,  -0.2500,  0,     0},
{0.1500,  0.1500,  ZAV,    0,       -0.5,     0,     0},
{0.1500,  0.1500,  ZAV,   -0.4300,  -0.2500,  0,     0},
{0.1500,  0.1500,  ZAV,   -0.4300,   0.2500,  0,     0},
{0.0800,  0.0800,  ZAV,    0,        0.2500,  0,     0},
{0.0400,  0.0400,  ZAV,    0.2165,   0.1250,  0,     0},
{0.0200,  0.0200,  ZAV,    0.2165,  -0.1250,  0,     0},
{0.0100,  0.0100,  ZAV,    0,       -0.25,    0,     0},
{0.0050,  0.0050,  ZAV,   -0.2165,  -0.1250,  0,     0},
{0.0025,  0.0025,  ZAV,   -0.2165,   0.1250,  0,     0}};

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    TYPE Sx, Sy, Sz, SO,DO,costheta,sintheta,DecAngle,DecHeigh,dYL,dZL,YCenter,ZCenter;//,ObjR;
	int  YL, ZL;
	TYPE *ProjSlice;
    const TYPE *Coef;

    /* Check for proper number of arguments */
    if (nrhs != 2) {
        mexErrMsgTxt("cone beam projection need two inputs.");
    }
    if (nlhs != 1) {
        mexErrMsgTxt("cone beam projection need one output.");
    }
    /* The input parameters*/
    //Slice = CreateProjSlice_Helical_Flat(SliceProjGeom,EnAttenuationCoef);
    //SliceProjGeom = struct( 'Sc',  [Sx Sy Sz SO DO costheta sintheta],  ...
    //                         'Det', [YL ZL DecAngle DecHeigh YC ZC]);
     
    geom[0] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 0));
	Sx  = geom[0][0];
    Sy  = geom[0][1];
    Sz  = geom[0][2];
	SO  = geom[0][3];
    DO  = geom[0][4];
    costheta = geom[0][5];
    sintheta = geom[0][6];
    
    geom[1] = mxGetPr(mxGetFieldByNumber(prhs[0], 0, 1));
	YL    = int(geom[1][0]+0.5);
	ZL    = int(geom[1][1]+0.5);
    DecAngle =  geom[1][2];
    DecHeigh =  geom[1][3];
    YCenter  =  geom[1][4]-1;
    ZCenter  =  geom[1][5]-1;

    //mexPrintf("Sx=%f,Sy=%f,Sz=%f,SO=%d,DO=%f,costheta=%f,sintheata=%f,YL=%d,ZL=%d,DecWidth=%f,DecHeigh=%f,YC=%f,ZC=%f\n",Sx, Sy,Sz,SO, DO, costheta, sintheta, YL, ZL, DecWidth, DecHeigh, YCenter, ZCenter);
    
    Coef     = mxGetPr(prhs[1]);
         
    dYL = DecAngle/YL;
    dZL = DecHeigh/ZL;
  
    if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
	{
        mexErrMsgTxt("Single precision is not supported in this version.\n");
		return;
	} 
	else 
	{
        plhs[0] = mxCreateNumericMatrix(YL, ZL, mxDOUBLE_CLASS, mxREAL);
        /* Assign pointers to the various parameters */
        ProjSlice = mxGetPr(plhs[0]);
		//The following is the actural projection part
        //computer some necessary constants
		TYPE Dx, Dy;
        Dx=-DO*costheta;
        Dy=-DO*sintheta;
		        int Yindex,Zindex,ElpIndex;
		TYPE PS[3],SPS[3],XS[3],SXS[3],DX[3],tpdata,tempvar,AA,BB,CC,t1,t2,InterZ1,InterZ2,d,delta;
		TYPE pcos[14],psin[14],AxisSquare[14][3];
        //TYPE PhPar[10][8];
		
		XS[0] = Sx;
		XS[1] = Sy;
		XS[2] = Sz;
                
		for (ElpIndex=0;ElpIndex<14;ElpIndex++)
		{
			tpdata = PhPar[ElpIndex][6]*PI/180;
			pcos[ElpIndex] = cos(tpdata);
			psin[ElpIndex] = sin(tpdata);
			AxisSquare[ElpIndex][0] = pow(PhPar[ElpIndex][0],2);
			AxisSquare[ElpIndex][1] = pow(PhPar[ElpIndex][1],2);
			AxisSquare[ElpIndex][2] = pow(PhPar[ElpIndex][2],2);
		}

		for (Yindex=0;Yindex<YL;Yindex++)
		{
			PS[1] =  tan((Yindex-YCenter)*dYL)*(SO+DO);
            PS[0] =   -PS[1]*sintheta+Dx;
			PS[1] =    PS[1]*costheta+Dy;

			for (Zindex=0;Zindex<ZL;Zindex++)
			{
                PS[2] = (Zindex-ZCenter)*dZL+XS[2];
                tpdata = 0;

				for (ElpIndex=0;ElpIndex<14;ElpIndex++)
				{
					SXS[0] = XS[0]-PhPar[ElpIndex][3];
					SPS[0] = PS[0]-PhPar[ElpIndex][3];
					SXS[1] = XS[1]-PhPar[ElpIndex][4];
					SPS[1] = PS[1]-PhPar[ElpIndex][4];
					SXS[2] = XS[2]-PhPar[ElpIndex][5];
					SPS[2] = PS[2]-PhPar[ElpIndex][5];
                    tempvar= SXS[0];
					SXS[0] = tempvar*pcos[ElpIndex]+SXS[1]*psin[ElpIndex];
					SXS[1] =-tempvar*psin[ElpIndex]+SXS[1]*pcos[ElpIndex];
					tempvar= SPS[0];
					SPS[0] = tempvar*pcos[ElpIndex]+SPS[1]*psin[ElpIndex];
					SPS[1] =-tempvar*psin[ElpIndex]+SPS[1]*pcos[ElpIndex];

					DX[0]  = -SXS[0]+SPS[0];
					DX[1]  = -SXS[1]+SPS[1];
					DX[2]  = -SXS[2]+SPS[2];
					tempvar= sqrt(pow(DX[0],2)+pow(DX[1],2)+pow(DX[2],2));
					
                    AA = pow(DX[0],2)/AxisSquare[ElpIndex][0]+
						 pow(DX[1],2)/AxisSquare[ElpIndex][1]+ 
						 pow(DX[2],2)/AxisSquare[ElpIndex][2];
					BB = DX[0]*SPS[0]/AxisSquare[ElpIndex][0]+
						 DX[1]*SPS[1]/AxisSquare[ElpIndex][1]+ 
						 DX[2]*SPS[2]/AxisSquare[ElpIndex][2];
                    CC = pow(SPS[0],2)/AxisSquare[ElpIndex][0]+ 
						 pow(SPS[1],2)/AxisSquare[ElpIndex][1]+ 
						 pow(SPS[2],2)/AxisSquare[ElpIndex][2]-1;
                  
					delta=pow(BB,2)-AA*CC;
					if(delta>=0)
					{

                        tpdata = tpdata+2*sqrt(delta)*tempvar*Coef[ElpIndex]/AA;
                        
					}
				}//for (ElpIndex=0;ElpIndex<10;ElpIndex++)
				ProjSlice[Zindex*YL+Yindex]=tpdata;
			}//for (Zindex=0;Zindex<ZL;Zindex++)
		}//for (Yindex=0;Yindex<YL;Yindex++)        
		//////////////////////////////////////
    }//    if (mxGetClassID(prhs[1]) == mxSINGLE_CLASS) 
}
