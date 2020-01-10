function X = PhotonAttenuation(Material, Energy, Options, Thickness)
% PhotonAttenuation provides photon attenuation in different materials.
%
% X = PhotonAttenuation(Material, Energy, Options, Thickness)
% Function providing the attenuation and energy absorption of x-ray and
% gamma-ray photons in various materials including mixtures and compounds,
% based on NIST report 5632, by J. Hubbell and S.M. Seltzer.
%
% Input :
% 1) Material - string, number or array of strings, numbers or cells
%     describing material type.
%     - Element atomic number Z - in 1 to 100 range
%     - Element symbols - 'Pb', 'Fe'
%     - Element names   - 'Lead', 'Iron', 'Cesium' or 'Caesium'
%     - Some common names and full compound names - 'Water', 'Polyethylene'
%       (see function PhysProps for more details)
%     - Compound formulas - 'H2SO4', 'C3H7NO2'- those are case sensitive
%     - Mixtures of any of above with fractions by weight - like
%       'H(0.057444)C(0.774589)O(0.167968)' for Bakelite or
%       'B(10)H(11)C(58)O(21)' for Borated Polyethylene (BPE-10)
%     Note: For 'Options' other than 'mac' or 'meac', 'Material' has to be
%     recognized by 'PhysProps' function since densities are needed for
%     calculation.
% 2) Energy - Energy of the photons. Can be single energy or vector of
%       energies. Several formats are allowed:
%     - Energy in MeV, should be in [0.001, 20] MeV range.
%     - Wavelengths in nano-meters. Encoded as negative numbers. The valid
%     range is 6.1982e-5 to 1.2396 nm;
%     - Continuous Spectrum - Encoded in 2 columns: column one contains
%       energy in MeV and column two contains relative number of photons at that
%       energy. Spectrum is assumed to be continuous and output is
%       calculated through integration using 'trapz' function.
% 3) Options - specifies what to return. String or number:
%     1 - 'mac' - function returns Mass Attenuation Coefficients in cm^2/g
%     2 - 'meac' - function returns Mass Energy-Absorption Coefficients
%           in cm^2/g. See link below for more info:
%           http://physics.nist.gov/PhysRefData/XrayMassCoef/chap3.html
%     3 - 'cross section' or 'x' - function returns cross section in barns per
%          atom (convert to cm^2 per atom by multiplying by 10^-24).
%          Available only for elements.
%     4 - 'mean free path' or 'mfp' - function returns mean free path (in cm) of
%           photon in the given material.
%     5 - 'transmission' or 't' - fraction of protons absorbed by given thickness
%          of material
%     6 - 'ln_T' - log of transmission
%     7 - 'lac' - Linear Attenuation Coefficients in 1/cm same as 1/(Cross
%          Section) or mac*density.
%     8 - 'half value layer' or 'hvl' - function returns half-value layer (in cm) of
%           photon in the given material . Available only for chemicals
%           recognized by 'CompoundProps' function (since density is needed).
%     9 - 'tenth value layer' or 'tvl' - analogous to 'hvl' .
% 4) Thickness - Thickness of material in cm. Either scalar or vector of
%      the same length as number of materials. Negative numbers indicate
%      mass thickness measured in g/cm^2 (density*thickness). Needed only
%      if energy spectrum is used or in case of Options set to
%      'Transmission'.
% Output :
%   X  - output depends on 'Options' parameter. Columns always correspond
%        to the materials and rows correspond to energy. In case of spectrum
%        input only single row is returned.
%
% History:
%   Written by Jarek Tuszynski (SAIC), 2006
%   Updated by Jarek Tuszynski (Leidos), 2014, jaroslaw.w.tuszynski@leidos.com
%   Inspired by John Schweppe Mathematica code available at
%     http://library.wolfram.com/infocenter/MathSource/4267/
%   Tables are based on NIST's XAAMDI and XCOM databases. See
%     PhotonAttenuationQ function for more details.
%
% Examples:
% %% Plot Cross sections of elements for different energy photons
% figure
% Z = 1:100; % elements with Z in 1-100 range
% E = logspace(log10(0.001), log10(20), 500);  % define energy grid
% X = PhotonAttenuation(Z, E, 'cross section');
% imagesc(log10(X)); colorbar;
% title('Cross sections of elements for different energy photons');
% xlabel('Atomic Number of Elements');
% ylabel('Photon Energy in MeV');
% set(gca,'YTick',linspace(1, length(E), 10));
% set(gca,'YTickLabel',1e-3*round(1e3*logspace(log10(0.001), log10(20), 10)))
%
% %% Plot Photon Attenuation Coefficients, using different input styles
% figure
% E = logspace(log10(0.001), log10(20), 500);  % define energy grid
% Z = {'Concrete', 'Air', 'B(10)H(11)C(58)O(21)', 100, 'Ag'};
% mac  = PhotonAttenuation(Z, E, 'mac');
% loglog(E, mac);
% legend({'Concrete', 'Air', 'BPE-10', 'Fermium', 'Silver'});
% ylabel('Attenuation in cm^2/g');
% xlabel('Photon Energy in MeV');
% title('Photon Attenuation Coefficients for different materials');
mu=0;
%% Process 'Energy' Input Parameter
s = size(Energy);
nEnergy = prod(s);
Spectrum = [];
if (min(s)==2)
  if (s(1)==2), Energy=Energy'; end
  Spectrum = Energy(:,2);
  Energy   = Energy(:,1);
  Spectrum = Spectrum / trapz(Energy, Spectrum); % normalize spectrum
  nEnergy  = 1; % this is a spectrum output will be an array instead of matrix
