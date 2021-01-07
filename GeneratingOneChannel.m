% This script generates one channel without considering the distance to the
% base station

number_objects = 10;                    % Number of objects

% Amplitude
A = rand(1, number_objects);

% Dopler shifts
speed = 3;                              % Speed (km/h)
speed = speed*1000/3600;                % Speed (m/s)
f = 5e9;                                % Frequency (GHz)
c = 3e8;                                % Speed of light
f_dopler_max = f*(c+speed)/c - f;           % Dopler frequency (Hz)
    % The dopler vector will contain all the dopler shifts. This shifts can
    % be positive or negative: if the signal is direct, the user may be
    % going away from the base (negative) or going towards the base
    % (positive). It is also possible that the signal is not direct. That
    % is why the dopler seen can be smaller. However, it can never be
    % greater than f_dopler. That is why the vector is then trucated
f_dopler_distribution = makedist('Normal','mu',0,'sigma',f_dopler_max);
f_dopler_distribution = truncate(f_dopler_distribution, ...
    round(-f_dopler_max), round(f_dopler_max));
f_dopler = random(f_dopler_distribution,size(A));

% Delays 
% The maximum delay will come from a building at 10 m
maximum_distance = 10;
delay_maximum_distance = maximum_distance/c;
delay = delay_maximum_distance*rand(size(A));

% Phases
% The phase will be random between -180 and 180
phase = 360*rand(size(A))-180;

% Axes
% The time frame is 3 ms, and I want 30 s
time_frame = 3e-3;                      % (s)
evaluation_time = 1;                   % (s)
time = 0:time_frame:evaluation_time;
% The subband bw is 640 kHz and there are 114 subbands
subband_bw = 640e3;
number_subbands = 114;
frequency = f:subband_bw:f+subband_bw*number_subbands;

[time, frequency] = meshgrid(time, frequency);

% Sum all the cntributions to the channel of the objects, see slide 23
T = zeros(size(time));
for ii = 1:number_objects
    T = T + A(ii)*exp(1j*(2*pi*f_dopler(ii)*time-...
        2*pi*delay(ii)*frequency-phase(ii)));
end

% Plot all the channel
set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,2000,700]);

subplot(1, 2, 1);
surf(time, frequency, 20*log10(abs(T)));
xlabel('Time');
ylabel('Frequency');
zlabel('Amplitude');
colormap winter
colorbar;

subplot(1, 2, 2);
pcolor(time, frequency, 20*log10(abs(T)));
xlabel('Time');
ylabel('Frequency');
colormap winter
colorbar;

path = '../Images/';
% saveas(gca, [path, 'one_channel'],'epsc');