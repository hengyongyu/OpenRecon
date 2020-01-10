%MPGREAD Read an MPEG encoded movie file.	
%	[M, map] = mpgread('filename', frames) reads the specifed
%	MPEG file and translates it into the movie M, and colormap map.
%	If a vector frames is specified, then only the frames specified
%	in this vector will be placed in M.  Otherwise, all frames will
%	be placed in M.
%
%       M = mpgread('filename', frames, 'indexed')
%       Reads an MPEG file into the MATLAB 5.3+ format movie which
%       is a structure array.  Each element has a cdata field 
%       containing a uint8 image matrix and a colormap field
%       containing the colormap.  The frames parameter can be [] to
%       indicate that all frames should be read.
%
%       M = mpgread('filename', frames, 'truecolor')
%       Reads an MPEG file into the MATLAB 5.3+ format movie.  Each
%       frame in the movie has a truecolor MxNx3 cdata field and
%       an empty colormap field.
%
%	[R, G, B] = mpgread('filename', frames) will perform the same 
%	operation as above, except that the decoded MPEG frames will
%	be placed into the matrices R, G, B, where R contains the red
%	component for each frame, G, the green component, and B, the
%	blue component.
%
