function idx = block_idx(labels_ni, prefix)
% Return indices of columns whose labels start with prefix.
% If no columns found, return [] (do NOT error).

    if isstring(labels_ni), labels_ni = cellstr(labels_ni); end
    if isstring(prefix), prefix = char(prefix); end

    idx = find(startsWith(string(labels_ni), string(prefix)));

    if isempty(idx)
        idx = [];  % graceful no-op
    end
end
