# Prediction-of-tensile-strength-in-aluminum-spot-welding

## **Overview**
This code implements a machine learning pipeline to predict tensile strength in aluminum resistance spot welding (RSW) based on monitored time-series signals. The key contribution is the inclusion of contact voltage measured at the faying interface, which significantly improves prediction accuracy (~30% reduction in RMSE compared to conventional methods).


## **Features**

#### **● Feature Extraction:** Extracts 18 statistical features from time-series signals

      ● 3 signals: Current, Voltage, Contact Voltage
      ● 2 windows: Preheating, Welding
      ● 3 statistics per signal: Maximum, Mean, Time-of-peak


#### **● Statistical Analysis:** P-value based feature selection (p < 0.05)

#### **● Machine Learning:** Linear regression with 5-fold cross-validation

#### **● Comparison:** Analyzes performance with/without contact voltage measurement

## **File Structure**
      main_rsw_prediction.m              # Main execution script
      extract_rsw_features.m             # Feature extraction
      train_and_evaluate_model.m         # ML training and k-fold CV
      filter_features_by_pvalue.m        # Statistical significance testing
      visualize_results.m                # Generate plots
      generate_synthetic_rsw_data.m      # Synthetic data generator
      example_data_loading.m             # Examples for loading real data
      README.md                          # This file

## **Requirements**
#### **Software**

● MATLAB R2022b or later

● Statistics and Machine Learning Toolbox

#### **Experimental Data Requirements**
To use this code with your own data, you need:
#### **Time-Series Signals (50 kHz sampling rate)**
For each weld specimen:

##### __● Current signal__ (measured with Rogowski coil)

##### __● Voltage signal__ (measured between electrodes)

##### __● Contact voltage signal__ (measured at faying interface) ⭐ KEY CONTRIBUTION

**2. Process Windows**

##### __●Preheating:__ 20 ms (1,000 samples at 50 kHz)

##### __●Cooling:__ 100 ms between preheating and welding

##### __●Welding:__ 50 ms (2,500 samples at 50 kHz)

#### **3. Process Parameters**

Preheating current: 8-12 kA
Welding current: 25-31 kA
Electrode force: Variable (e.g., 3-5 kN)
Preheating time: 20 ms (fixed)
Welding time: 50 ms (fixed)
Cooling time: 100 ms (fixed)

#### **4. Ground Truth**

Tensile strength from mechanical testing (N)
According to KS B 0854 standards
Specimen size: 100 mm × 30 mm × 1 mm (thickness)
