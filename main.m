
%% Plot the user distribution
clear;
speed = 3;                              % Speed of the user(km/h)
f = 5e9;                                % Frequency (GHz)
number_users = 30;
delay_sinr = 2;                         % Frames delay of the sinr
alpha = [0 1 1];
beta = [1 0 1];

throughput = zeros(size(alpha));
allocation_fairness = zeros(size(alpha));
rate_fairness = zeros(size(alpha));

set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,2000,500]);

parfor ii = 1:length(alpha)
   [throughput(ii),  allocation_fairness(ii), rate_fairness(ii), ...
       users_scheduled, time, frequency] = simulate_single_scenario(speed,...
       f, number_users, delay_sinr, alpha(ii), beta(ii));
   
   [time, frequency] = meshgrid(time(300:350), frequency);
   
   subplot(1, length(alpha), ii);
   pcolor(time, frequency, users_scheduled(:, 300:350));
   xlabel('Time (s)');
   ylabel('Frequency (GHz)');
   title(strcat('\alpha = ', num2str(alpha(ii)), ', \beta = ', num2str(beta(ii))));
   colormap winter
   colorbar;
   
   fprintf('For alpha = %i, beta = %i: R = %f Mbps, Fa = %f, Fr = %f\n',...
       alpha(ii), beta(ii), throughput(ii)/1e6, allocation_fairness(ii), ...
       rate_fairness(ii));
end

path = '../Images/';
% saveas(gca, [path, 'comp_scheduled_extreme_alpha_beta'],'epsc');

% Results
% For alpha = 1, beta = 1: R = 193.632763 Mbps, Fa = 0.994008, Fr = 0.616113
% For alpha = 1, beta = 0: R = 399.074764 Mbps, Fa = 0.107724, Fr = 0.107724
% For alpha = 0, beta = 1: R = 134.049322 Mbps, Fa = 0.530265, Fr = 0.992374

%% Plot fairness and throughput for different values of alpha and beta
clear;
speed = 3;                              % Speed of the user(km/h)
f = 5e9;                                % Frequency (GHz)
number_users = 30;
delay_sinr = 2;                         % Frames delay of the sinr
alpha = 0:0.5:4;
beta = 0:0.5:4;

throughput = zeros(length(alpha), length(beta));
allocation_fairness = zeros(length(alpha), length(beta));
rate_fairness = zeros(length(alpha), length(beta));

for ii = 1:length(alpha)
    for jj = 1:length(beta)
        averages = 10;
        for kk = 1:averages
            [throughput_now,  allocation_fairness_now, rate_fairness_now, ~, ~,...
                ~] = simulate_single_scenario(speed, f, number_users, ...
                delay_sinr, alpha(ii), beta(jj));
            throughput(ii, jj) = throughput(ii, jj) + 1/averages*throughput_now;
            allocation_fairness(ii, jj) = allocation_fairness(ii, jj) + ...
                1/averages*allocation_fairness_now;
            rate_fairness(ii, jj) = rate_fairness(ii, jj) + 1/averages*rate_fairness_now;
        end
    end
end

[alpha, beta] = meshgrid(alpha, beta);
set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,2000,500]);

subplot(1, 3, 1);
pcolor(alpha, beta, throughput/1e6);
xlabel('\alpha');
ylabel('\beta');
title('Throughput (Mbps)');
colormap winter
colorbar;

subplot(1, 3, 2);
pcolor(alpha, beta, allocation_fairness);
xlabel('\alpha');
ylabel('\beta');
title('Allocation fairness');
colormap winter
colorbar;

subplot(1, 3, 3);
pcolor(alpha, beta, rate_fairness);
xlabel('\alpha');
ylabel('\beta');
title('Rate fairness');
colormap winter
colorbar;

path = '../Images/';
saveas(gca, [path, 'comp_throughput_fairness_alpha_beta'],'epsc');

%% Compare throughput and fairness for different velocities
% Using only alpha = beta = 1
clear;
speed = 5:5:100;                        % Speed of the user(km/h)
f = 5e9;                                % Frequency (GHz)
number_users = 30;
delay_sinr = 2;                         % Frames delay of the sinr
alpha = 1;
beta = 1;

throughput = zeros(size(speed));
allocation_fairness = zeros(size(speed));
rate_fairness = zeros(size(speed));

