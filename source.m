if ~exist('eeg_data', 'var')
    error('The variable "eeg_data" does not exist in the workspace.');
end

fs = 256;
eeg_channel = 1;

disp('Class and size of ''eeg_data'':');
disp(class(eeg_data));
disp(size(eeg_data));

if ~istable(eeg_data)
    error('The variable "eeg_data" must be a table.');
end

eeg_signal = eeg_data{:, eeg_channel};

disp('Class and size of ''eeg_signal'':');
disp(class(eeg_signal));
disp(size(eeg_signal));

if numel(eeg_signal) >= 10
    disp('First 10 values of ''eeg_signal'':');
    disp(eeg_signal(1:10));
else
    disp('Not enough values to display the first 10 of ''eeg_signal''.');
    disp(eeg_signal);
end

window_size = 50;

if window_size <= 0 || ~isnumeric(window_size)
    error('Window size must be a positive numeric integer.');
end

filtered_signal = movmean(eeg_signal, window_size);

try
    alpha_band = bandpass(filtered_signal, [8, 13], fs);
    beta_band = bandpass(filtered_signal, [13, 30], fs);
catch
    alpha_band = filtered_signal;
    beta_band = filtered_signal;
end

X_alpha = fft(alpha_band);
X_beta = fft(beta_band);

Pxx_alpha = abs(X_alpha).^2 / length(X_alpha);
Pxx_beta = abs(X_beta).^2 / length(X_beta);

f_alpha = (0:length(X_alpha)-1) * fs / length(X_alpha);
f_beta = (0:length(X_beta)-1) * fs / length(X_beta);

[~, peak_idx_alpha] = max(Pxx_alpha);
[~, peak_idx_beta] = max(Pxx_beta);

peak_freq_alpha = f_alpha(peak_idx_alpha);
peak_freq_beta = f_beta(peak_idx_beta);

disp(['Peak Alpha Frequency: ' num2str(peak_freq_alpha) ' Hz']);
disp(['Peak Beta Frequency: ' num2str(peak_freq_beta) ' Hz']);

mean_power_alpha = mean(Pxx_alpha(f_alpha >= 8 & f_alpha <= 13));
mean_power_beta = mean(Pxx_beta(f_beta >= 13 & f_beta <= 30));

features = [mean_power_alpha, mean_power_beta];

total_power = mean_power_alpha + mean_power_beta;

if total_power == 0
    error('Total power is zero, cannot classify. Check the EEG signal.');
end

alpha_ratio = mean_power_alpha / total_power;
beta_ratio = mean_power_beta / total_power;

classification = struct('sad', 0, 'happy', 0, 'anger', 0, 'jealous', 0);

classification.anger = beta_ratio * 100;
classification.happy = alpha_ratio * 100;
classification.sad = (1 - alpha_ratio) * 50;
classification.jealous = beta_ratio * 80;

disp('Classification Result:');
disp(classification);

emotion_names = fieldnames(classification);
emotion_values = zeros(length(emotion_names), 1);

for i = 1:length(emotion_names)
    emotion_values(i) = classification.(emotion_names{i});
end

figure;

subplot(3,1,1);
plot((1:length(eeg_signal))/fs, eeg_signal);
title('Original EEG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot((1:length(filtered_signal))/fs, filtered_signal);
title('Filtered EEG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
bar(categorical(emotion_names), emotion_values);
title('Emotion Classification');
xlabel('Emotion');
ylabel('Percentage');
ylim([0 100]);
