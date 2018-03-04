%% Clear start
clearvars -except MeasFile; 

%% Path and directory preparation

path_split    = strsplit(cd,'\');                           	% Path of the current directory
Data_Path	  = [strjoin(path_split,'\'),'\Data\'        ]  ;   % Path of the input mat file(s)
addpath(genpath([strjoin(path_split,'\'),'\Subfunctions\']));   % Add the directory contating the sub-functions

%% Filename, Anfangszeitpunkt und Endeszeitpunkt

Filename    = 'Example_File';
Firstpoint  = datetime('01.07.2017 00:00:00','InputFormat','dd.MM.yyyy HH:mm:ss','Format','dd.MM.yyyy HH:mm:ss','TimeZone','Europe/Berlin');
Last_point  = datetime('30.07.2017 00:00:00','InputFormat','dd.MM.yyyy HH:mm:ss','Format','dd.MM.yyyy HH:mm:ss','TimeZone','Europe/Berlin');
step_In_min = 2;

%% Data loading

% if ~exist('MeasFile','var')
    data     = load([Data_Path,Filename]);
    MeasFile = data.(cell2mat(fields(data))); % Measurement file
    clear data                                % For Memory reasons delete this
% end

%% Function of filling the table with missing rows
Adjusted_MeasFile = adjust_measurement_file(MeasFile, Firstpoint, Last_point, step_In_min);

%% Some nice to have (RB)

Adjusted_MeasFile.chf01.time_hour = ...
    datetime(...
    year(Adjusted_MeasFile.chf01.Timestamp),...
    month(Adjusted_MeasFile.chf01.Timestamp),...
    day(Adjusted_MeasFile.chf01.Timestamp),...
    hour(Adjusted_MeasFile.chf01.Timestamp),...
    0,  ...
    0   ...
    );

varfun(@mean,Adjusted_MeasFile.chf01,'InputVariables','HA_F_L1_Hz','GroupingVariables','time_hour')
