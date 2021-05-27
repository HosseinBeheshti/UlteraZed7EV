close all;
clc;
clear;
simulation_time = 1e-4;
%% load log data
load_data_en = 1;
if load_data_en == 1
    fid=fopen('../../log_data/BladeRF_Bands-L1.int16');
    x=fread(fid,2e5,'int16');
    fclose(fid);
end
%% Core initialize parameters
fs = 120e6;
ts = 1/fs;
input_signal_width = 4;
input_signal_binary_point = 3;
quantized_input = double(fi(x.*2^(input_signal_binary_point-15),1,input_signal_width,input_signal_binary_point))';
input_signal = [0:ts*12:ts*12*(length(x)-1); quantized_input]';
DDS_phase_width = 16;
DDS_signal_width = 16;
fc = randi([1 50],1,12)./10;
DDS_ch_pinc = fc.*(2^(DDS_phase_width)/fs);
multiplier_width = input_signal_width + DDS_signal_width;
multiplier__point = multiplier_width - 1;





