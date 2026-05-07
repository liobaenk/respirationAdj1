function intensity = electric_test_stimuli(intensity, nr_stim, aio_s, trig_s)%%% Test script for DAQ card

%% LPT port
srate = 1000; % sampling rate of EEG; !!! NEEDS TO BE ADJUSTED !!!
trigger_length = 2/srate;
port = 19456; %LPT-Port;
%lptwrite(port,0); % set port to 0


%%

% stimuli
int_tmp = intensity;
ttl_dur = 1; % duration of ttl wave; in ms
% parameters of rectpulse2: duration, intensity, sampling rate, ... 
% duration of before stimulus (rectangular pulse) in ms, waveform duration

[stim_wave_test, offset] = rectpulse2(0.2, 1, aio_s.Rate, 1, 3);
[ttl_wave, ttl_offset] = rectpulse2(ttl_dur, 5, aio_s.Rate, 1, 3);
ISI_3 = 0.200; % last stimulus (triggered through LPT port) 200ms after begin of DAQ card

%%
step_increase = 0.05;
t_start_trial = GetSecs()

for i = 1:nr_stim;
    int_tmp = int_tmp + step_increase; % 3.5;
    disp(i)
    disp(int_tmp)
    
    % Buffer waveform
    stop(aio_s);    
    queueOutputData(aio_s,[stim_wave_test*int_tmp ttl_wave]);
    
    % Takes ~150 ms
    tic
    startBackground(aio_s);
    toc
    WaitSecs(0.5);            
       
    % Start analog output (triggers waveform immediately)
    try
        outputSingleScan(trig_s,0)
        outputSingleScan(trig_s,1)
        outputSingleScan(trig_s,0)
    catch lasterr
        disp(['Trial ', num2str(i), ': ', lasterr.message]);
        data.ao_error(i,1) = 1;
        stop(aio_s);
    end
        
    WaitSecs(1.5);
end


% % simplest code (one trial):
% int_ttl = 1.85; %1.85; %3.3; % minimum pulse level for NeurOne 3.3V
% ttl_dur = 6;
% ttl_wave = rectpulse2(ttl_dur, 1, aio_s.Rate, 10, 210) * int_ttl;
% stop(aio_s);
% queueOutputData(aio_s, [zeros(size(ttl_wave)), zeros(size(ttl_wave)), zeros(size(ttl_wave)), ttl_wave]);
% startBackground(aio_s)
% outputSingleScan(trig_s,0)
% outputSingleScan(trig_s,1)
% outputSingleScan(trig_s,0)


