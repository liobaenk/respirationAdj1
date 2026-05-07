function [btn,onset] = show_instr_img_thr1F(instr_images,window,thr1F)
% [btn,onset] = show_instr_img(instr_images,window,lpt) displays 
% sequentially all instruction images in the structure instr_images. It
% returns the flip onset times (onset) and the pressed buttons (btn.n) as
% well as the response time (btn.t).
%
% It requires an open window.
%
% Author:           Martin Grund
% Last update:      November 20, 2017
addpath ='E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp\assets\func';
% Prepare output variables
onset = cell(length(instr_images),5);
btn.n = zeros(length(instr_images),1);
btn.t = btn.n;

for i = 1:length(instr_images)
    img_texture = Screen('MakeTexture',window,instr_images{i});
    Screen('DrawTexture',window,img_texture);
    [onset{i,:}] = Screen('Flip',window);    
    Screen('Close',img_texture);
    
    % Wait for button press
%     [btn.n(i),btn.t(i),btn.port(i,:)] = parallel_button(inf,onset{i,1},'variable',0.025,lpt);
    [btn.n(i),btn.t(i)] = register_button_press(0,Inf, thr1F.btn, thr1F.s_port, thr1F.lpt_adr1 ,thr1F.trigger_length);
 
end

% Blank screen after last button press
[onset{i,:}] = Screen('Flip',window);