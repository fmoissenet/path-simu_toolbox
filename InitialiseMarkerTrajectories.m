% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : To be defined
% Reference    : To be defined
% Date         : September 2021
% -------------------------------------------------------------------------
% Description  : This routine initialise the markerset used in this project.
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

function Trial = InitialiseMarkerTrajectories(Trial,Marker)

% Set markerset
markerSet = {'RASI','LASI','RPSI','LPSI',...
             'RTHI','RKNE','RKNI','CRT1','CRT2','CRT3','CRT4',...
             'RTTU','RTIB','RANK','RMED',...
             'RHEE','RMIF','RTOE','RMET',...
             'LTHI','LKNE','LKNI','CLT1','CLT2','CLT3','CLT4',...
             'LTTU','LTIB','LANK','LMED',...
             'LHEE','LMIF','LTOE','LMET'};      
         
% Set landmark type
% 'landmark' is a marker related to a rigid body
% 'semi-landmark' is a marker related to a curve
% 'hybrid-landmark' is a marker related to a curve and a rigid body
% 'technical' is a marker not used for anatomical description
landmarkList = {'landmark','landmark','landmark','landmark',...
                'technical','landmark','landmark','technical','technical','technical','technical',...
                'landmark','technical','landmark','landmark',...
                'landmark','landmark','landmark','landmark',...
                'technical','landmark','landmark','technical','technical','technical','technical',...
                'landmark','technical','landmark','landmark',...
                'landmark','landmark','landmark','landmark'};              
         
% Set related rigid segments
% Only used with landmark and hybrid-landmarks markers ('none' instead')
segmentList = {'Pelvis','Pelvis','Pelvis','Pelvis',...
               'RThigh','RThigh','RThigh','RThigh','RThigh','RThigh','RThigh',...
               'RShank','RShank','RShank','RShank',...
               'RFoot','RFoot','RFoot','RFoot',...
               'LThigh','LThigh','LThigh','LThigh','LThigh','LThigh','LThigh',...
               'LShank','LShank','LShank','LShank',...
               'LFoot','LFoot','LFoot','LFoot'};     
           
% Set related curves
% Only used with semi-landmark and hybrid-landmarks markers ('none' instead')
% Syntax: Curve named followed by order number on the curve
curveList = {'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan,...
             'none',nan,'none',nan,'none',nan,'none',nan}; 

% Initialise markers
Trial.Marker = [];
for i = 1:length(markerSet)
    Trial.Marker(i).label                 = markerSet{i};
    Trial.Marker(i).type                  = landmarkList{i};
    Trial.Marker(i).Body.Segment.label    = segmentList{i};
    Trial.Marker(i).Body.Curve.label      = curveList{i*2-1};
    Trial.Marker(i).Body.Curve.index      = curveList{i*2};
    if isfield(Marker,markerSet{i})
        Trial.Marker(i).Trajectory.raw    = permute(Marker.(markerSet{i}),[2,3,1])*1e-3; % Convert mm to m
        Trial.Marker(i).Trajectory.fill   = [];
        Trial.Marker(i).Trajectory.smooth = [];
        Trial.Marker(i).Trajectory.units  = 'm';
        Trial.Marker(i).Trajectory.Gap    = [];
    else
        Trial.Marker(i).Trajectory.raw    = [];
        Trial.Marker(i).Trajectory.fill   = [];
        Trial.Marker(i).Trajectory.smooth = [];
        Trial.Marker(i).Trajectory.units  = 'm';
        Trial.Marker(i).Trajectory.Gap    = [];
    end
    Trial.Marker(i).Processing.smooth     = 'none';
    Trial.Marker(i).Processing.Gap        = [];
end