end
Energy  = Energy(:);
if (any(Energy<0))
  idx = find(Energy<0);
  PlanckConstant = 4.1350e-021; % Planks constant in MeV*sec
  SpeedOfLight   = 299792458E9; % in nano meters per second
  WaveLength     = -Energy(idx);
  Energy(idx)    = (PlanckConstant*SpeedOfLight) ./ WaveLength;
end
if (any(Energy<0.0009) || any(Energy>21))
  warning('PhotonAttenuation:wrongEnergy',...
    'Warning in PhotonAttenuation function: energy is outside of the recomended range from 0.001 MeV to 20 MeV');
end

%% Process 'Material' Input Parameter
if (ischar   (Material)), Material = {Material}; end
if (isnumeric(Material)), Material = num2cell(Material); end
nMaterial = length(Material);

%% Process 'Options' Input Parameter
OptNames = {'mac','meac', 'cross section', 'mean free path', 'transmission', 'ln_t', 'lac', 'half value layer', 'tenth value layer', ...
  'mac','meac', 'x', 'mfp', 't', 'log_t', 'lac', 'hvl', 'tvl'};
nOpt = length(OptNames)/2;
if (nargin<3), Options = 1; end
if (ischar(Options))
  Options = find(strcmpi( Options, OptNames),1);
  if (Options>nOpt), Options=Options-nOpt; end
else
  if (Options>nOpt), Options=[]; end
end
if (isempty(Options))
  error(['Error in PhotonAttenuation function: Options parameter was not recognized: ', Options]);
end
param = (Options==2)+1; % param=2 if Option==2 and  param=1 otherwise

%% Process 'Thickness' Input Parameter
if (nargin<4), Thickness=1; end
if (length(Thickness)==1 && nMaterial>1)
  Thickness = repmat(Thickness(1), 1, nMaterial);
end
if (length(Thickness)>1 && nMaterial==1)
  nMaterial = length(Thickness);
  Material = repmat(Material(1), 1, nMaterial);
end
if (length(Thickness)~=nMaterial)
  error('Error in PhotonAttenuation function: missmatch between lengths or Material and Thickness arrays');
end

