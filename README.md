# OpenRecon
This open-source software package is a response to the NIH/NIBIB Low-dose CT U01 community.  The purpose is to share a standardized platform equipped with key analytic reconstruction methods for helical/spiral multi-slice/cone-beam CT assuming either a flat-panel detector or a curved detector array. 

For the flat-panel detector, the main file is: Helical_Rec_Flat.m

For the curved detector, the main file is: Helical_Rec_Curve.m

If your Matlab cannot identify the MEX file, you can re-compile the corresponding CPP files use the MEX command.

The functions to generate the linear attenuation coefficients are from the following webpage: http://www.mathworks.com/matlabcentral/fileexchange/12092-photonattenuation-2, and the copyright belongs to Jaroslaw Tuszynski.  The image display graphic toolbox was developed by our late collaborator Dr. Shiying Zhao in 2004 for our collaboration. The public use of Dr. Zhao’s codes is a good way in memory of his dedication and contribution to our field.
