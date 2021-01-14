% ----------------------------------------------------------------------- %
%   fetchYmaData() - This function fetches the current almanac data for   %
%   the given day. It calculates the current day of the year and reads    %
%   date from the 2nd Spce Operation Squadron website:                    %
%                   https://gps.afspc.af.mil/gps/archive/                 %
%                                                                         %
% ----------------------------------------------------------------------- %
%               Created by Kurt Pedrosa  -- May 18th 2017                 %
% ----------------------------------------------------------------------- %
function full_almanac_data = fetchYumaData()
    % Get day of the year
    % Note: calculation of day of the year sometime throws an error
    %   because it increases the current day faster than the website.
    current_date = clock;
    year = current_date(1);
    day_of_year = floor( now - datenum( year, 1, 0, 0, 0, 0 ));
    fprintf('Today is day number %d of the year %d.\n',  day_of_year, year );
    % print a empty line for spacing
    fprintf('\n');

    % Load the data 
    file_type = '.alm';
    file_name = strcat(num2str( day_of_year ), file_type );

    if exist( file_name, 'file') == 0
        disp('Almanac data is NOT available.');
        fprintf('\n');
    elseif exist( file_name , 'file' ) == 2
        disp('Checking YUMA data for presence of 32 satellite vehicles.');
        % print a empty line for spacing
        fprintf('\n');
        data_not_formated = ExtractData( file_name );

        % Ensure that all 32 SVs are accounted for.
        % If 32 SVs not present, then create a dummy data for the missing SVs
        % Dummy date includes decimal values of alternatind one's and zero's
        dummy_data =...
        [ 63 0.0208330154418945 696320 4.18879020381111 4.99335085024861e-07 ...
          5461.3330078125 0 4.18878995511504 4.18878995511504 ...
          0.00130176544189453 4.96584107168019e-09 ];

        if size( data_not_formated, 1 ) ~= 32
            numb_of_columns = size( data_not_formated, 2 );
            data_column_temp = [];
            for count_columns = 1:numb_of_columns
                data_column_temp = [ data_column_temp 0 ];
            end
            data_temp = [ data_not_formated ; data_column_temp ];
        end

        for count_index = 1:32
            find_result = find( data_temp( :, 1 ) == count_index );
            if isempty( find_result )
                data_temp =...
                    [ data_temp( 1:count_index-1, :);...
                    [ count_index dummy_data ];...
                    data_temp( count_index:end-1, :) ];
                    count_index = 1;
            end
        end

        disp('Done. Almanac data is now available.');
        % print a empty line for spacing
        fprintf('\n');

        full_almanac_data = data_temp;
    else
        error('Check fetchYumaData() for error. Almanac file existance is not defined.');
    end
end

% ----------------------------------------------------------------------- %
%   ExtractData() - This function takes in a file, reads through the file %
%   extracting the data for each satellite and storying it into an array  %
%                                                                         %
%       Important: A YUMA almanac file expected                           %
% ----------------------------------------------------------------------- %
%               Created by Kurt Pedrosa  -- May 18th 2017                 %
% ----------------------------------------------------------------------- %
function all_sv_data = ExtractData( almanac_file )
    all_sv_data = [];
    % Open file
    file_id = fopen( almanac_file );

    % Read file
    current_line = fgetl( file_id );
    while ~feof( file_id )
        % If current line is the SV ID start saving info
        if strfind( current_line, 'ID')
            id = ParseValueInCurrentLine( current_line );
            sv_data =  id ;
            current_line = fgetl( file_id ); % Go to next line
            % Get health
            if strfind( current_line, 'Health')
                health = ParseValueInCurrentLine( current_line );
                sv_data = [ sv_data health ];
                current_line = fgetl( file_id ); % Go to next line
                % Get Eccentricity
                if strfind( current_line, 'Eccentricity' )
                    eccentricity = ParseValueInCurrentLine( current_line );
                    sv_data = [ sv_data eccentricity ];
                    current_line = fgetl( file_id );
                    % Get Time of Applicability
                    if strfind( current_line, 'Time of Applicability')
                        time_of_app = ParseValueInCurrentLine( current_line );
                        sv_data = [ sv_data time_of_app ];
                        current_line = fgetl( file_id );
                        % Get Orbital Inclination
                        if strfind( current_line, 'Orbital Inclination' )
                            orbital_incl = ParseValueInCurrentLine( current_line );
                            sv_data = [ sv_data orbital_incl ];
                            current_line = fgetl( file_id );
                            % Get Rate of Right Ascen
                            if strfind( current_line, 'Rate of Right Ascen')
                                rate_of_right_ascen = ParseValueInCurrentLine( current_line );
                                sv_data = [ sv_data rate_of_right_ascen ];
                                current_line = fgetl( file_id );
                                % Get SQRT(A)
                                if strfind( current_line, 'SQRT(A)')
                                    sqroot_a = ParseValueInCurrentLine( current_line );
                                    sv_data = [ sv_data sqroot_a ];
                                    current_line = fgetl( file_id );
                                    % get Right Ascen at Week
                                    if strfind( current_line, 'Right Ascen at Week')
                                        ascen_at_week = ParseValueInCurrentLine( current_line );
                                        sv_data = [ sv_data ascen_at_week ];
                                        current_line = fgetl( file_id );
                                        % Get Argument of Perigee
                                        if strfind( current_line, 'Argument of Perigee')
                                            arg_perigee = ParseValueInCurrentLine( current_line );
                                            sv_data = [ sv_data arg_perigee ];
                                            current_line = fgetl( file_id );
                                            % Get Mean Anom
                                            if strfind( current_line, 'Mean Anom')
                                                mean_anom = ParseValueInCurrentLine( current_line );
                                                sv_data = [ sv_data mean_anom ];
                                                current_line = fgetl( file_id );
                                                % Get Af0
                                                if strfind( current_line, 'Af0' )
                                                    af0 = ParseValueInCurrentLine( current_line );
                                                    sv_data = [ sv_data af0 ];
                                                    current_line = fgetl( file_id );
                                                    if strfind( current_line, 'Af1')
                                                        af1 = ParseValueInCurrentLine( current_line );
                                                        sv_data = [ sv_data af1 ];
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            % Complie all the data into one array
            % Referenced by SV ID as the first element on each row
            all_sv_data = [ all_sv_data; sv_data ];
        end
        current_line = fgetl( file_id );
    end

    fclose( file_id );
end

% ----------------------------------------------------------------------- %
%   ParseValueInCurrentLine() - This function takes in the current line   %
%   being read and finds the value at the end-of-the-line. For example    %
%   ID:             32          will return the number 32                 %
%   SQRT(A)  (m 1/2)            5153.687012  will return 5153.687012      %
%                                                                         %
%       Important: A YUMA almanac file expected                           %
% ----------------------------------------------------------------------- %
%               Created by Kurt Pedrosa  -- May 18th 2017                 %
% ----------------------------------------------------------------------- %
function parsed_value = ParseValueInCurrentLine( current_line )
    for count_char = 0:length( current_line ) - 1
        if strcmp( current_line( end-count_char ), ' ' )
            parsed_value = str2double( current_line( end - ( count_char - 1 ):end )) ;
            break;
        end
    end
end
