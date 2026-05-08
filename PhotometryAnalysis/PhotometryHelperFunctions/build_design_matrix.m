function [X, labels, bases, lags] = build_design_matrix(t, sessTrials, cfg, lickTimes)

dt = cfg.dt;
labels = strings(0,1);
X = [];

bases = struct();
lags  = struct();

% ---------- Trial start ----------
if cfg.use.trialStart
    win = cfg.win.trialStart;
    K   = cfg.K.trialStart;

    lags.trialStart = (win(1):dt:win(2)).';
    bases.trialStart = make_rcos_basis(lags.trialStart, K, win);

    X_ts = event_kernel_block(t, sessTrials.t_trial_start, win, bases.trialStart, dt);
    X = [X, X_ts];
    labels = [labels; "TrialStart_b"+(1:K).'];
end

% ---------- Tone + modulators ----------
if cfg.use.tone_main || cfg.use.tone_F || cfg.use.tone_I || cfg.use.tone_FI
    [F, I, FI] = trial_modulators(sessTrials, cfg);

    win = cfg.win.tone;
    K   = cfg.K.tone;

    lags.tone = (win(1):dt:win(2)).';
    bases.tone = make_rcos_basis(lags.tone, K, win);

    [X_tone, X_tF, X_tI, X_tFI] = tone_blocks( ...
        t, sessTrials.t_tone_start, win, bases.tone, dt, F, I, FI);

    if cfg.use.tone_main
        X = [X, X_tone];
        labels = [labels; "Tone_b"+(1:K).'];
    end
    if cfg.use.tone_F
        X = [X, X_tF];
        labels = [labels; "ToneF_b"+(1:K).'];
    end
    if cfg.use.tone_I
        X = [X, X_tI];
        labels = [labels; "ToneI_b"+(1:K).'];
    end
    if cfg.use.tone_FI
        X = [X, X_tFI];
        labels = [labels; "ToneFI_b"+(1:K).'];
    end
end

% ---------- Outcomes (Hit / FA / CRMiss; legacy pos/neg optional) ----------
if cfg.use.outcome_hit || cfg.use.outcome_neg || cfg.use.outcome_FA || cfg.use.outcome_CRMiss

    win = cfg.win.outcome;
    K   = cfg.K.outcome;

    lags.outcome = (win(1):dt:win(2)).';
    bases.outcome = make_rcos_basis(lags.outcome, K, win);

    hasLick  = ~isnan(sessTrials.t_response);   % lick trials (Hit/FA)
    isReward = sessTrials.reward == 1;

    % Canonical categories
    isHit    =  isReward;              % reward only on lick trials
    isFA     = ~isReward &  hasLick;   % lick but no reward
    isCRMiss = ~isReward & ~hasLick;   % no lick, no reward (timeout)

    % Sanity checks (recommended)
    assert(all(isReward <= hasLick), "reward==1 on a no-lick trial (check t_response / reward).");
    assert(~any(isHit & isFA), "Hit and FA overlap (should be impossible).");
    assert(~any(isHit & isCRMiss), "Hit and CR/Miss overlap (should be impossible).");
    assert(~any(isFA  & isCRMiss), "FA and CR/Miss overlap (should be impossible).");

    % OutcomePos == Hit (keep your existing flag name)
    if cfg.use.outcome_hit
        X_oh = event_kernel_block(t, sessTrials.t_outcome(isHit), win, bases.outcome, dt);
        X = [X, X_oh];
        labels = [labels; "OutcomeHit_b"+(1:K).'];   % NOTE: rename label for clarity
    end

    % OutcomeFA
    if isfield(cfg.use,'outcome_FA') && cfg.use.outcome_FA
        X_ofa = event_kernel_block(t, sessTrials.t_outcome(isFA), win, bases.outcome, dt);
        X = [X, X_ofa];
        labels = [labels; "OutcomeFA_b"+(1:K).'];
    end

    % OutcomeCRMiss
    if isfield(cfg.use,'outcome_CRMiss') && cfg.use.outcome_CRMiss
        X_ocm = event_kernel_block(t, sessTrials.t_outcome(isCRMiss), win, bases.outcome, dt);
        X = [X, X_ocm];
        labels = [labels; "OutcomeCRMiss_b"+(1:K).'];
    end

    % Legacy OutcomeNeg (optional)
    if cfg.use.outcome_neg
        X_on = event_kernel_block(t, sessTrials.t_outcome(~isReward), win, bases.outcome, dt);
        X = [X, X_on];
        labels = [labels; "OutcomeNeg_b"+(1:K).'];
    end
end


% ---------- First lick ----------
if cfg.use.firstLick
    win = cfg.win.firstLick;
    K   = cfg.K.firstLick;

    lags.firstLick = (win(1):dt:win(2)).';
    bases.firstLick = make_rcos_basis(lags.firstLick, K, win);

    lickTimes = sessTrials.t_response;  % NaN for no-lick trials is OK
    X_lk = event_kernel_block(t, lickTimes, win, bases.firstLick, dt);

    X = [X, X_lk];
    labels = [labels; "FirstLick_b"+(1:K).'];
end

% ---------- Continuous lick rate (causal sliding window) ----------
if isfield(cfg.use,'lickRate') && cfg.use.lickRate

    if isempty(lickTimes)
        % no lick events at all
        dt = median(diff(t));
        win = cfg.lickRate.win_s;
        wSamp = max(1, round(win/dt));

        lickTrain = zeros(numel(t),1);
        lickCount = zeros(numel(t),1);
        lickRate  = zeros(numel(t),1);
    else
        dt = median(diff(t));
        win = cfg.lickRate.win_s;
        wSamp = max(1, round(win/dt));

        % impulse train on t-grid (counts per photometry sample bin)
        idx = round((lickTimes - t(1))/dt) + 1;
        idx = idx(idx >= 1 & idx <= numel(t));
        lickTrain = accumarray(idx, 1, [numel(t), 1], @sum, 0);

        if cfg.lickRate.causal
            % causal moving sum over last wSamp samples (includes current)
            lickCount = filter(ones(wSamp,1), 1, lickTrain);
        else
            % non-causal / centered moving sum (leaks future licks backwards)
            lickCount = movsum(lickTrain, [floor(wSamp/2) ceil(wSamp/2)], 'Endpoints','shrink');
        end

        lickRate = lickCount / (wSamp*dt);  % Hz-ish
    end

    % optional clip (only meaningful for continuous lickRate; safe either way)
    if isfield(cfg.lickRate,'clip_prctile') && cfg.lickRate.clip_prctile < 100
        hi = prctile(lickRate, cfg.lickRate.clip_prctile);
        lickRate = min(lickRate, hi);
    end

    % ---- optional binarize into lick-state (state not rate) ----
    % Definition: +1 if ANY lick occurred in the last causal window; else -1.
    % Uses lickCount (pre-zscore) so threshold is anchored to lick presence, not mean.
    isBinarize = isfield(cfg.lickRate,'binarize') && cfg.lickRate.binarize;
    if isBinarize
        lickState = ones(size(lickRate));
        lickState(lickCount == 0) = -1;
        lickRate = lickState;  % overwrite regressor with state variable
    end

    % z-score (per stream/session)
    % For binarized state, z-scoring is usually unnecessary and can be confusing.
    doZ = isfield(cfg.lickRate,'zscore') && cfg.lickRate.zscore && ~isBinarize;
    if doZ
        m = mean(lickRate,'omitnan');
        s = std(lickRate,0,'omitnan');
        if s == 0, s = 1; end
        lickRate = (lickRate - m) / s;
    end

    X = [X, lickRate];

    if isBinarize
        labels = [labels; "LickState"];
    else
        labels = [labels; "LickRate"];
    end
end

% ---------- Withholding / response-window boxcar (tone -> outcome) ----------
if isfield(cfg.use,'withholdingBoxcar') && cfg.use.withholdingBoxcar

    withhold = zeros(size(t));
    amp = cfg.withhold.value;

    % tone->outcome windows across valid trials already filtered in sessTrials
    t0s = sessTrials.t_tone_start;
    t1s = sessTrials.t_outcome;

    for k = 1:numel(t0s)
        t0 = t0s(k); t1 = t1s(k);
        if isnan(t0) || isnan(t1) || t1 <= t0
            continue
        end
        withhold(t >= t0 & t < t1) = amp;
    end

    X = [X, withhold];
    labels = [labels; "WithholdBoxcar"];  % consider renaming to "ResponseWindow"
end


assert(~any(isnan(X(:))), "X contains NaNs after building design matrix (check lickRate zscore/std and event timings).");




end