function kfun = reconstruct_kernel(beta_ni, sd, idxBlock, B)
% beta_hat: (p+1)x1 from ridge() with intercept
% sd: 1xp for X_ni columns
% idxBlock: indices into X_ni columns for this block
% B: (nLag x K) basis matrix for that kernel's lag grid
%
% Returns kfun: (nLag x 1) kernel in original units of y per event

    w_std = beta_ni(idxBlock);      % +1 to skip intercept
    w = w_std ./ sd(idxBlock)';          % undo column standardization

    kfun = B * w;                        % nLag x 1 actual kernel
end