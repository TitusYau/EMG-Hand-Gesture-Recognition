# EMG-Hand-Gesture-Recognition
This project aims to classify hand gestures using electromyography (EMG) signals. The goal is to build a machine learning model that accurately recognizes different hand gestures based on EMG data.

## Description
In this project, I will be using the Ninapro DB5 dataset to classify hand gestures based on EMG signals. The DB5 has 10 subjects, each performing 53 movements organized into three exercises. I will be focusing on exercise B, which includes 17 isotonic/isometric/wrist movements.  

## Preprocessing 
One of the main limitations of surface electromyography (sEMG) include surface crosstalk from nearby muscles, as electrodes often pick up signals from surrounding muscles, not just the target muscle. As a result, the collected signal may be affected by noise, yielding misleading results. Therefore, by performing preprocessing, we improve the signal-to-noise ratio, enabling more robust feature-extraction in the future, increasing model accuracy and stability in general. 

### Band-pass/Notch filtering
EMG signals are often contaminated by electrical signals due to crosstalk from muscles or other sources. A bandpass filter removes this noise by allowing only a specific frequency range to pass through, filtering out low/high frequency signals, enhancing the clarity of the EMG signals. Since the sampling frequency of the Ninapro DB5 dataset is 200Hz, I chose a frequency range of 15 to 95Hz, in order to ensure compliance with the Nyquist Theorem. In addition, this frequency range should effectively isolate the relevant muscle activity, while minimizing interferance and removing noise. After reviewing some papers that perform similar signal processing, I opted to use a fifth-order Butterworth filter for the bandpass filtering. In addition, I applied a notch filter to remove the 60Hz power line hum that is often present in EMG signal recordings.

### Rectification and envelope
By applying full-wave rectification and the filtered signal, both positive and negative portions of the EMG signal are converted into a unipolar signal, allowing the information from the entire waveform to be used. Furthermore, an RMS envelope is applied onto the signal, providing a measure of the average power of muscle activity over time. These techniques overall improve the quality of the EMG signal for feature extraction and machine learning later on. 

### Normalization
Following research papers that have worked on the same database, I decided to apply max normalization on the emg singals. This brings all the data points onto a common scale, allowing for machine learning algorithms to perform better, as it reduces the risk for certain features to dominate the learning process.
