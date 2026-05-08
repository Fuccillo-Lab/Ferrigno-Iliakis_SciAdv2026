function B = make_rcos_basis(lags, K, win)
% Raised cosine basis on [win(1), win(2)]
t0 = win(1); t1 = win(2);
x = (lags - t0) / (t1 - t0);   % map to [0,1]
x = max(0, min(1, x));

c = linspace(0, 1, K);
dc = c(2)-c(1);

B = zeros(numel(x), K);
for k = 1:K
    z = (x - c(k)) / dc;
    B(:,k) = (abs(z) < 1) .* (0.5 + 0.5*cos(pi*z));
end

% Normalize each basis column so weights are comparable-ish
B = B ./ max(B, [], 1);
B(isnan(B)) = 0;
end