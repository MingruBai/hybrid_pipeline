#include "mex.h"
#include <string.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    double* vertex = mxGetPr(prhs[0]); //arg0: num_rows x num_cols x 3 double matrix
    unsigned int num_cols = mxGetN(prhs[0])/3;
    unsigned int num_rows = mxGetM(prhs[0]);
    

    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(num_rows, num_cols,mxREAL);
    
    /* get a pointer to the real data in the output matrix */
    double* groups = mxGetPr(plhs[0]);
    
    for (int i = 0; i < num_rows * num_cols; ++i) *(groups + i) = -1;
    
    double zThreshold = 0.1;

    int curGroups = 1;
    
    unsigned int layerSize = num_cols* num_rows;
    
    for (unsigned int c = 0; c < num_cols-1; ++c) {
        for (unsigned int r = 0; r < num_rows-1; ++r) {
                        
            double* z00 = vertex+ num_rows*c + r + layerSize;
            double* z01 = vertex+ num_rows*c + r + layerSize + num_rows;
            double* z10 = vertex+ num_rows*c + r + layerSize + 1;
            double* z11 = vertex+ num_rows*c + r + layerSize + num_rows + 1;
            
            if (*z00 == 0.0) continue;
             //mexPrintf("hey");
            if (*(groups + num_rows*c + r) == -1){
                *(groups + num_rows*c + r) = curGroups;
                curGroups = curGroups + 1;
            }
        
            if (*z01 != 0.0 && fabs(*z01-*z00)<zThreshold){
                *(groups + num_rows*c + num_rows + r) = *(groups + num_rows*c + r);
            }
        
            if (*z10 != 0.0 && fabs(*z10-*z00)<zThreshold){
                *(groups + num_rows*c + r + 1) = *(groups + num_rows*c + r);
            }
        
            if (*z11 != 0.0 && fabs(*z11-*z00)<zThreshold){
                *(groups + num_rows*c + num_rows + r + 1) = *(groups + num_rows*c + r);
            }

        }
    }
}