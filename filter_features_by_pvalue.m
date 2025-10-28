function [features_filtered, feature_names_filtered] = filter_features_by_pvalue(features, targets, feature_names, p_threshold)
% =========================================================================
% FILTER_FEATURES_BY_PVALUE - Select statistically significant features
% =========================================================================
% Implements the feature selection method from the paper (Table 3):
% - Train initial linear model on all features
% - Calculate p-values for each coefficient
% - Select only features with p < 0.05 (or specified threshold)
% - Return filtered feature set
%
% This corresponds to the paper's approach where variables with p > 0.05
% were excluded from the model.
%
% Input:
%   features: [N x D] feature matrix
%   targets: [N x 1] target values
%   feature_names: Cell array of D feature names
%   p_threshold: P-value threshold (default: 0.05)
%
% Output:
%   features_filtered: [N x D'] filtered feature matrix (D' <= D)
%   feature_names_filtered: Cell array of selected feature names
% =========================================================================

    % Train initial model on all features
    mdl = fitlm(features, targets, 'linear');
    
    % Get p-values (exclude intercept)
    pvalues = mdl.Coefficients.pValue(2:end);
    coefficients = mdl.Coefficients.Estimate(2:end);
    
    % Display initial analysis
    fprintf('  Initial feature analysis:\n');
    fprintf('  %-20s %12s %10s %10s\n', 'Feature', 'Coefficient', 'P-value', 'Selected');
    fprintf('  %s\n', repmat('-', 1, 55));
    
    for i = 1:length(feature_names)
        is_significant = pvalues(i) < p_threshold;
        status = '';
        if is_significant
            status = '  ***';
        end
        fprintf('  %-20s %12.4f %10.4f %10s\n', ...
                feature_names{i}, coefficients(i), pvalues(i), status);
    end
    fprintf('  %s\n', repmat('-', 1, 55));
    
    % Select significant features
    significant_idx = find(pvalues < p_threshold);
    
    if isempty(significant_idx)
        warning('No features meet the p-value threshold. Using all features.');
        features_filtered = features;
        feature_names_filtered = feature_names;
    else
        features_filtered = features(:, significant_idx);
        feature_names_filtered = feature_names(significant_idx);
        fprintf('  Selected %d out of %d features (%.1f%%)\n\n', ...
                length(significant_idx), length(feature_names), ...
                100 * length(significant_idx) / length(feature_names));
    end
end

%[appendix]{"version":"1.0"}
%---
