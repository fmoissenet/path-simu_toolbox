% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : June 2020
% -------------------------------------------------------------------------
% Description  : To be defined
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : None
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = InitialiseGRFSignals(Trial,GRF)

if ~isempty(GRF)
    for i = 1:size(GRF,1)
                        
        % Initialise CoP, force and moment
        Trial.GRF(i).Signal.P.raw      = [];
        Trial.GRF(i).Signal.P.filt     = [];
        Trial.GRF(i).Signal.P.smooth   = [];
        Trial.GRF(i).Signal.P.units    = 'm';
        Trial.GRF(i).Signal.F.raw      = [];
        Trial.GRF(i).Signal.F.filt     = [];
        Trial.GRF(i).Signal.F.smooth   = [];
        Trial.GRF(i).Signal.F.units    = 'N';
        Trial.GRF(i).Signal.M.raw      = [];
        Trial.GRF(i).Signal.M.filt     = [];
        Trial.GRF(i).Signal.M.smooth   = [];
        Trial.GRF(i).Signal.M.units    = 'Nm';
        Trial.GRF(i).Processing.filt   = 'none';
        Trial.GRF(i).Processing.smooth = 'none';  
    end
end