# EMG-Hand-Gesture-Recognition
This project aims to classify hand gestures using electromyography (EMG) signals. The goal is to build a machine learning model that accurately recognizes different hand gestures based on EMG data.

## Description
In this project, I will be using the Ninapro DB5 dataset to classify hand gestures based on EMG signals. The DB5 has 10 subjects, each performing 53 movements organized into three exercises. I will be focusing on exercise B, which includes 17 isotonic/isometric/wrist movements.  



## Preprocessing 
One of the main limitations of surface electromyography (sEMG) include surface crosstalk from nearby muscles, as electrodes often pick up signals from surrounding muscles, not just the target muscle. As a result, the collected signal may be affected by noise, yielding misleading results. Therefore, by performing preprocessing, we improve the signal-to-noise ratio, enabling more robust feature-extraction in the future, increasing model accuracy and stability in general. 

### Band-pass filtering

### Notch filtering

### Rectification and envelope

### Normalization

### Segmentation

### Power spectral density

### 