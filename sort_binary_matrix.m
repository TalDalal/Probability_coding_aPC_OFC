function [sorted_matrix, sort_order] = sort_binary_matrix(A)
    % Count number of ones in each row
    num_ones = sum(A, 2);
    
    % Find the position of the first '1' in each row (set to Inf if no ones)
    first_one_pos = arrayfun(@(row) find(A(row, :), 1, 'first'), 1:size(A, 1), 'UniformOutput', false);
    first_one_pos = cellfun(@(x) ifelse(isempty(x), Inf, x), first_one_pos);
    
    % Get sorting order
    [~, sort_order] = sortrows([num_ones, first_one_pos']);
    
    % Apply sorting order
    sorted_matrix = A(sort_order, :);
end

function out = ifelse(cond, val_true, val_false)
    if cond
        out = val_true;
    else
        out = val_false;
    end
end
