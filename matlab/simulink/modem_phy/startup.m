addpath('./');
hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath','/media/fpgaws/installation/vitis/Vivado/2020.1/bin')
uiopen('./combinedTxRx.slx',1)
% set_param('RxTxFixedPointLibrary','Lock','off');