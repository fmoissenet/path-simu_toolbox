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
% Dependencies : - Biomechanical Toolkit (BTK): https://github.com/Biomechanical-ToolKit/BTKCore
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = ProcessEMGSignals(Trial,fmethod,smethod)

for i = 1:size(Trial.EMG,2)
    if ~isempty(Trial.EMG(i).Signal.raw)
        
        % -----------------------------------------------------------------
        % REPLACE NANs BY ZEROs
        % -----------------------------------------------------------------   
        Trial.EMG(i).Signal.filt                                  = Trial.EMG(i).Signal.raw;
        Trial.EMG(i).Signal.filt(isnan(Trial.EMG(i).Signal.filt)) = 0;

        % -----------------------------------------------------------------
        % ZEROING AND FILTER EMG SIGNAL
        % -----------------------------------------------------------------
        Trial.EMG(i).Signal.filt = Trial.EMG(i).Signal.filt-mean(Trial.EMG(i).Signal.filt,3,'omitnan');
        % Method 1: No filtering
        if strcmp(fmethod.type,'none')
            Trial.EMG(i).Signal.filt     = Trial.EMG(i).Signal.filt;
            Trial.EMG(i).Processing.filt = fmethod.type;
        
        % Method 2: Band pass filter (Butterworth 4nd order, [fmethod.parameter fmethod.parameter] Hz)
        elseif strcmp(fmethod.type,'butterBand4')
            [B,A]                        = butter(2,[fmethod.parameter(1) fmethod.parameter(2)]./(Trial.fanalog/2),'bandpass');
            Trial.EMG(i).Signal.filt     = permute(filtfilt(B,A,permute(Trial.EMG(i).Signal.filt,[3,1,2])),[2,3,1]);
            Trial.EMG(i).Processing.filt = fmethod.type;
        end

        % -----------------------------------------------------------------
        % RECTIFY EMG SIGNAL
        % -----------------------------------------------------------------
        Trial.EMG(i).Signal.rect = abs(Trial.EMG(i).Signal.filt);
        
        % -----------------------------------------------------------------
        % SMOOTH EMG SIGNAL
        % -----------------------------------------------------------------        
        % Method 1: No smoothing
        if strcmp(smethod.type,'none')
            Trial.EMG(i).Signal.smooth     = Trial.EMG(i).Signal.rect;
            Trial.EMG(i).Processing.smooth = smethod.type;
        
        % Method 2: Low pass filter (Butterworth 2nd order, [smethod.parameter] Hz)
        elseif strcmp(smethod.type,'butterLow2')
            [B,A]                          = butter(1,smethod.parameter/(Trial.fanalog/2),'low');
            Trial.EMG(i).Signal.smooth     = permute(filtfilt(B,A,permute(Trial.EMG(i).Signal.rect,[3,1,2])),[2,3,1]);
            Trial.EMG(i).Processing.smooth = smethod.type;
        
        % Method 3: Moving average (window of [smethod.parameter] frames)
        elseif strcmp(smethod.type,'movmean')
            Trial.EMG(i).Signal.smooth = permute(smoothdata(permute(Trial.EMG(i).Signal.rect,[3,1,2]),'movmean',smethod.parameter),[2,3,1]);
            Trial.EMG(i).Processing.smooth = 'movmean';
        
        % Method 4: Moving average (window of [smethod.parameter] frames)
        elseif strcmp(smethod.type,'movmedian')
            Trial.EMG(i).Signal.smooth = permute(smoothdata(permute(Trial.EMG(i).Signal.rect,[3,1,2]),'movmedian',smethod.parameter),[2,3,1]);
            Trial.EMG(i).Processing.smooth = 'movmedian';
        
        % Method 5: Signal root mean square (RMS) (window of [smethod.parameter] frames)
        elseif strcmp(smethod.type,'rms')
            Trial.EMG(i).Signal.smooth     = permute(envelope(permute(Trial.EMG(i).Signal.filt,[3,1,2]),smethod.parameter,'rms'),[2,3,1]);
            Trial.EMG(i).Processing.smooth = 'rms';
        end
               
    end
end