function [Z R] = ParseChemicalFormula(Name)
%ParseChemicalFormula converts many different styles of names used for 
% elements, compounds and mixtures to uniform list of elements and their 
% weight ratios.
%
% [Z R] = ParseChemicalFormula(Name) function takes a string with a  
% chemical formula or name and returns atomic numbers (Z) and fractions by
% weight (R) of contributing elements.
%
% Input formats:
% - Element atomic number Z - in 1 to 100 range
% - Element symbols - 'Pb', 'Fe'
% - Element names   - 'Lead', 'Iron', 'Cesium' or 'Caesium'
% - Some common names and full compound names - 'Water', 'Polyethylene' 
%   (see function PhysProps for more details)
% - Compound formulas - 'H2SO4', 'C3H7NO2'- those are case sensitive 
% - Mixtures  of any of above with fractions by weight - like
%   'H(0.057444)C(0.774589)O(0.167968)' for Bakelite or  
%   'B(10)H(11)C(58)O(21)' for Borated Polyethylene (BPE-10)
%
% If name can not be parsed than Z and R returned are empty
% 
% See Also:
%   PhysProps, PhotonAttenuation, PhotonAttenuationQ
%
% Written by Jarek Tuszynski (SAIC), 2006
%
% Examples:
% [Z R] = ParseChemicalFormula('Pb')
% [Z R] = ParseChemicalFormula('Lead')
% [Z R] = ParseChemicalFormula('Water')
% [Z R] = ParseChemicalFormula('H2SO4')
% Bakelite = 'H(0.057444) C(0.774589) O(0.167968)';
% [Z R] = ParseChemicalFormula(Bakelite)
% GafChromic = 'H(0.0897) C(0.6058) N2O3(0.3045)';
% [Z R] = ParseChemicalFormula(GafChromic)
%
% % get properties of concrete
% X = PhysProps('Concrete');
% [Z R] = ParseChemicalFormula(X{3});
% MFP = PhotonAttenuation(X{3}, 0.662, 'mean free path');
% Concrete.Density      = X{2};
% Concrete.Z_A          = X{1};
% Concrete.ElementZ     = Z';
% Concrete.ElementRatio = R';
% Concrete.MeaFreePath  = MFP; % of gammas from Cesium-137 source
% Concrete


R=[]; Z=[];
Name = strtrim(Name);
if (isempty(Name)), return; end;

PP = PhysProps('Element Data');
ElName = PP(:,1);              % get Element names
AMass  = (1:100) ./ [PP{:,2}]; % get atomic masses
clear PP;
  
%% check if this is element symbol
if (length(Name)<=2) % check if this is element symbol
  k = find(strcmp(Name, ElName),1);
  if (length(k)>0), 
    Z = k; 
    R = 1;
    return;
  end;
end
  
%% check if this is element name or known compound
X = PhysProps(Name);
if (~isnan(X{1})), Name = X{3}; end

%% check if this is a compound
s1 = regexprep(Name,'(\D)([A-Z])', '$11$2'); % letter before upper case -> separate with '1'
s1 = regexprep(s1  ,'(\D)([A-Z])', '$11$2'); % for some reason have to do it twice
if (isempty(regexp(s1(length(s1)), '\d','once'))), s1 = [s1,'1']; end % string does not end with digit -> add '1'
s2 = regexp(s1,'([A-Z][a-z]*|\d+)', 'match');
El = s2(1:2:end);
z = zeros(1, length(El));
for i=1:length(El)
  j = find(strcmp(El{i}, ElName),1);
  if (~isempty(j)), z(i) = j; end
end
if (mod(length(s2),2)==0) && (all(z>0))
  Z = z;
  N = str2num(char(s2(2:2:end)))';
  R = AMass(Z).*N;
  R = R/sum(R(:)); % normalize ratios so they add-up to 1
  R = R(:); Z = Z(:);
  return;
end

%% check if this is a mixture of elements and/or compounds
s1 = regexprep(Name,')|(', ' '); % replace parenthesis with spaces
s2 = regexp([' ',s1],'\s([\.\+\-]|\w)+', 'tokens');
s3 = [s2{:}]; % convert from array of arrays of strints to array of strings
Mt = s3(1:2:end);
Rt = str2num(char(s3(2:2:end)));
if (isempty(Rt)), return; end 
for j = 1:length(Mt)
  [ZZ, RR] = ParseChemicalFormula(Mt{j});
  if (isempty(ZZ) || isempty(Rt(j))), return; end 
  Z = [Z; ZZ];
  R = [R; RR*Rt(j)];
end

%% make sure all Z's are unique
[Z idx] = sort(Z);
R = R(idx);
while (any(diff(Z)==0))
  i = find(diff(Z)==0, 1);
  idx = find(Z==Z(i));
  R(i) = sum(R(idx));
  idx(1) = [];
  Z(idx) = [];
  R(idx) = []; 
end

R = R/sum(R(:)); 
R = R(:); Z = Z(:);
