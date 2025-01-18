

function dataset = checkAndFixTime(dataset)
    % Total number of observations
    total_observations = size(dataset, 1);
    
    % Find the first repeating time point
    unique_times = unique(dataset(:,1));
    first_repeating_index = find(histc(dataset(:,1), unique_times) > 1, 1, 'first');
    
    if isempty(first_repeating_index)
        disp('No repeating time points found.');
    else
        disp('One of the time axes has duplicates.');

        first_repeating_time = unique_times(first_repeating_index);

        % Index of the first repeating time in the original array
        start_index = find(dataset(:,1) == first_repeating_time, 1);

        % Calculate average time interval based on the data before the first repeat
        time_intervals = diff(dataset(1:start_index-1, 1));
        average_interval = mean(time_intervals);

        % Number of synthetic points to generate
        synthetic_points = total_observations - start_index + 1;

        % Generate synthetic time points
        start_time = dataset(start_index-1, 1);
        synthetic_times = start_time + (1:synthetic_points)' * average_interval;

        % Replace the repeating entries in the original array
        dataset(start_index:end, 1) = synthetic_times;

        % Optionally, display dataset if necessary
        % disp(dataset);
    end
    return;  % Return the modified dataset
end

