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
        fprintf('Number of movements: %d\n', max(restimulus));
    else
        warning('File not found: %s', filepath);
    end
end
