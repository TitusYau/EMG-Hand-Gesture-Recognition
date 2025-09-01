clear; % Clears all variable and functions
clc; % Clears command window

% Parameters
fs = 200; % Sampling frequency of 200Hz
subjects = 1:10;
data_path = '/data/raw';
num_channels = 16;

% Initialize storage, creating empty arrays to store the emg data, labels, and subject info
all_emg_data = {} ;
all_labels = {};
subject_info = {};

% Load and process data for all subjects
for subject = subjects % For each subject
    filename = sprintf('S%d_E2_A1.mat', subject); % Generate file path for each subject
    filepath = fullfile(pwd, data_path,filename); % Create full file path
    if exist(filepath, 'file') % Check if the file exists
        loaded_data = load(filepath);
        emg = loaded_data.emg; % EMG Signals
        restimulus = loaded_data.restimulus; % Movement labels
        repetition = loaded_data.repetition; % Rep numbers 

        all_emg_data{subject} = emg; % Store emg data for subject
        all_labels{subject} = restimulus; % Store label for subject

        fprintf("Loaded data for Subject %d\n", subject);
        fprintf('Data shape: %d samples x %d channels\n', size(emg));
        fprintf('Number of movements: %d\n\n', max(restimulus));
    else
        warning('File not found: %s', filepath);
    end
end

% Signal Preprocessing

processed_data = {}

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


        % Plotting for testing purposes
        t = (0:length(emg_raw)-1) / 200;
        figure;
        subplot(3, 1, 1);
        plot(t, emg_raw);
        title('EMG Raw');
        xlabel('Time');
        ylabel('Amplitude');

        subplot(3, 1, 2);
        plot(t, emg_bandpassed);
        title('Bandpassed EMG');
        xlabel('Time');
        ylabel('Amplitude');

        subplot(3, 1, 3);
        plot(t, emg_notched);
        title('Notched EMG');
        xlabel('Time (s)');
        ylabel('Amplitude');
        break;
    end
end
