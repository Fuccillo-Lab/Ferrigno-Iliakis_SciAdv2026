function X = event_kernel_block(t, eventTimes, win, B, dt)
% Build a (nTime x K) regressor block by summing basis functions around each event.

nT = numel(t);
K = size(B,2);
X = zeros(nT, K);

pre  = win(1);
post = win(2);

lags = (pre:dt:post).';
if size(B,1) ~= numel(lags)
    error("B rows (%d) do not match lag grid (%d).", size(B,1), numel(lags));
end

for e = 1:numel(eventTimes)
    te = eventTimes(e);
    if isnan(te) || isinf(te); continue; end

    idx = find(t >= te+pre & t <= te+post);
    if isempty(idx); continue; end

    tau = t(idx) - te;
    row = round((tau - pre)/dt) + 1;
    row = max(1, min(numel(lags), row));

    X(idx, :) = X(idx, :) + B(row, :);
end
end