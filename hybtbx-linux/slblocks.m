function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
blkStruct.Name = 'Hybrid Toolbox';

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
%           blkStruct.OpenFcn = 'ExampleTF=tf([1 0],[1 1]);cstblocks;';%.mdl file
blkStruct.OpenFcn = 'hyblib';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
%           blkStruct.MaskDisplay = 'disp(''LTI'')';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'hyblib';
Browser(1).Name    = 'Hybrid Toolbox (v1.0)';
 
blkStruct.Browser = Browser;