for ii = 1:length(speed)
    averages = 10;
    for jj = 1:averages
        [throughput_now,  allocation_fairness_now, rate_fairness_now, ~, ~,...
            ~] = simulate_single_scenario(speed(ii), f, number_users, ...
            delay_sinr, alpha, beta);
        throughput(ii) = throughput(ii) + 1/averages*throughput_now;
        allocation_fairness(ii) = allocation_fairness(ii) + ...
            1/averages*allocation_fairness_now;
        rate_fairness(ii) = rate_fairness(ii) + 1/averages*rate_fairness_now;
    end
end

set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,1500,500]);

subplot(1, 2, 1);
plot(speed, throughput/1e6, 'ok');
xlabel('Speed of the user (km/h)');
ylabel('Throughput (Mbps)');

subplot(1, 2, 2);
plot(speed, allocation_fairness, '*' ); hold on;
plot(speed, rate_fairness, '+'); hold off;
xlabel('Speed of the user (km/h)');
ylabel('Fairness');
legend('Allocation fairness', 'Data-rate fairness', 'Location', 'best');

path = '../Images/';
saveas(gca, [path, 'throughput_fairness_speeds'],'epsc');

%% Compare throughput and fairness for different delays
% Using only alpha = beta = 1
clear;
speed = 3;                        % Speed of the user(km/h)
f = 5e9;                                % Frequency (GHz)
number_users = 30;
delay_sinr = 1:5;                         % Frames delay of the sinr
alpha = 1;
beta = 1;

throughput = zeros(size(delay_sinr));
allocation_fairness = zeros(size(delay_sinr));
rate_fairness = zeros(size(delay_sinr));

for ii = 1:length(delay_sinr)
    averages = 10;
    for jj = 1:averages
        [throughput_now,  allocation_fairness_now, rate_fairness_now, ~, ~,...
            ~] = simulate_single_scenario(speed, f, number_users, ...
            delay_sinr(ii), alpha, beta);
        throughput(ii) = throughput(ii) + 1/averages*throughput_now;
        allocation_fairness(ii) = allocation_fairness(ii) + ...
            1/averages*allocation_fairness_now;
        rate_fairness(ii) = rate_fairness(ii) + 1/averages*rate_fairness_now;
    end
end

set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,800,300]);

subplot(1, 2, 1);
plot(delay_sinr, throughput/1e6, 'ok');
xlabel('SINR feedback delay (frames)');
ylabel('Throughput (Mbps)');

subplot(1, 2, 2);
plot(delay_sinr, allocation_fairness, '*' ); hold on;
plot(delay_sinr, rate_fairness, '+'); hold off;
xlabel('SINR feedback delay (frames)');
ylabel('Fairness');
legend('Allocation fairness', 'Data-rate fairness', 'Location', 'best');

path = '../Images/';
saveas(gca, [path, 'throughput_fairness_delays'],'epsc');

%% Compare throughput and fairness for different frequencies
% Using only alpha = beta = 1
clear;
speed = 3;                        % Speed of the user(km/h)
f = [2.11 1.93 1.805 0.869 0.12 0.045 1.845 1.92 1.45 5.15 2.49]*1e9;
f = sort(f);                      % Frequency (Hz)
number_users = 30;
delay_sinr = 2;                         % Frames delay of the sinr
alpha = 1;
beta = 1;

throughput = zeros(size(f));
allocation_fairness = zeros(size(f));
rate_fairness = zeros(size(f));

for ii = 1:length(f)
    averages = 10;
    for jj = 1:averages
        [throughput_now,  allocation_fairness_now, rate_fairness_now, ~, ~,...
            ~] = simulate_single_scenario(speed, f(ii), number_users, ...
            delay_sinr, alpha, beta);
        throughput(ii) = throughput(ii) + 1/averages*throughput_now;
        allocation_fairness(ii) = allocation_fairness(ii) + ...
            1/averages*allocation_fairness_now;
        rate_fairness(ii) = rate_fairness(ii) + 1/averages*rate_fairness_now;
    end
end

set(0, 'DefaultAxesFontName', 'Times New Roman');
figure('Color',[1 1 1]);
set(gcf,'position',[100,100,1500,500]);

subplot(1, 2, 1);
plot(f/1e9, throughput/1e6, 'ok');
xlabel('Frequency (GHz)');
ylabel('Throughput (Mbps)');

subplot(1, 2, 2);
plot(f/1e9, allocation_fairness, '*' ); hold on;
plot(f/1e9, rate_fairness, '+'); hold off;
xlabel('Frequency (GHz)');
ylabel('Fairness');
legend('Allocation fairness', 'Data-rate fairness', 'Location', 'best');

path = '../Images/';
saveas(gca, [path, 'throughput_fairness_frequency'],'epsc');