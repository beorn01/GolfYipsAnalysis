function dataset = checkAndFixFinite(dataset)
    % Remove rows with non-finite values (NaN, Inf, -Inf)
    finiteRows = isfinite(dataset(:,1));
    dataset = dataset(finiteRows, :);
    
    % Optionally display a message
    disp(['Removed ' num2str(sum(~finiteRows)) ' rows with non-finite values.']);
end
