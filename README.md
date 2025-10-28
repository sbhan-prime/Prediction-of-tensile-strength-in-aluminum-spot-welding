# Prediction-of-tensile-strength-in-aluminum-spot-welding

Overview
This code implements a machine learning pipeline to predict tensile strength in aluminum resistance spot welding (RSW) based on monitored time-series signals. The key contribution is the inclusion of contact voltage measured at the faying interface, which significantly improves prediction accuracy (~30% reduction in RMSE compared to conventional methods).
Features

Feature Extraction: Extracts 18 statistical features from time-series signals

3 signals: Current, Voltage, Contact Voltage
2 windows: Preheating, Welding
3 statistics per signal: Maximum, Mean, Time-of-peak


Statistical Analysis: P-value based feature selection (p < 0.05)
Machine Learning: Linear regression with 5-fold cross-validation
Comparison: Analyzes performance with/without contact voltage measurement