%% Initialize output variables
if (isempty(Spectrum)), X = zeros(nEnergy,nMaterial);
else                    X = zeros(1      ,nMaterial); end
u = 1.6605402E-24 ; % atomic mass unit (1/12 of the mass of C-12)
barns = 1E24;       % barns

%% Main Loop: preform calculation for each material
old_material = [];
for iMat = 1:nMaterial
  %% Parse material
  % VARIABLES:
  % Z      - array of element numbers contained in the material
  % Ratios - array of element ratios in the material
  % MatStr - string representation of the material
  material = Material{iMat};
  if (isempty(material))
    error('Error in PhotonAttenuation function: compound formula was empty');
  end
  if (~isempty(old_material) && length(old_material)==length(material) && all(old_material==material))
    if (Option<3 && isempty(Spectrum)) % a shortcut for common configuration
      X(:,iMat) = mu;
      continue;
    end
  end
  
  if (ischar(material)) % check if this is element name or known compound
    [Z, Ratios] = ParseChemicalFormula(material);
    if (isempty(Z))
      error(['Error in PhotonAttenuation function: compound formula was not recognized: ', material]);
    end
    MatStr = material;
  elseif (isnumeric(material))
    Z      = material;
    Ratios = 1;
    MatStr = num2str(material);
  else
    error('Error in PhotonAttenuation function: compound formula was not recognized.');
  end
  if (length(Z)>1 && Options==3)
    error('Error in PhotonAttenuation function: Cross section "Option" is only supported for elements.');
  end
  
  %% Look up the data, average contributions of different elements and save
  mu = PhotonAttenuationQ(Z, Energy, param);
  old_material = material;          % old_material will store the name of material for which we calculated mu
  Ratios = Ratios(:) / sum(Ratios); % normalize ratios so they add up to one
  % if mu is 2D (spectrum and compound) it will become 1D
  % if mu is 1D (because of compound) it will become scalar
  % if mu is 1D (because of spectrum) it will not change
  % if mu is a scalar (monoenergetic & element) it will not change
  mu  = mu * Ratios;
  
  %% Lookup density and atomic molar mass if needed
  if (Options>=3 || ~isempty(Spectrum))
    PP      = PhysProps(material);
    Density = PP{1,2};
    A       = Z/PP{1,1}; % atomic molar mass in g/mol
  end
  
  %% Calculate Transmission if needed
  if (Options==5 || Options==6 || ~isempty(Spectrum)) % a shortcut for common configuration
    if(Thickness(iMat)>0),
      MassThick =  Thickness(iMat)*Density; % mass thickness measured in g/cm^2
    else
      MassThick = -Thickness(iMat);
    end % user provided linear thickness
    if ~isnan(MassThick)
      MassThick = max(MassThick, 1e-6);
    end
    T = exp(-mu*MassThick); % always convert to transmission
  end
  
  %% if Energy has a spectrum than integrate
  if (~isempty(Spectrum))
    T  = trapz(Energy, T.*Spectrum); % integrate over energy (T become a scalar)
    mac = -log(T)/MassThick;
  else
    mac = mu;
  end
  
  %% Cast output in a chosen format
  switch (Options)
    case {1,2} % mac & meac
      x = mac;
    case 3 % 'cross section'
      x = mac * (barns*u*A);
    case 4 % 'mean free path'
      x = 1./(mac*Density);
    case 5 % 'transmission'
      x = T;
    case 6 % 'log T'
      x = -log(T);
    case 7 % 'linear attenuation coefficiant'
      x = mac*Density;
    case 8 % 'half-value layer'
      x = -log(0.5)./(mac*Density);
    case 9 % 'tenth-value layer'
      x = -log(0.1)./(mac*Density);
  end
  X(:,iMat) = x;
  if (any(isnan(x)))
    error(['Error in PhotonAttenuation function: Physical properties of "',...
      MatStr,'" not found in PhysProps function.']);
  end
  
end
