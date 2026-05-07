function [resp_button, resp_time] = register_button_press(t_stim, ISI_task, serial_port_buttons, s_port, port2, trigger_length)
% Register behavioral responses either by button box or keyboard
% Detailed explanation goes here
%From Rosa
resp_button = 0; resp_time = NaN; % initialize output arguments
[~,~,~] = IOPort('Read', s_port); % flush button presses from previous trial

while GetSecs - t_stim < (ISI_task)

    if serial_port_buttons
        [button, when, errmsg] = IOPort('Read', s_port);
        if ~isempty(button)
            if button(end) == 1
                %disp('Button 1')
                %lptwrite(port2, 1); WaitSecs(trigger_length); lptwrite(port2, 0); % set port to zero again
                %parPulse(port2, 1, 0, 255, trigger_length, 1);
                send_pportTrigger(io64, hex2dec('D010'), 200);
                resp_button = 1; % target button
                resp_time = when - t_stim;
                WaitSecs(0.001)
                %WaitSecs('UntilTime', t_stim + ISI_task); % don´t allow another button registration
                break
            elseif button(end) == 2
                %disp('Button 2')
                %lptwrite(port2, 2); WaitSecs(trigger_length); lptwrite(port2, 0); % set port to zero again
                %parPulse(port2, 2, 0, 255, trigger_length, 1);
                send_pportTrigger(io64, hex2dec('D010'), 210);
                resp_button = 2; % standard button
                resp_time = when - t_stim;
                WaitSecs(0.001)
                %WaitSecs('UntilTime', t_stim + ISI_task); % don´t allow another button registration
                break
            elseif find(keyCode==1) == 27 % if ESC has been pressed
                resp_button = 27;
                break % stop sequence
            end
        end
    end

    [keyIsDown, secs, keyCode, ~]  = KbCheck(); % check for button press
    if keyIsDown
        if ~serial_port_buttons
            if find(keyCode==1) == 37 % left arrow
                %lptwrite(port2, 1); WaitSecs(trigger_length); lptwrite(port2, 0); % set port to zero again
                resp_button = 1; % target button
                resp_time = secs - t_stim;
                WaitSecs('UntilTime', t_stim + ISI_task); % don´t allow another button registration
                break

            elseif find(keyCode==1) == 39 % right arrow
                %lptwrite(port2, 2); WaitSecs(trigger_length); lptwrite(port2, 0); % set port to zero again
                resp_button = 2; % standard button
                resp_time = secs - t_stim;
                WaitSecs('UntilTime', t_stim + ISI_task); % don´t allow another button registration
                break

            elseif find(keyCode==1) == 27 % if ESC has been pressed
                resp_button = 27;
                break % stop sequence
            end

        elseif find(keyCode==1) == 27 % if ESC has been pressed
            resp_button = 27;
            break % stop sequence
        end
    end
end

end

