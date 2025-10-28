function visualize_results(results_wo_cv_all, results_wo_cv_filtered, ...
                          results_w_cv_all, results_w_cv_filtered, ...
                          ground_truth, feature_names)
% =========================================================================
% VISUALIZE_RESULTS - Generate plots similar to paper Figs. 6 and 7
% =========================================================================
% Creates visualization plots showing:
% - Predicted vs Actual tensile strength
% - Comparison with/without contact voltage
% - Error distribution
% - Feature importance (coefficient magnitudes)
% =========================================================================

    % Create figure with subplots
    figure('Position', [100, 100, 1400, 900], 'Color', 'w');
    
    % ==== Subplot 1: Without CV - All features (Fig 6a style) ====
    subplot(2, 3, 1);
    plot_prediction_scatter(ground_truth, results_wo_cv_all.predictions, ...
                           'Without CV (All 12 features)');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nR²: %.3f', ...
                             results_wo_cv_all.rmse, results_wo_cv_all.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10);
    
    % ==== Subplot 2: Without CV - Filtered (paper results) ====
    subplot(2, 3, 2);
    plot_prediction_scatter(ground_truth, results_wo_cv_filtered.predictions, ...
                           'Without CV (P-filtered)');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nR²: %.3f', ...
                             results_wo_cv_filtered.rmse, results_wo_cv_filtered.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10);
    
    % ==== Subplot 3: Error comparison (Without CV) ====
    subplot(2, 3, 3);
    errors_all = ground_truth - results_wo_cv_all.predictions;
    errors_filtered = ground_truth - results_wo_cv_filtered.predictions;
    histogram(errors_all, 20, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.6, ...
              'DisplayName', 'All features');
    hold on;
    histogram(errors_filtered, 20, 'FaceColor', [0.2 0.2 0.8], 'FaceAlpha', 0.6, ...
              'DisplayName', 'Filtered');
    xlabel('Prediction Error (N)');
    ylabel('Count');
    title('Error Distribution (Without CV)');
    legend('Location', 'best');
    grid on;
    
    % ==== Subplot 4: With CV - All features (Fig 6b style) ====
    subplot(2, 3, 4);
    plot_prediction_scatter(ground_truth, results_w_cv_all.predictions, ...
                           'With CV (All 18 features)');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nR²: %.3f', ...
                             results_w_cv_all.rmse, results_w_cv_all.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10);
    
    % ==== Subplot 5: With CV - Filtered (Fig 7b style) ====
    subplot(2, 3, 5);
    plot_prediction_scatter(ground_truth, results_w_cv_filtered.predictions, ...
                           'With CV (P-filtered)');
    text(0.05, 0.95, sprintf('RMSE: %.1f N\nR²: %.3f', ...
                             results_w_cv_filtered.rmse, results_w_cv_filtered.r2), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'FontSize', 10);
    
    % ==== Subplot 6: Error comparison (With CV) ====
    subplot(2, 3, 6);
    errors_all = ground_truth - results_w_cv_all.predictions;
    errors_filtered = ground_truth - results_w_cv_filtered.predictions;
    histogram(errors_all, 20, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.6, ...
              'DisplayName', 'All features');
    hold on;
    histogram(errors_filtered, 20, 'FaceColor', [0.2 0.8 0.2], 'FaceAlpha', 0.6, ...
              'DisplayName', 'Filtered');
    xlabel('Prediction Error (N)');
    ylabel('Count');
    title('Error Distribution (With CV)');
    legend('Location', 'best');
    grid on;
    
    % Overall title
    sgtitle('RSW Tensile Strength Prediction Results', 'FontSize', 14, 'FontWeight', 'bold');
    
    % ==== Figure 2: Feature Importance Comparison ====
    figure('Position', [150, 150, 1200, 500], 'Color', 'w');
    
    % Subplot 1: P-values of all features (Table 3 style)
    subplot(1, 2, 1);
    pvalues_all = results_w_cv_all.pvalues;
    [pvalues_sorted, sort_idx] = sort(pvalues_all);
    names_sorted = feature_names(sort_idx);
    
    barh(1:length(pvalues_sorted), pvalues_sorted);
    hold on;
    plot([0.05 0.05], [0 length(pvalues_sorted)+1], 'r--', 'LineWidth', 2);
    set(gca, 'YTick', 1:length(pvalues_sorted), 'YTickLabel', names_sorted);
    xlabel('P-value');
    title('Statistical Significance of Features (p < 0.05 threshold)');
    grid on;
    xlim([0 max([0.1, max(pvalues_sorted)])]);
    
    % Subplot 2: Coefficients of selected features
    subplot(1, 2, 2);
    selected_idx = results_w_cv_filtered.pvalues < 0.05;
    if sum(selected_idx) > 0
        coef_selected = results_w_cv_filtered.coefficients;
        names_selected = results_w_cv_filtered.feature_names;
        
        [coef_abs_sorted, sort_idx] = sort(abs(coef_selected), 'descend');
        coef_sorted = coef_selected(sort_idx);
        names_sorted = names_selected(sort_idx);
        
        colors = zeros(length(coef_sorted), 3);
        for i = 1:length(coef_sorted)
            if coef_sorted(i) > 0
                colors(i, :) = [0.2 0.6 0.2]; % Green for positive
            else
                colors(i, :) = [0.8 0.2 0.2]; % Red for negative
            end
        end
        
        barh(1:length(coef_sorted), coef_sorted, 'FaceColor', 'flat', 'CData', colors);
        set(gca, 'YTick', 1:length(coef_sorted), 'YTickLabel', names_sorted);
        xlabel('Coefficient Value');
        title('Regression Coefficients of Selected Features');
        grid on;
    end
    
    % ==== Figure 3: Performance Comparison Bar Chart ====
    figure('Position', [200, 200, 800, 500], 'Color', 'w');
    
    models = {'W/O CV\n(All)', 'W/O CV\n(Filtered)', 'With CV\n(All)', 'With CV\n(Filtered)'};
    rmse_values = [results_wo_cv_all.rmse, results_wo_cv_filtered.rmse, ...
                   results_w_cv_all.rmse, results_w_cv_filtered.rmse];
    
    bar_colors = [0.8 0.2 0.2; 0.6 0.2 0.4; 0.2 0.6 0.2; 0.2 0.8 0.4];
    
    b = bar(rmse_values, 'FaceColor', 'flat');
    b.CData = bar_colors;
    
    set(gca, 'XTickLabel', models);
    ylabel('RMSE (N)');
    title('Model Performance Comparison', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    
    % Add value labels on bars
    for i = 1:length(rmse_values)
        text(i, rmse_values(i) + max(rmse_values)*0.02, ...
             sprintf('%.1f', rmse_values(i)), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Calculate and display improvement
    improvement = (results_wo_cv_filtered.rmse - results_w_cv_filtered.rmse) / ...
                  results_wo_cv_filtered.rmse * 100;
    text(0.5, max(rmse_values)*0.9, ...
         sprintf('Improvement: %.1f%% ↓', improvement), ...
         'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
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
