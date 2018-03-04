function out_struct = adjust_measurement_file(in__struct, Firstpoint, Lastpoint, step_In_min)
%ADJUST_MEASUREMENT_FILE Adjust the measurement file 'in__struct' in
%regards to the period defined by Firstpoint, Lastpoint and step_In_min and
%save the resulting adjusted measurement file 'out_struct'.

%% Main
fields_names    = fields(in__struct);                           % fields (tables) in input struct
ideal_Tvec(:,1) = Firstpoint:minutes(step_In_min):Lastpoint; 	% ideal time vector: column of timestamp with all timepoints
out_struct      = in__struct;                                   % initial out_struct (resulting measurement file)                                
% Over all fields (tables)
for k_f = 1 : numel(fields_names)                           	% k_f - k_field (k_table) of struct
    k_f_table    = out_struct.(fields_names{k_f});           	% k_field of struct -> table
    column_names = k_f_table.Properties.VariableNames;
    column_class = cell(numel(column_names),1);                 % initial column class vector
    % Get the class for all columns
    for k_c = 1 : numel(column_names)                       	% k_c - k_column of field
        column_class{k_c,1} = ...
            class(k_f_table.(column_names{k_c}));
    end
    columns__to_del = column_names(~ismember(column_class,{'datetime','double',}));  % name of not 'datetime' and not 'double' columns
    columns__double = column_names( ismember(column_class,{'double', }));            % name of 'double' columns
    column_datetime = column_names( ismember(column_class,{'datetime'}));            % name of 'datetime' columns
    % delete not double or datetime columns
    for k_c = 1 : numel(columns__to_del)                                             % k_c - k_column of field
        k_f_table.(columns__to_del{k_c}) = [];
    end
    real__Tvec = k_f_table.(cell2mat(column_datetime)); 	                         % real time vector
    % if some timestamps occure more than once, delete them
    if numel(unique(real__Tvec)) ~= numel(real__Tvec)       
        [~, pos_unique] = unique(real__Tvec);
        k_f_table       = k_f_table (pos_unique,:);
        real__Tvec      = real__Tvec(pos_unique);
    end
    pos__real2ideal = ismember(ideal_Tvec,real__Tvec);      % position of real  in ideal time vector
    pos_ideal2_real = ismember(real__Tvec,ideal_Tvec);      % position of ideal in real  time vector
    num_Variables   = numel(columns__double);               % number of double-variables in the table
    num_TimeSteps   = numel(ideal_Tvec);                    % number of time steps
    Final_Table     = array2table(NaN(...                   % Initial (final) table filled with NaN elements
        num_TimeSteps ,...
        num_Variables + 1),...                              % all double-variables + datetime
        'VariableNames',...
        [column_datetime, columns__double]);
    Final_Table.(column_datetime{:}) = ideal_Tvec;          % assign ideal time vector
    Final_Table  (pos__real2ideal,:) = ...                  % assign all Variables in right position
        k_f_table(pos_ideal2_real,:);
    out_struct.(fields_names{k_f})   = Final_Table;         % assing the final table to the out
end