%MPGWRITE Write an MPEG file.
%	MPGWRITE(M, map, 'filename', options) Encodes M in MPEG 
%	format using the specified colormap and writes the result to the
%	specified file.  The options argument is an optional vector of
%	8 or fewer options where each value has the following meaning:
%	1. REPEAT:
%		An integer number of times to repeat the movie
%		(default is 1).
%	2. P-SEARCH ALGORITHM:
%		0 = logarithmic	(fastest, default value)
%		1 = subsample
%		2 = exhaustive	(better, but slow)
%	3. B-SEARCH ALGORITHM:
%		0 = simple	(fastest)
%		1 = cross2	(slightly slower, default value)
%		2 = exhaustive	(very slow)
%	4. REFERENCE FRAME:
%		0 = original	(faster, default)
%		1 = decoded	(slower, but results in better quality)
%	5. RANGE IN PIXELS:
%		An integer search radius.  Default is 10.
%	6. I-FRAME Q-SCALE:
%		An integer between 1 and 31.  Default is 8.
%	7. P-FRAME Q-SCALE:
%		An integer between 1 and 31.  Default is 10.
%	8. B-FRAME Q-SCALE:
%		An integer between 1 and 31.  Default is 25.
%

