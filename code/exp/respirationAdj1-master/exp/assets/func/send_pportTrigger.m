function send_pportTrigger(ioObj,pport_address,triggerCode)
% sends trigger, should be called AFTER setup_pportTrigger().m!

% Calling io64() with three input parameters allows the user to output data 
% to the specified I/O port address.  object is the handle to an io64 object 
% (described above); address specifies the physical address of the 
% destination I/O port (<64K); and, data represents the value (between 0-255) 
% being output to the I/O port.
% http://apps.usd.edu/coglab/psyc770/IO64.html
%
% Input (for psychophysiology lab, Trafford Centre, BSMS Brighton)
% ioObj             = io64
% pport_address     = 888
% address           = hex2dec(num2str(888)); computed via
%                     setup_pportTrigger().m
% triggerCode       = 255 %turns all on
%
% Author:       Lioba Enk
% Last update:  08 July, 2022

% Modified by Busra Cilburunoglu
% Last update: 16 Oct, 2025

%  initialize the interface to the inpoutx64 system driver
status = io64(ioObj);

%pport_address = hex2dec('D010');

data_out = triggerCode;
io64(ioObj,pport_address,data_out); % send a signal

WaitSecs(0.001); 

data_out = 0;
io64(ioObj,pport_address,data_out); % stop sending a signal

end
