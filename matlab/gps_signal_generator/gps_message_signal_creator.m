% ----------------------------------------------------------------------- %
%                       GPS Message Signal Creator                        %
%                                                                         %
%   Description: This file creates the message signal and populates the   %
%       appropriate registers in the ROACH.                               %
%                                                                         %
%   Created by Kurt Pedross                                               %
%       Jan 12th 2017   - ERAU Spring 2017                                %
%   Edited by HosseinBeheshti                                             %
%       Dec 3th 2020                                                      %
% ----------------------------------------------------------------------- %

clc
clear
% Select the SV
sv_1 = 9;
sv_2 = 15;
sv_3 = 23;
sv_4 = 30;

selected_bit_sv1 = SelectSatellite( sv_1 );
selected_bit_sv2 = SelectSatellite( sv_2 );
selected_bit_sv3 = SelectSatellite( sv_3 );
selected_bit_sv4 = SelectSatellite( sv_4 );

% Create Message Data
message_signal = CreateMessageData(sv_1);
