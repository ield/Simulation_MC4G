function [bit_rate] = obtainBitRate(sinr, subband_bw)
% Obtains the achievable bit rate from the sinr: it is used the AMC tables
% in order to obtain the bit rate that can be achieved at any given time:
% first it is obtained the efficiency from the amc tables and then the
% bitrate from the bw of the subband. Table obtained from 
% https://www.researchgate.net/figure/AMC-mapping-table-32_tbl3_277968475
% sinr(dB)
% subband_bw: (Hz): used to calculate the bitrate from the efficiency

snr_threshold = [-inf -6.5 -4 -2.6 -1 1 3 6.6 10 11.4 11.8 13 13.8 15.6 ...
                    16.8 17.6 inf];
% If the snr is smaller then snr_threshold(1) then the efficiency is 0.
% That is whi it is added an extra 0
spectral_efficiency = [0 0.15 0.23 0.38 0.6 0.88 1.18 1.48 1.91 2.41 ...
                        2.73 3.32 3.9 4.52 5.12 5.55];
snr_discrete_bin = discretize(sinr, snr_threshold);
efficiency = spectral_efficiency(snr_discrete_bin);
bit_rate = subband_bw*efficiency;
end

