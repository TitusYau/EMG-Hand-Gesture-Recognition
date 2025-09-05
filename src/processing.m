clear; % Clears all variable and functions
clc; % Clears command window

% Parameters
fs = 200; % Sampling frequency of 200Hz
subjects = 1:10;
data_path = '/data/raw';
interim_path = '/data/interim';
num_channels = 16;

% Initialize storage, creating empty arrays to store the emg data, labels, and subject info
all_emg_data = {} ;
all_labels = {};
all_repetition = {};

% Load and process data for all subjects
for subject = subjects % For each subject
    filename = sprintf('S%d_E2_A1.mat', subject); % Generate file path for each subject
    filepath = fullfile(pwd, data_path,filename); % Create full file path
    if exist(filepath, 'file') % Check if the file exists
        loaded_data = load(filepath);
        emg = loaded_data.emg; % EMG Signals
        restimulus = loaded_data.restimulus; % Movement labels
        rerepetition = loaded_data.rerepetition; % Rep numbers 

        all_emg_data{subject} = emg; % Store emg data for subject
        all_stimulus{subject} = restimulus; % Store label for subject
        all_repetition{subject} = rerepetition;
    else
        warning('File not found: %s', filepath);
    end
end

% Signal Preprocessing

for subject = subjects
    if ~isempty(all_emg_data)
        emg_raw = all_emg_data{subject};

        % Remove the constant voltage offset caused by the interactions between the electrodes and skin
        dc_offset = mean(emg_raw); 
        emg_corrected = emg_raw - dc_offset;

        % Use fifth-order Butterworth filter to perform bandpass filtering for the EMG signal
        filter_order = 5;
        normalized_freq = [15,95]/(200/2); % Frequencies normalized by Nyquist frequency
        [b,a] = butter(filter_order, normalized_freq, 'bandpass'); 
        emg_bandpassed = filtfilt(b,a, emg_corrected); % Filter

        % Notch filter (removing interfering signals such as background hum produced by electrical grid)
        notch_freq = 60;
        Q = 30;
        [b_notch, a_notch] = iirnotch(notch_freq / (200/2), notch_freq / (200/2) / Q);
        emg_notched = filtfilt(b_notch, a_notch, emg_bandpassed);

        % Full wave rectification
        emg_rectified = abs(emg_notched);

        % RMS envelope signal, smoothing rectified signal to represent overall amplitude of the signal over time
        window_length = 100;
        emg_rms = zeros(size(emg_rectified));
        for ch = 1:size(emg_rectified, 2)
            for i = 1:size(emg_rectified, 1)
                start_idx = max(1, i - floor(window_length/2));
                end_idx = min(size(emg_rectified, 1), i + floor(window_length/2));
                emg_rms(i, ch) = sqrt(mean(emg_rectified(start_idx:end_idx, ch).^2));
            end
        end
        % Max normalization
        emg_normalized = emg_rms ./ max(emg_rms, [], 1);
        restimulus = all_stimulus{subject};
        rerepetition = all_repetition{subject};
        save(fullfile(pwd,interim_path, sprintf('S%d_E2_processed.mat', subject)), 'emg_normalized', 'restimulus', 'rerepetition');
    end
end
