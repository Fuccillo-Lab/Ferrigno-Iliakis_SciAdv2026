function [X_main, X_F, X_I, X_FI] = tone_blocks(t, toneTimes, win, B, dt, F, I, FI)
% Build tone basis regressors, plus modulated copies by per-trial scalars.

K = size(B,2);
nT = numel(t);

X_main = zeros(nT,K);
X_F    = zeros(nT,K);
X_I    = zeros(nT,K);
X_FI   = zeros(nT,K);

pre = win(1);
post = win(2);
lags = (pre:dt:post).';
if size(B,1) ~= numel(lags)
    error("B rows (%d) do not match lag grid (%d).", size(B,1), numel(lags));
end

for e = 1:numel(toneTimes)
    te = toneTimes(e);
    if isnan(te) || isinf(te); continue; end

    idx = find(t >= te+pre & t <= te+post);
    if isempty(idx); continue; end

    tau = t(idx) - te;
    row = round((tau - pre)/dt) + 1;
    row = max(1, min(numel(lags), row));

    Be = B(row,:); % nIdx x K

    X_main(idx,:) = X_main(idx,:) + Be;

    if ~isnan(F(e));  X_F(idx,:)  = X_F(idx,:)  + F(e)  * Be; end
    if ~isnan(I(e));  X_I(idx,:)  = X_I(idx,:)  + I(e)  * Be; end
    if ~isnan(FI(e)); X_FI(idx,:) = X_FI(idx,:) + FI(e) * Be; end
end
end