function features = extract_rsw_features(raw_data, config)
% =========================================================================
% EXTRACT_RSW_FEATURES - Extract 18 features from RSW time-series data
% =========================================================================
% Implements the feature extraction method from the paper:
% - Maximum value (xmax)
% - Mean value (xmean) 
% - Time-of-peak (tmax)
% Applied to 3 signals (Current, Voltage, Contact Voltage)
% in 2 windows (Preheating, Welding)
%
% Input:
%   raw_data: Cell array of size [N x 1], where each cell contains
%             a struct with fields:
%             - preheat_current: [M1 x 1] vector
%             - preheat_voltage: [M1 x 1] vector
%             - preheat_contact_voltage: [M1 x 1] vector
%             - weld_current: [M2 x 1] vector
%             - weld_voltage: [M2 x 1] vector
%             - weld_contact_voltage: [M2 x 1] vector
%   config: Configuration struct with sampling_rate, etc.
%
% Output:
%   features: [N x 18] matrix of extracted features
%             Order: [Preheat_I_max, Preheat_I_mean, Preheat_I_tmax,
%                     Preheat_V_max, Preheat_V_mean, Preheat_V_tmax,
%                     Preheat_CV_max, Preheat_CV_mean, Preheat_CV_tmax,
%                     Weld_I_max, Weld_I_mean, Weld_I_tmax,
%                     Weld_V_max, Weld_V_mean, Weld_V_tmax,
%                     Weld_CV_max, Weld_CV_mean, Weld_CV_tmax]
% =========================================================================

    num_samples = length(raw_data);
    features = zeros(num_samples, 18);
    
    for i = 1:num_samples
        sample = raw_data{i};
        
        % ===== PREHEATING FEATURES (9 features) =====
        % Current features (Imax, Imean, TImax)
        [features(i, 1), idx] = max(sample.preheat_current);        % Imax
        features(i, 2) = mean(sample.preheat_current);              % Imean
        features(i, 3) = idx * config.dt * 1000;                    % TImax (in ms)
        
        % Voltage features (Vmax, Vmean, TVmax)
        [features(i, 4), idx] = max(sample.preheat_voltage);        % Vmax
        features(i, 5) = mean(sample.preheat_voltage);              % Vmean
        features(i, 6) = idx * config.dt * 1000;                    % TVmax (in ms)
        
        % Contact Voltage features (CVmax, CVmean, TCVmax)
        [features(i, 7), idx] = max(sample.preheat_contact_voltage); % CVmax
        features(i, 8) = mean(sample.preheat_contact_voltage);       % CVmean
        features(i, 9) = idx * config.dt * 1000;                     % TCVmax (in ms)
        
        % ===== WELDING FEATURES (9 features) =====
        % Current features (Imax, Imean, TImax)
        [features(i, 10), idx] = max(sample.weld_current);          % Imax
        features(i, 11) = mean(sample.weld_current);                % Imean
        features(i, 12) = idx * config.dt * 1000;                   % TImax (in ms)
        
        % Voltage features (Vmax, Vmean, TVmax)
        [features(i, 13), idx] = max(sample.weld_voltage);          % Vmax
        features(i, 14) = mean(sample.weld_voltage);                % Vmean
        features(i, 15) = idx * config.dt * 1000;                   % TVmax (in ms)
        
        % Contact Voltage features (CVmax, CVmean, TCVmax)
        [features(i, 16), idx] = max(sample.weld_contact_voltage);  % CVmax
        features(i, 17) = mean(sample.weld_contact_voltage);        % CVmean
        features(i, 18) = idx * config.dt * 1000;                   % TCVmax (in ms)
    end
end


function feature_names = get_feature_names()
% =========================================================================
% GET_FEATURE_NAMES - Return descriptive names for all 18 features
% =========================================================================
    feature_names = {
        'Preheat_Imax',     'Preheat_Imean',     'Preheat_TImax', ...
        'Preheat_Vmax',     'Preheat_Vmean',     'Preheat_TVmax', ...
        'Preheat_CVmax',    'Preheat_CVmean',    'Preheat_TCVmax', ...
        'Weld_Imax',        'Weld_Imean',        'Weld_TImax', ...
        'Weld_Vmax',        'Weld_Vmean',        'Weld_TVmax', ...
        'Weld_CVmax',       'Weld_CVmean',       'Weld_TCVmax'
    };
end

%[appendix]{"version":"1.0"}
%---
