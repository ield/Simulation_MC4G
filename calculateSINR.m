function [sinr] = calculateSINR(channel, tx_power_max, tx_gain, rx_gain, ...
    distance, rx_noise_figure, thermal_noise, subband_bw, ...
    number_subbands, Interference)
% Calculates the SINR of a given channel: the signal component is taken
% from the power, gain and losses. The noise from the bandwidth and noise
% figure
% channel: (dB) channel variationsdue to multipath, pathloss, etc
% tx_power_max: Maximum transmitted power (dBm)
% tx_gain:(dB)
% rx_gain:(dB)
% distance: distance from the user to the base (m) used to calc attenuation
% rx_noise_figure = 9:(dB)
% thermal_noise: (dBm/Hz): kt
% subband_bw: (Hz): used to calculate the bandwidth gor the noise
% number_subbands: used to calculate the total power per subband
% Interference: (dBm)

% The signal offser is calculated using friis: the tx power + gain - loss
tx_power = tx_power_max - 10*log10(number_subbands);
path_loss = 132.9 + 37.6*log10(distance/1000);
signal_offset = tx_power + tx_gain - path_loss + rx_gain;
Signal = channel + signal_offset;   % (dBm)

% The noise is calculates a ktbf
Noise = thermal_noise + rx_noise_figure + 10*log10(subband_bw);

sinr = Signal - Noise - Interference;

end

