function message_data = CreateMessageData( sv_selected )

% Defined here for sanity.
hours_in_day = 24;
minutes_in_hour = 60;
seconds_in_hour = 60;
days_in_week = 7;

message_data = [];

persistent full_almanac_data;

% Define gps_epoch
%   GPS reference time defined by zero time-point as midnight of the
%       night of Jan 5 1980 / morning of Jan 6 1980
gps_epoch = [ 1980 1 6 00 00 00.000 ]; % Jan 6 1980 00:00:00.000

% GPS is referenced to Coordinate Universal Time (UTC)
%   Using the now() so there must be a EST correction on the calculation
correction_EST = 4/24;

% Define the current gps week ( float number )
gps_week = (( now + correction_EST ) - datenum( gps_epoch ))/7;

% Round gps_week to get the true ( int ) gps week.
%   Check the website below for testing these calculations.
%   https://www.labsat.co.uk/index.php/en/gps-time-calculator
true_gps_week = floor( gps_week ); % integer number

% Define GPS one week ( in seconds )
%   This is the largest unit used in stating GPS time.
%   1 week = 604,800 seconds
gps_seconds_of_week = ...
    floor((( gps_week - true_gps_week )*hours_in_day*minutes_in_hour*seconds_in_hour*days_in_week));

% Define Week number for Subframe 1 Word 3
% This is a 10-bit modulo 1024 representatino of the current GPS week number
transmission_week_number_temp = str2bin_array( dec2bin( mod( true_gps_week, 1024 )));
if length( transmission_week_number_temp ) <10
    transmission_week_number = [zeros(1, 10-length( transmission_week_number_temp )), transmission_week_number_temp];
end

% Prepare Yuma almanac data
full_almanac_data = prepareYumaData();
% Define the SV Health array and populate it with Almanac health data
full_sv_health_data = full_almanac_data( : , 1:2 );

    % Index the selected SV.
    index_selected_sv = find( full_almanac_data == sv_selected );
    
    % Create message data
    temp_message_data = [];
    for count_pages = 1:25
        if count_pages == 1
            subframe_1 = GenerateSubframe1( ...
                transmission_week_number,...
                str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
                full_almanac_data( index_selected_sv, 2 ),...
                full_almanac_data( index_selected_sv, 11 ),...
                full_almanac_data( index_selected_sv, 12 ),...
                [ 0 0 ]);
        else
            subframe_1 = GenerateSubframe1( ...
                transmission_week_number,...
                str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
                full_almanac_data( index_selected_sv, 2 ),...
                full_almanac_data( index_selected_sv, 11 ),...
                full_almanac_data( index_selected_sv, 12 ),...
                subframe_5( 10, 29:30 ));
        end
        
        subframe_2 = GenerateSubframe2( ...
            str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
            full_almanac_data( index_selected_sv, 10 ),...
            full_almanac_data( index_selected_sv, 3 ),...
            full_almanac_data( index_selected_sv, 7 ),...
            subframe_1( 10, 29:30 ));
        
        subframe_3 = GenerateSubframe3( ...
            str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
            full_almanac_data( index_selected_sv, 5 ),...
            full_almanac_data( index_selected_sv, 9 ),...
            full_almanac_data( index_selected_sv, 6 ),...
            subframe_2( 10, 29:30 ));
        
        subframe_4 = GenerateSubframe4( ...
            count_pages,...
            str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
            true_gps_week,...
            full_almanac_data( index_selected_sv, 4 ),...
            full_sv_health_data( :, 2 ),...
            full_almanac_data,...
            subframe_3( 10, 29:30 ));
        
        subframe_5 = GenerateSubframe5( ...
            count_pages, full_almanac_data( count_pages, : ),...
            full_sv_health_data( :, 2 ), true_gps_week,...
            str2bin_array( GetHOWTimeWeek( gps_seconds_of_week + ( 6*count_pages - 6) )),...
            subframe_4( 10, 29:30 ));
        
        temp_message_data = [ temp_message_data;...
            subframe_1;...
            subframe_2;...
            subframe_3;...
            subframe_4;...
            subframe_5 ];
    end
    message_data = temp_message_data;

fprintf('Message data for satelitte %d has been generated.\n', sv_selected );

end


function handover_word_TOW = GetHOWTimeWeek( gps_seconds_of_week )

% Guard the range of gps_seconds_of_week.
%   It can only be between 0 - 604,799;
if gps_seconds_of_week < 0
    error('GPS Seconds cannot be a negative number. Check calculation.');
elseif gps_seconds_of_week > 604799
    gps_seconds_of_week = gps_seconds_of_week - 604799;
end
% Count how many 1.5 seconds have occured in the gps_seconds_of_week
%   Reference the Figure 3-16 Time Line Relationship of HOW message
% This number maybe be a float or an int but it must be between
% 0 - 403,199
% actual_TOW_count is a 19 binary number equivalent to the count of
%       1.5 seconds in the gps_seconds of the week.
%
%   gps_seconds_of_week range 0 - 604,799 ( 604800 seconds total )
%   actual_TOW_count range 0 - 403,199 ( 403,200 count total )
actual_TOW_count = dec2bin( gps_seconds_of_week/1.5 , 19);

% Handover word time of week count ( HOW TOW ) is defined as
%   the 17 MSB of the actual_TOW_count.
% However, the HOW TOW is always 1 more than the actual_TOW_count, Meaning
%       actual_TOW_count = 0        --->  HOW TOW = 1
%       actual_TOW_count = 403,196  --->  HOW TOW = 0
%       actual_TOW_count = 403,192  --->  HOW TOW = 100,7999
%                           See Figure 3-16
how_tow_adjusted = bin2dec( actual_TOW_count( 1:17 )) + 1;

% Account for the 0 decimal equivalent of how-message tow Counts
if how_tow_adjusted == 100800
    handover_word_TOW = ConvertHowTow2Bin( 0 );
else
    handover_word_TOW = ConvertHowTow2Bin( how_tow_adjusted );
end
end


function handover_TOW_binary = ConvertHowTow2Bin( handover_word_TOW )
% Check again if handover_word_TOW is between 0 and 100,799
if handover_word_TOW > 0 && handover_word_TOW < 100800
    % Value must be a 17 bit number
    handover_TOW_binary = dec2bin( handover_word_TOW, 17 );
else
    error('Invalid Handover Word Time of Week Decimal. Check conversion to binary.');
end
end
