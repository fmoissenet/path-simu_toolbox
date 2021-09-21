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
% Description  : This routine aims to export C3D files with updated data.
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : - Biomechanical Toolkit (BTK): https://github.com/Biomechanical-ToolKit/BTKCore
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function ExportC3D(Trial,Folder)

% Set new C3D file
btkFile = btkNewAcquisition();
btkSetFrequency(btkFile,Trial.fmarker);
btkSetFrameNumber(btkFile,Trial.n1);
btkSetPointsUnit(btkFile,'marker','m');
btkSetAnalogSampleNumberPerFrame(btkFile,10);

% Append events
if ~isempty(Trial.Event)
    for i = 1:size(Trial.Event,2)
        for j = 1:size(Trial.Event(i).value,2)
            Event = Trial.Event(i).value(1,j)/Trial.fmarker;
            btkAppendEvent(btkFile,Trial.Event(i).label,Event,'');
            clear Event;
        end
    end
end

% Append marker trajectories
if ~isempty(Trial.Marker)
    for i = 1:size(Trial.Marker,2)
        if ~isempty(Trial.Marker(i).Trajectory.smooth)
            btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,permute(Trial.Marker(i).Trajectory.smooth,[3,1,2]));
        else
            btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,zeros(Trial.n1,3));
        end
    end
end

% Append virtual marker trajectories
if ~isempty(Trial.Vmarker)
    for i = 1:size(Trial.Vmarker,2)
        if ~isempty(Trial.Vmarker(i).Trajectory.smooth)
            btkAppendPoint(btkFile,'marker',Trial.Vmarker(i).label,permute(Trial.Vmarker(i).Trajectory.smooth,[3,1,2]));
        else
            btkAppendPoint(btkFile,'marker',Trial.Vmarker(i).label,zeros(Trial.n1,3));
        end
    end
end

% Append EMG signals
if ~isempty(Trial.EMG)
    for i = 1:size(Trial.EMG,2)
        if ~isempty(Trial.EMG(i).Signal.filt)
            btkAppendAnalog(btkFile,[Trial.EMG(i).label,'_raw'],permute(Trial.EMG(i).Signal.filt,[3,1,2]),'EMG signal (mV)');
        end
    end
end

% Export C3D file
cd(Folder.export);
btkWriteAcquisition(btkFile,[regexprep(Trial.file,'.c3d',''),'_processed.c3d']);