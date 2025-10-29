function visualize_results(results_wo_cv_all, results_wo_cv_filtered, ...
                          results_w_cv_all, results_w_cv_filtered, ...
                          ground_truth, feature_names)
% =========================================================================
% VISUALIZE_RESULTS - Generate plots identical to paper Figs. 6 and 7
% =========================================================================
% Creates visualization plots showing:
% - Figure 6: Prediction accuracy (all features)
%   - (a) before including contact-voltage features
%   - (b) after including contact-voltage features
% - Figure 7: Prediction accuracy (p-value filtered features)
%   - (a) before including contact-voltage features  
%   - (b) after including contact-voltage features
% =========================================================================

    % ==== Figure 1: All Features (Paper Figure 6) ====
    figure('Position', [100, 100, 1200, 500], 'Color', 'w');
    
    % Subplot (a): Without Contact Voltage - All features
    subplot(1, 2, 1);
    plot_prediction_scatter(ground_truth, results_wo_cv_all.predictions, ...
                           '(a) Before including contact-voltage features');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nMAE: %.1f N\nR²: %.3f', ...
                             results_wo_cv_all.rmse, results_wo_cv_all.mae, ...
                             results_wo_cv_all.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10, 'FontWeight', 'bold');
    
    % Subplot (b): With Contact Voltage - All features
    subplot(1, 2, 2);
    plot_prediction_scatter(ground_truth, results_w_cv_all.predictions, ...
                           '(b) After including contact-voltage features');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nMAE: %.1f N\nR²: %.3f', ...
                             results_w_cv_all.rmse, results_w_cv_all.mae, ...
                             results_w_cv_all.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10, 'FontWeight', 'bold');
    
    sgtitle('Prediction accuracy of the linear model (all features)', ...
            'FontSize', 13, 'FontWeight', 'bold');
    
    % ==== Figure 2: Filtered Features (Paper Figure 7) ====
    figure('Position', [150, 150, 1200, 500], 'Color', 'w');
    
    % Subplot (a): Without Contact Voltage - Filtered features
    subplot(1, 2, 1);
    plot_prediction_scatter(ground_truth, results_wo_cv_filtered.predictions, ...
                           '(a) Before including contact-voltage features');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nMAE: %.1f N\nR²: %.3f', ...
                             results_wo_cv_filtered.rmse, results_wo_cv_filtered.mae, ...
                             results_wo_cv_filtered.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10, 'FontWeight', 'bold');
    
    % Subplot (b): With Contact Voltage - Filtered features
    subplot(1, 2, 2);
    plot_prediction_scatter(ground_truth, results_w_cv_filtered.predictions, ...
                           '(b) After including contact-voltage features');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nMAE: %.1f N\nR²: %.3f', ...
                             results_w_cv_filtered.rmse, results_w_cv_filtered.mae, ...
                             results_w_cv_filtered.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10, 'FontWeight', 'bold');
    
    sgtitle('Prediction accuracy of the linear model (p-value filtered features, p ≤ 0.05)', ...
            'FontSize', 13, 'FontWeight', 'bold');
end


function plot_prediction_scatter(actual, predicted, title_text)
% Helper function to create scatter plot with reference line
    scatter(actual, predicted, 50, 'filled', 'MarkerFaceAlpha', 0.6);
    hold on;
    
    % Perfect prediction line
    min_val = min([actual; predicted]);
    max_val = max([actual; predicted]);
    plot([min_val max_val], [min_val max_val], 'r--', 'LineWidth', 2);
    
    xlabel('Actual Tensile Strength (N)');
    ylabel('Predicted Tensile Strength (N)');
    title(title_text);
    grid on;
    axis equal;
    axis([min_val max_val min_val max_val]);
end

%[appendix]{"version":"1.0"}
%---
