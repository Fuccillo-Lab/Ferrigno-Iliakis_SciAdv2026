function K = reconstruct_all_kernels(beta_hat, sd, labels_noIntercept, bases, cfg)
% beta_hat includes intercept in row 1
% cfg.use.* controls which kernels are expected

% ---- defaults for cfg.use ----
if nargin < 5 || isempty(cfg); cfg = struct(); end
if ~isfield(cfg,'use'); cfg.use = struct(); end

defuse = struct( ...
    'trialStart',     true, ...
    'tone_main',      true, ...
    'tone_F',         true, ...
    'tone_I',         true, ...
    'tone_FI',        true, ...
    'outcome_hit',    true, ...
    'outcome_neg',    true, ...
    'outcome_FA',     true, ...
    'outcome_CRMiss', true, ...
    'firstLick',      true );

fn = fieldnames(defuse);
for j = 1:numel(fn)
    if ~isfield(cfg.use, fn{j})
        cfg.use.(fn{j}) = defuse.(fn{j});
    end
end

% ---- initialize output with all expected fields ----
K = struct( ...
    'trialStart', [], ...
    'tone_main',  [], ...
    'tone_F',     [], ...
    'tone_I',     [], ...
    'tone_FI',    [], ...
    'out_hit',    [], ...
    'out_neg',    [], ...
    'out_FA',     [], ...
    'out_CRMiss', [], ...
    'firstLick',  [] );

% ---- intercept handling ----
beta_ni = beta_hat(2:end);
lbl = labels_noIntercept;

% ---- helper: reconstruct only if:
%      (i) flag true
%      (ii) basis provided and nonempty
%      (iii) matching block exists
    function out = maybe_recon(flag, prefix, basis)
        out = [];
        if ~flag, return; end
        if nargin < 3 || isempty(basis), return; end   % <- key guard
        idx = block_idx(lbl, prefix);
        if isempty(idx), return; end
        out = reconstruct_kernel(beta_ni, sd, idx, basis);
    end

% ---- TrialStart ----
if cfg.use.trialStart && isfield(bases,'trialStart')
    K.trialStart = maybe_recon(true, "TrialStart_b", bases.trialStart);
end

% ---- Tone blocks ----
if isfield(bases,'tone')
    K.tone_main = maybe_recon(cfg.use.tone_main, "Tone_b",   bases.tone);
    K.tone_F    = maybe_recon(cfg.use.tone_F,    "ToneF_b",  bases.tone);
    K.tone_I    = maybe_recon(cfg.use.tone_I,    "ToneI_b",  bases.tone);
    K.tone_FI   = maybe_recon(cfg.use.tone_FI,   "ToneFI_b", bases.tone);
end

% ---- Outcomes (only touch bases.outcome if it exists) ----
if isfield(bases,'outcome')
    K.out_hit    = maybe_recon(cfg.use.outcome_hit,    "OutcomeHit_b",    bases.outcome);
    K.out_neg    = maybe_recon(cfg.use.outcome_neg,    "OutcomeNeg_b",    bases.outcome);
    K.out_FA     = maybe_recon(cfg.use.outcome_FA,     "OutcomeFA_b",     bases.outcome);
    K.out_CRMiss = maybe_recon(cfg.use.outcome_CRMiss, "OutcomeCRMiss_b", bases.outcome);
end

% ---- First lick ----
if cfg.use.firstLick && isfield(bases,'firstLick')
    K.firstLick = maybe_recon(true, "FirstLick_b", bases.firstLick);
end

end
