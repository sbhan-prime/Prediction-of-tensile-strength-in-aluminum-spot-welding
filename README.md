# Prediction-of-tensile-strength-in-aluminum-spot-welding

## **Overview**
This code implements a machine learning pipeline to predict tensile strength in aluminum resistance spot welding (RSW) based on monitored time-series signals. The key contribution is the inclusion of contact voltage measured at the faying interface, which significantly improves prediction accuracy (~30% reduction in RMSE compared to conventional methods).


## **Features**

Feature Extraction: Extracts 18 statistical features from time-series signals

3 signals: Current, Voltage, Contact Voltage
2 windows: Preheating, Welding
3 statistics per signal: Maximum, Mean, Time-of-peak


Statistical Analysis: P-value based feature selection (p < 0.05)
Machine Learning: Linear regression with 5-fold cross-validation
Comparison: Analyzes performance with/without contact voltage measurement

File Structure
main_rsw_prediction.m              # Main execution script
extract_rsw_features.m             # Feature extraction (Eq. 1-3 from paper)
train_and_evaluate_model.m         # ML training and k-fold CV
filter_features_by_pvalue.m        # Statistical significance testing
visualize_results.m                # Generate plots (Fig. 6, 7 style)
generate_synthetic_rsw_data.m      # Synthetic data generator (for testing)
example_data_loading.m             # Examples for loading real data
README.md                          # This file
Requirements
Software

MATLAB R2022b or later
Statistics and Machine Learning Toolbox

Experimental Data Requirements
To use this code with your own data, you need:
1. Time-Series Signals (50 kHz sampling rate)
For each weld specimen:

Current signal (measured with Rogowski coil)
Voltage signal (measured between electrodes)
Contact voltage signal (measured at faying interface) ⭐ KEY CONTRIBUTION

2. Process Windows

Preheating: 20 ms (1,000 samples at 50 kHz)
Cooling: 100 ms between preheating and welding
Welding: 50 ms (2,500 samples at 50 kHz)

3. Process Parameters (from Table 1)

Preheating current: 8-12 kA
Welding current: 25-31 kA
Electrode force: Variable (e.g., 3-5 kN)
Preheating time: 20 ms (fixed)
Welding time: 50 ms (fixed)
Cooling time: 100 ms (fixed)

4. Ground Truth

Tensile strength from mechanical testing (N)
According to KS B 0854 standards
Specimen size: 100 mm × 30 mm × 1 mm (thickness)

Data Format
Your data should be structured as:
matlab% raw_data: Cell array [N x 1]
% Each cell contains a struct with:
raw_data{i}.preheat_current           % [1000 x 1] vector
raw_data{i}.preheat_voltage           % [1000 x 1] vector
raw_data{i}.preheat_contact_voltage   % [1000 x 1] vector
raw_data{i}.weld_current              % [2500 x 1] vector
raw_data{i}.weld_voltage              % [2500 x 1] vector
raw_data{i}.weld_contact_voltage      % [2500 x 1] vector

% ground_truth: [N x 1] vector of tensile strength values
ground_truth(i)                       % Tensile strength in Newtons
Usage
Quick Start (with synthetic data)
matlab% Run the main script - it will generate synthetic data if no real data exists
main_rsw_prediction
Using Your Own Data

Prepare your data following the format above
Save to MAT file:

matlab   save('rsw_raw_data.mat', 'raw_data', 'ground_truth');

Run main script:

matlab   main_rsw_prediction
Example Data Loading
See example_data_loading.m for detailed examples of:

Loading from CSV files (LabVIEW export)
Loading from MAT files
Data quality checks
Visualization of weld cycles

Expected Results
Based on the paper, you should see:
Model ConfigurationRMSEImprovementWithout CV (All features)Baseline-Without CV (P-filtered)Lower 10-15%With CV (All features)Lower 20-25%With CV (P-filtered)Lowest~30% ⭐
Key Findings (Table 3)
Statistically significant features (p < 0.05):

Weld_Vmean (Mean electrode voltage during welding) - Most significant
Weld_CVmean (Mean contact voltage during welding) ⭐
Weld_TCVmax (Time of peak contact voltage) ⭐
Weld_Imean (Mean current during welding)

Preheating features generally show p > 0.05, indicating less impact on final tensile strength.
Methodology
Feature Extraction (from paper Eq. 1-3)
For each signal x(t):
x_max  = max(x)                    # Maximum value
x_mean = (1/N) * Σ x_i            # Mean value
t_max  = argmax(x)                 # Time of peak
Machine Learning Pipeline

Data Collection: Acquire signals at 50 kHz
Feature Extraction: Extract 18 features (3 stats × 3 signals × 2 windows)
Data Shuffling: Random shuffling with fixed seed
K-Fold CV: 5-fold cross-validation
Model Training: Linear regression (OLS)
Statistical Testing: Calculate p-values
Feature Selection: Keep only features with p < 0.05
Re-training: Train final model with selected features
Evaluation: Calculate RMSE, MAE, R²

Why Contact Voltage?
From the paper:

"Unlike conventional dynamic resistance, which includes all resistance components in the welding circuit, contact voltage is directly measured at the faying interface between aluminum sheets. Thus, it excludes voltage drops across the electrode-material interfaces and better reflects interfacial phenomena such as oxide breakdown and nugget initiation."

The aluminum oxide layer is non-uniform and significantly affects weld quality. Contact voltage is more sensitive to these interfacial phenomena than electrode-to-electrode voltage.
Measurement System Setup
As described in paper Fig. 1:

Hardware:

Spot welding machine with 6-axis robot
NI-9221 DAQ (8 channels, 50 kHz per channel)
Rogowski coil for current measurement
Voltage clamps on electrodes
Wire connected to upper sheet for contact voltage


Signal Acquisition:

Sampling rate: 50 kHz
Data transfer: USB 3.0
Software: LabVIEW (or equivalent)


Contact Voltage Measurement:

Connect wire to upper aluminum sheet
Measure voltage between sheets at faying interface
This excludes electrode-material contact resistance



Troubleshooting
"Data file not found" warning

The code will generate synthetic data for demonstration
Replace with your actual experimental data following the format above

Low prediction accuracy

Check if contact voltage is properly measured
Verify sampling rate is 50 kHz
Ensure proper time window extraction
Check for outliers in tensile test data (exclude interfacial fractures)

P-values all > 0.05

May indicate insufficient data or high noise
Collect more samples (paper used multiple specimens per condition)
Check signal quality and calibration

Citation
If you use this code, please cite the original paper:
Bo Wook Seo et al., "Prediction of tensile strength in aluminum spot welding 
using machine learning" (2025)
Notes

Data Not Included: This repository contains only the code. You must provide your own experimental data.
Synthetic Data: The synthetic data generator is for demonstration only and does not represent real RSW physics accurately.
Process Parameters: The code assumes fixed process parameters as described in the paper. Adjust as needed for your setup.
Material: Optimized for aluminum alloy RSW. May require modification for other materials.
Safety: Always follow proper safety protocols when operating resistance spot welding equipment.

Contact
For questions about the implementation, please refer to the paper or contact the authors.

Important: This is a research implementation. Validate thoroughly before use in production environments.
