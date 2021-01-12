function [channel] = generateChannel(number_objects, speed, f, c, ...
    maximum_distance, time_frame, evaluation_time, subband_bw, ...
    number_subbands)
% Generates a channel for a given user
% Number_objects: number of objects determinin multipath
% Speed: speed of the user (km/h)
% f: Frequency of the communication (Hz)
% c: Speed of light (m/s)
% maximum_distance: The maximum delay comes from ... (m)
% time_frame: Time division (s)
% evaluation_time: (s)
% subband_bw: (Hz)
% number_subbands 

A = rand(1, number_objects);

% Dopler shifts
speed = speed*1000/3600;                % Speed (m/s)
f_dopler_max = f*(c+speed)/c - f;           % Dopler frequency (Hz)
    % The dopler vector will contain all the dopler shifts. This shifts can
    % be positive or negative: if the signal is direct, the user may be
    % going away from the base (negative) or going towards the base
    % (positive). It is also possible that the signal is not direct. That
    % is why the dopler seen can be smaller. However, it can never be
    % greater than f_dopler. That is why the vector is then trucated
f_dopler_distribution = makedist('Normal','mu',0,'sigma',f_dopler_max);
f_dopler_distribution = truncate(f_dopler_distribution, ...
    floor(-abs(f_dopler_max)), ceil(abs(f_dopler_max)));
f_dopler = random(f_dopler_distribution,size(A));

% Delays 
delay_maximum_distance = maximum_distance/c;
delay = delay_maximum_distance*rand(size(A));

% Phases
% The phase will be random between -180 and 180
phase = 2*pi*rand(size(A))-pi;

% Axes
time = 0:time_frame:evaluation_time;
frequency = f:subband_bw:f+subband_bw*(number_subbands-1);
[time, frequency] = meshgrid(time, frequency);

% Sum all the cntributions to the channel of the objects, see slide 23
T = zeros(size(time));
for ii = 1:number_objects
    T = T + A(ii)*exp(1j*(2*pi*f_dopler(ii)*time-...
        2*pi*delay(ii)*frequency-phase(ii)));
end

channel = 20*log10(abs(T));
end

