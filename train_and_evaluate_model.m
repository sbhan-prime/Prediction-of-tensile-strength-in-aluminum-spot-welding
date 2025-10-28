function results = train_and_evaluate_model(features, targets, feature_names, config)
% =========================================================================
% TRAIN_AND_EVALUATE_MODEL - Train linear regression with k-fold CV
% =========================================================================
% Implements the ML approach from the paper:
% - Linear regression model (OLS - Ordinary Least Squares)
% - K-fold cross-validation (k=5)
% - Random shuffling to prevent bias
%
% Input:
%   features: [N x D] feature matrix
%   targets: [N x 1] tensile strength values (ground truth)
%   feature_names: Cell array of feature names
%   config: Configuration struct
%
% Output:
%   results: Struct containing:
%            - rmse: Root Mean Square Error
%            - mae: Mean Absolute Error
%            - r2: R-squared coefficient
%            - model: Trained model on full dataset
%            - predictions: Cross-validated predictions
%            - coefficients: Regression coefficients
%            - pvalues: P-values for each coefficient
% =========================================================================

    num_samples = size(features, 1);
    num_features = size(features, 2);
    k_fold = config.k_fold;
    
    % Initialize storage
    predictions = zeros(num_samples, 1);
    all_coefficients = zeros(k_fold, num_features + 1); % +1 for intercept
    
    % Random shuffling with fixed seed for reproducibility
    rng(42);
    shuffle_idx = randperm(num_samples);
    features_shuffled = features(shuffle_idx, :);
    targets_shuffled = targets(shuffle_idx);
    
    % K-fold cross-validation
    cv_partition = cvpartition(num_samples, 'KFold', k_fold);
    
    fprintf('  Training with %d-fold cross-validation...\n', k_fold);
    for fold = 1:k_fold
        % Split data
        train_idx = training(cv_partition, fold);
        test_idx = test(cv_partition, fold);
        
        X_train = features_shuffled(train_idx, :);
        y_train = targets_shuffled(train_idx);
        X_test = features_shuffled(test_idx, :);
        
        % Train linear regression model (OLS)
        mdl = fitlm(X_train, y_train, 'linear');
        
        % Store coefficients
        all_coefficients(fold, :) = mdl.Coefficients.Estimate';
        
        % Predict on test set
        y_pred = predict(mdl, X_test);
        
        % Store predictions in original order
        original_test_idx = shuffle_idx(test_idx);
        predictions(original_test_idx) = y_pred;
    end
    
    % Train final model on full dataset for coefficient analysis
    final_model = fitlm(features, targets, 'linear');
    
    % Calculate performance metrics
    rmse = sqrt(mean((targets - predictions).^2));
    mae = mean(abs(targets - predictions));
    
    % Calculate R-squared
    ss_res = sum((targets - predictions).^2);
    ss_tot = sum((targets - mean(targets)).^2);
    r2 = 1 - (ss_res / ss_tot);
    
    % Extract p-values and coefficients
    coefficients = final_model.Coefficients.Estimate(2:end); % Exclude intercept
    pvalues = final_model.Coefficients.pValue(2:end); % Exclude intercept
    
    % Display results
    fprintf('  Performance Metrics:\n');
    fprintf('    RMSE: %.2f N\n', rmse);
    fprintf('    MAE:  %.2f N\n', mae);
    fprintf('    R²:   %.4f\n', r2);
    
    % Display significant features
    significant_idx = find(pvalues < config.p_threshold);
    if ~isempty(significant_idx)
        fprintf('  Significant features (p < %.2f):\n', config.p_threshold);
        for i = 1:length(significant_idx)
            idx = significant_idx(i);
            fprintf('    %s: coef=%.4f, p=%.4f\n', ...
                    feature_names{idx}, coefficients(idx), pvalues(idx));
        end
    else
        fprintf('  No features with p < %.2f\n', config.p_threshold);
    end
    
    % Store results
    results.rmse = rmse;
    results.mae = mae;
    results.r2 = r2;
    results.model = final_model;
    results.predictions = predictions;
    results.coefficients = coefficients;
    results.pvalues = pvalues;
    results.feature_names = feature_names;
    results.num_features = num_features;
end

%[appendix]{"version":"1.0"}
%---
