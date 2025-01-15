% Ensure 'eeg_data' is in the workspace

if ~exist ('eeg_data', 'var')

error ('The variable "eeg_data" does not exist in the workspace.');

end

% Parameters

fs = 256;

 % Sampling frequency (adjust according to your data)

eeg_channel = 1;

 % Channel of interest (index of the column in the table)

% Check the class and size of 'eeg_data'

disp('Class and size of ''eeg_data'':');

disp(class(eeg_data));

disp(size(eeg_data));

% Extract the EEG channel of interest (assuming 'eeg_data' is a table)

if ~istable(eeg_data)

error('The variable "eeg_data" must be a table.');

end

eeg_signal = eeg_data{:, eeg_channel};

 % Use curly braces to extract data as an array

% Check the class and size of 'eeg_signal'

disp('Class and size of ''eeg_signal'':');

disp(class(eeg_signal));

disp(size(eeg_signal));

% Display the first 10 values

if numel(eeg_signal) >= 10

disp('First 10 values of ''eeg_signal'':');

disp(eeg_signal(1:10));

else

disp('Not enough values to display the first 10 of ''eeg_signal''.');

disp(eeg_signal);

end

% Preprocessing: Use a simple moving average filter as an alternative

window_size = 50;

 % Size of the moving average window

if window_size <= 0 || ~isnumeric(window_size)

error('Window size must be a positive numeric integer.');

end

filtered_signal = movmean(eeg_signal, window_size);

disp('Warning: Using moving average filter instead of band-pass filter.');

% Check for Signal Processing Toolbox functions

try

% Apply band-pass filter to isolate specific frequency ranges for feature extraction

alpha_band = bandpass(filtered_signal, [8, 13], fs);

 % Alpha band (8-13 Hz)

beta_band = bandpass(filtered_signal, [13, 30], fs);

 % Beta band (13-30 Hz)

catch

disp('The bandpass function is not available. Implementing basic filtering.');

% Implement a basic band-pass filter from scratch (not as accurate)

alpha_band = filtered_signal;

 % Placeholder - simple moving average applied

beta_band = filtered_signal;

 % Placeholder - simple moving average applied

end

% Perform Fourier transform

X_alpha = fft(alpha_band);

X_beta = fft(beta_band);

% Calculate power spectral density

Pxx_alpha = abs(X_alpha).^2 / length(X_alpha);

Pxx_beta = abs(X_beta).^2 / length(X_beta);

% Frequency vector

f_alpha = (0:length(X_alpha)-1) * fs / length(X_alpha);

f_beta = (0:length(X_beta)-1) * fs / length(X_beta);

% Find peak frequencies in the alpha and beta bands

[~, peak_idx_alpha] = max(Pxx_alpha);

[~, peak_idx_beta] = max(Pxx_beta);

peak_freq_alpha = f_alpha(peak_idx_alpha);

peak_freq_beta = f_beta(peak_idx_beta);

% Display peak frequencies

disp(['Peak Alpha Frequency: ' num2str(peak_freq_alpha) ' Hz']);

disp(['Peak Beta Frequency: ' num2str(peak_freq_beta) ' Hz']);

% Feature extraction: Mean power in alpha and beta bands

mean_power_alpha = mean(Pxx_alpha(f_alpha >= 8 & f_alpha <= 13));

mean_power_beta = mean(Pxx_beta(f_beta >= 13 & f_beta <= 30));

% Combine features into a feature vector

features = [mean_power_alpha, mean_power_beta];

% Improved Classification Logic (scaled and adaptive)

% Adjust thresholds based on normalized power values and the range of feature space

total_power = mean_power_alpha + mean_power_beta;

if total_power == 0

error('Total power is zero, cannot classify. Check the EEG signal.');

end

alpha_ratio = mean_power_alpha / total_power;

beta_ratio = mean_power_beta / total_power;

% Emotion classification based on feature ratios

classification = struct('sad', 0, 'happy', 0, 'anger', 0, 'jealous', 0);

% Classify as "anger" based on beta dominance

classification.anger = beta_ratio * 100;

% Example classifications based on ratios (you can refine these as per data):

classification.happy = alpha_ratio * 100; 

% Hypothetically, high alpha may indicate happiness

classification.sad = (1 - alpha_ratio) * 50;

 % Assume higher non-alpha could indicate anger

classification.jealous = beta_ratio * 80;

 % Example, beta activity might be associated with jealousy

% Display classification

disp('Classification Result:');

disp(classification);

% Convert struct to array manually

emotion_names = fieldnames(classification);

emotion_values = zeros(length(emotion_names), 1); 

% Extract values from the struct manually

for i = 1:length(emotion_names)

emotion_values(i) = classification.(emotion_names{i});

end

% Plotting

figure;

% Plot the original EEG signal

subplot(3,1,1);

plot((1:length(eeg_signal))/fs, eeg_signal);

title('Original EEG Signal');

xlabel('Time (s)');

ylabel('Amplitude');

% Plot the filtered EEG signal

subplot(3,1,2);

plot((1:length(filtered_signal))/fs, filtered_signal);

title('Filtered EEG Signal');

xlabel('Time (s)');

ylabel('Amplitude');

% Plot Classification Result as a Bar Graph

subplot(3,1,3);

bar(categorical(emotion_names), emotion_values);

title('Emotion Classification');

xlabel('Emotion');

ylabel('Percentage');

ylim([0 100]);

 % Limit y-axis for better visibility

