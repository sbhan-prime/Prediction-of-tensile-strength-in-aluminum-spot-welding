% =========================================================================
% Main Script for Aluminum RSW Tensile Strength Prediction
% Based on: "Prediction of tensile strength in aluminum spot welding 
%            using machine learning"
% =========================================================================
% This script implements the complete ML pipeline including:
% 1. Data loading and preprocessing
% 2. Feature extraction (18 features from time-series signals)
% 3. Statistical significance testing (p-value filtering)
% 4. Machine learning model training and evaluation
% 5. Comparison with/without contact voltage features
% =========================================================================

clear; clc; close all;

%% Configuration
config.sampling_rate = 50000; % 50 kHz
config.preheat_duration = 0.02; % 20 ms
config.cooling_duration = 0.1; % 100 ms
config.welding_duration = 0.05; % 50 ms
config.k_fold = 5; % 5-fold cross-validation
config.p_threshold = 0.05; % significance level
config.dt = 1/config.sampling_rate; % 20 microseconds

fprintf('==========================================================\n');
fprintf('Aluminum RSW Tensile Strength Prediction using ML\n');
fprintf('==========================================================\n\n');

%% Step 1: Load Raw Time-Series Data
fprintf('Step 1: Loading raw time-series data...\n');
% Data should be in format: one row per weld
% Columns: [preheating_current, welding_current, electrode_force, 
%           current_signal, voltage_signal, contact_voltage_signal, 
%           tensile_strength]
% NOTE: User needs to provide actual data file
data_file = 'rsw_raw_data_2.mat'; % User should provide this file

if ~exist(data_file, 'file')
    fprintf('Data file not found.');
    [raw_data, ground_truth] = generate_synthetic_rsw_data(config);
else
    load(data_file, 'raw_data', 'ground_truth');
end

num_samples = size(raw_data, 1);
fprintf('  Loaded %d welding samples\n', num_samples);

%% Step 2: Feature Extraction
fprintf('Step 2: Extracting features from time-series signals...\n');
features_all = extract_rsw_features(raw_data, config);
feature_names = get_feature_names();

fprintf('  Extracted %d features per sample:\n', size(features_all, 2));
fprintf('  - Preheating stage: 9 features (3 signals × 3 statistics)\n');
fprintf('  - Welding stage: 9 features (3 signals × 3 statistics)\n');
fprintf('  Feature names:\n');
for i = 1:length(feature_names)
    fprintf('    %2d. %s\n', i, feature_names{i});
end
fprintf('\n');

%% Step 3: Prepare datasets with and without contact voltage
fprintf('Step 3: Preparing feature sets...\n');

% Features WITHOUT contact voltage (12 features)
cv_indices = contains(feature_names, 'CV');
features_without_cv = features_all(:, ~cv_indices);
feature_names_without_cv = feature_names(~cv_indices);

% Features WITH contact voltage (18 features)
features_with_cv = features_all;
feature_names_with_cv = feature_names;

fprintf('  Dataset WITHOUT contact voltage: %d features\n', size(features_without_cv, 2));
fprintf('  Dataset WITH contact voltage: %d features\n', size(features_with_cv, 2));
fprintf('\n');

%% Step 4: Train ML models and compare
fprintf('Step 4: Training and evaluating ML models...\n');
fprintf('--------------------------------------------------------\n');

% 4.1: Without contact voltage - All features
fprintf('Case 1: WITHOUT Contact Voltage (All 12 features)\n');
results_wo_cv_all = train_and_evaluate_model(features_without_cv, ground_truth, ...
                                              feature_names_without_cv, config);
fprintf('\n');

% 4.2: Without contact voltage - P-value filtered
fprintf('Case 2: WITHOUT Contact Voltage (P-value filtered, p < %.2f)\n', config.p_threshold);
[features_wo_cv_filtered, names_wo_cv_filtered] = filter_features_by_pvalue(...
    features_without_cv, ground_truth, feature_names_without_cv, config.p_threshold);
results_wo_cv_filtered = train_and_evaluate_model(features_wo_cv_filtered, ground_truth, ...
                                                   names_wo_cv_filtered, config);
fprintf('\n');

% 4.3: With contact voltage - All features
fprintf('Case 3: WITH Contact Voltage (All 18 features)\n');
results_w_cv_all = train_and_evaluate_model(features_with_cv, ground_truth, ...
                                            feature_names_with_cv, config);
fprintf('\n');

% 4.4: With contact voltage - P-value filtered
fprintf('Case 4: WITH Contact Voltage (P-value filtered, p < %.2f)\n', config.p_threshold);
[features_w_cv_filtered, names_w_cv_filtered] = filter_features_by_pvalue(...
    features_with_cv, ground_truth, feature_names_with_cv, config.p_threshold);
results_w_cv_filtered = train_and_evaluate_model(features_w_cv_filtered, ground_truth, ...
                                                  names_w_cv_filtered, config);
fprintf('\n');

%% Step 5: Compare results
fprintf('==========================================================\n');
fprintf('FINAL COMPARISON\n');
fprintf('==========================================================\n\n');

comparison_table = table(...
    {'Without CV (All)'; 'Without CV (Filtered)'; 'With CV (All)'; 'With CV (Filtered)'}, ...
    [size(features_without_cv, 2); size(features_wo_cv_filtered, 2); ...
     size(features_with_cv, 2); size(features_w_cv_filtered, 2)], ...
    [results_wo_cv_all.rmse; results_wo_cv_filtered.rmse; ...
     results_w_cv_all.rmse; results_w_cv_filtered.rmse], ...
    [results_wo_cv_all.mae; results_wo_cv_filtered.mae; ...
     results_w_cv_all.mae; results_w_cv_filtered.mae], ...
    [results_wo_cv_all.r2; results_wo_cv_filtered.r2; ...
     results_w_cv_all.r2; results_w_cv_filtered.r2], ...
    'VariableNames', {'Model', 'NumFeatures', 'RMSE', 'MAE', 'R2'});

disp(comparison_table);

% Calculate improvement
improvement = (results_wo_cv_filtered.rmse - results_w_cv_filtered.rmse) / ...
              results_wo_cv_filtered.rmse * 100;

%% Step 6: Visualize results
fprintf('Step 6: Generating visualization plots...\n');
visualize_results(results_wo_cv_all, results_wo_cv_filtered, ...
                 results_w_cv_all, results_w_cv_filtered, ...
                 ground_truth, feature_names_with_cv);
fprintf('==========================================================\n');

