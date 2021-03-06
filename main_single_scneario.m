clear;
% Variable declaration: definition of the environment
% Definition of the channel
number_objects = 10;                    % Number of objects
speed = 3;                              % Speed of the user(km/h)
f = 5e9;                                % Frequency (GHz)
c = 3e8;                                % Speed of light
maximum_distance = 10;                  % The maximum delay comes from 10 m
% Definition of time and frequency axes
time_frame = 3e-3;                      % (s)
evaluation_time = 30;                   % (s)
subband_bw = 640e3;                     % (Hz)
number_subbands = 114;
% Definition of the envirnment
number_users = 30;
max_distance = 1000;                    % (m) max distance to base station
% Definition of the station parameters
tx_power = 44;                          % Maximum transmitted power (dBm)
tx_gain = 14;                           % (dB)
rx_gain = 0;                            % (dB)
rx_noise_figure = 9;                    % (dB)
thermal_noise = -174;                   % (dBm/Hz): kt
Interference = 20;                      % dB
% Definition of the simulation parameters
delay_sinr = 2;                         % Frames delay of the sinr
Nt = 100;                               % Frames to evaluate the assigned resources
alpha = 1;
beta = 1;

% Create all the parameters of each user:
% Distance to the base terminal
% Achievable bit-rate at each instant
users = [];
for ii = 1:number_users
    % Each user is at a given distance
    users(ii).distance = max_distance*rand(1);
    
    % Each user has a random changing channel
    channel = generateChannel(number_objects, speed, f, c, ...
        maximum_distance, time_frame, evaluation_time, subband_bw, ...
        number_subbands);
    % Each channel has an offset depending on the antenna parameters and
    % the distance
    sinr = calculateSINR(channel, tx_power, ...
        tx_gain, rx_gain, users(ii).distance, rx_noise_figure, ...
        thermal_noise, subband_bw, number_subbands, Interference); 
    users(ii).bit_rate = obtainBitRate(sinr,subband_bw);
    
    time = 0:time_frame:evaluation_time;
    users(ii).Rm = zeros(size(time));
    users(ii).DRC_prime = zeros(1, Nt);
    users(ii).Pm = zeros(size(users(ii).bit_rate));
    % All users start with Rm (1) = 1 so that there is n division by 0 in
    % the execution of the code
    users(ii).Rm(1) = 1;                    
end

frequency = f:subband_bw:f+subband_bw*(number_subbands-1);

%% The system is run all the given time
% The loop starts at 2 because at 1 there is no result about the DRC'. For
% t = 1, the assignment is done before the loop
% The for loop stops before the end because the system bit rate obtaines
% is the one seen after the decission is made.
users_scheduled = zeros(length(frequency), length(time));
% It is created a vector that saves the trhoughput of each user separatedly
user_throughput = zeros(1, number_users);

for tt = 2:length(time)-delay_sinr
    
    % #1: Compute Rm[n] and Pm for all users and subbands
    % The results at this given time are stored in all Pm tt
    all_Pm_tt = zeros(number_users, number_subbands); 
    for ii = 1:number_users
        users(ii).Rm(tt) = (1-1/Nt)*users(ii).Rm(tt-1) + ...
                            1/Nt*sum(users(ii).DRC_prime);
        users(ii).Pm(:, tt) = (users(ii).bit_rate(:, tt)*time_frame).^alpha / ...
                            (users(ii).Rm(tt))^beta;
        all_Pm_tt(ii,:) = users(ii).Pm(:, tt);
    end
    
    % #2: Calculate m* per subband
    % In m_asterisk_s are stored the users which are schedules at each
    % subband at the moment tt
    [~,m_asterisk_s] = max(all_Pm_tt);
    users_scheduled(:, tt) = m_asterisk_s;
    
    % #3: Refresh DRC'(m): For all the frequency subands it is looked for
    % the user selected and then it is updated the drc. It is possible that
    % a user is selected more than once. That is why the DRCs are added in
    % new_DRC_prime and then are updated.
    new_DRC_prime = zeros(1, number_users);
    for ff = 1:number_subbands
        user_selected = m_asterisk_s(ff);
        new_DRC_prime(user_selected) = new_DRC_prime(user_selected)+...
                users(user_selected).bit_rate(ff, tt+delay_sinr)*time_frame;
    end
    for ii = 1:number_users
        users(ii).DRC_prime = [new_DRC_prime(ii) users(ii).DRC_prime(1:end-1)];
    end
    
    % It is also refreshed the bitrate
    user_throughput = user_throughput + new_DRC_prime; 
end
%% Calculate the fairness and throughput

% Throughput
throughput = sum(user_throughput) / evaluation_time;
fprintf('Throughput = % f Mbps\n', throughput/1e6);

% Allocation fairness
users_edges = (0:number_users)+0.5;  % Users edges to be casified in the histogram
resource_assigned_user = histcounts(users_scheduled, users_edges);

numerator_allocation_fairness = sum(resource_assigned_user)^2;
denominator_allocation_fairness = number_users * sum(resource_assigned_user.^2);
allocation_fairness = numerator_allocation_fairness/denominator_allocation_fairness;
fprintf('Allocation fariness = % f\n', allocation_fairness);

% Data rate fairness
numerator_rate_fairness = throughput^2;
denominator_rate_fairness = number_users * sum((user_throughput/evaluation_time).^2);
rate_fairness = numerator_rate_fairness / denominator_rate_fairness;
fprintf('Data-rate fariness = % f\n', rate_fairness);







