function [allOUT, metricsAll] = resid_psth_pipeline(streams, trials, fits, cfg, licks)

%RESID_PSTH_PIPELINE  Residualized PSTHs (Option A: save PSTHs + metadata + metrics)
%
% Requirements:
% - streams: table with fields including:
%     stream_uid, session_uid, animal_id, cell_type, side,
%     path_time, path_debleached (or cfg.signal_field), include (optional)
% - trials: table with fields including:
%     session_uid, is_valid, trial_idx, tone_type, go_is_high, outcome,
%     t_trial_start, t_tone_start, t_outcome, rt
% - fits: 215x1 struct with fields:
%     kernels.(trialStart, tone_main, tone_F, out_hit, out_FA, out_CRMiss)
%     lags.(trialStart, tone, outcome)
% - cfg fields:
%     dt = 0.025
%     h5file = "C:\...\signals2.h5"
%     time_field = "path_time"
%     signal_field = "path_debleached" (or normalized)
%     win.trialStart_extract = [-1 2]
%     win.tone_extract = [-1 2]
%     code.high = +0.5; code.low = -0.5;  % for HIGH vs LOW frequency
%
% Outputs:
% - allOUT: cell array of per-stream output structs
% - metricsAll: concatenated table of per-trial metrics (tidy long format)

arguments
    streams table
    trials  table
    fits    struct
    cfg     struct
    licks   table = table()   % optional
end

% --- default cfg sanity
if ~isfield(cfg,'dt'), cfg.dt = 0.025; end
if ~isfield(cfg,'time_field'), cfg.time_field = "path_time"; end
if ~isfield(cfg,'signal_field'), cfg.signal_field = "path_debleached"; end
if ~isfield(cfg,'win') || ~isfield(cfg.win,'trialStart_extract')
    cfg.win.trialStart_extract = [-1 2];
end
if ~isfield(cfg,'win') || ~isfield(cfg.win,'tone_extract')
    cfg.win.tone_extract = [-1 2];
end
if ~isfield(cfg,'code')
    cfg.code.high = +0.5;
    cfg.code.low  = -0.5;
end

allOUT = cell(numel(fits), 1);
metricsAll = table();

for i = 1:numel(fits)
    if isfield(streams,'include') && ~streams.include(i)
        continue;
    end
    OUT = residualize_stream_optionA(i, streams, trials, fits, cfg, licks);
    allOUT{i} = OUT;
    metricsAll = [metricsAll; OUT.metrics]; %#ok<AGROW>
end

end

% =====================================================================
function OUT = residualize_stream_optionA(i, streams, trials, fits, cfg, licks)


dt = cfg.dt;

% extraction windows (plotting windows)
tTS   = (cfg.win.trialStart_extract(1):dt:cfg.win.trialStart_extract(2))';
tTone = (cfg.win.tone_extract(1):dt:cfg.win.tone_extract(2))';

% --- load time + signal from H5
t = h5read(cfg.h5file, streams.(cfg.time_field){i});  t = t(:);
y = h5read(cfg.h5file, streams.(cfg.signal_field){i}); y = y(:);

% quick dt sanity (optional but helpful)
% dt_emp = mean(diff(t),'omitnan');
% if abs(dt_emp - dt) > 1e-3
%     warning('Stream %d dt mismatch: empirical %.6f vs cfg %.6f', i, dt_emp, dt);
% end

% --- select valid trials for this session
sid = streams.session_uid{i};
Tr = trials(strcmp(trials.session_uid, sid) & trials.is_valid==1, :);
if isempty(Tr)
    OUT = empty_out(streams, i, tTS, tTone);
    return;
end
Tr = sortrows(Tr, "trial_idx");
nTr = height(Tr);

% ============================================================
% Session-level covariates for extra residualization (Lick + Withhold)
% ============================================================

% --- fetch lick times for this session_uid (absolute session time, seconds)
lickTimes = [];
if ~isempty(licks) && ismember("session_uid", licks.Properties.VariableNames)
    ixL = find(strcmp(licks.session_uid, sid), 1, 'first');
    if ~isempty(ixL)
        lt = licks.lick_times(ixL);
        if iscell(lt)
            lickTimes = lt{1};
        else
            lickTimes = lt;
        end
        lickTimes = lickTimes(:);
    end
end

% --- build lickRate on full session t-grid (match GLM code)
lickRate_full = compute_lickrate_on_grid(t, lickTimes, cfg);

% --- build withholding boxcar on full session t-grid: tone -> outcome
withhold_full = zeros(size(t), 'single');
if isfield(cfg,'use') && isfield(cfg.use,'withholdingBoxcar') && cfg.use.withholdingBoxcar
    amp = cfg.withhold.value;

    % only trials with a real tone + real outcome; restart/truncated should fail these anyway
    validWH = Tr.is_valid==1 & ~(Tr.outcome=="restart" | Tr.outcome=="truncated") & ...
              ~(Tr.tone_type=="none") & ~isnan(Tr.t_tone_start) & ~isnan(Tr.t_outcome) & (Tr.t_outcome > Tr.t_tone_start);

    t0s = double(Tr.t_tone_start(validWH));
    t1s = double(Tr.t_outcome(validWH));

    for k = 1:numel(t0s)
        t0 = t0s(k); t1 = t1s(k);
        withhold_full(t >= t0 & t < t1) = amp;
    end
end

% --- pull scalar betas (robust to missing predictors)
betaLick = get_beta_from_model(fits(i), "LickRate");
betaWH   = get_beta_from_model(fits(i), "WithholdBoxcar");


% --- kernels + lags
K = fits(i).kernels;

lagsTS   = fits(i).lags.trialStart(:);   % [-1..2]
lagsTone = fits(i).lags.tone(:);         % [0..1.5]
lagsOut  = fits(i).lags.outcome(:);      % [0..2]

kTS    = single(K.trialStart(:));
kTone  = single(K.tone_main(:));
kToneF = single(K.tone_F(:));

kHit = single(K.out_hit(:));
kFA  = single(K.out_FA(:));
kCRM = single(K.out_CRMiss(:));

% --- allocate trial-by-time (kept internal; Option A does not save it)
Yts   = nan(numel(tTS),   nTr, 'single');
Ytone_base = nan(numel(tTone), nTr, 'single');   % y - (trialStart + outcome)
Ytone_LW   = nan(numel(tTone), nTr, 'single');   % additionally subtract betaLick*lickRate + betaWH*withhold


% --- build per-trial metadata (for slicing)
Tmeta = table();
Tmeta.stream_uid   = repmat(string(streams.stream_uid{i}), nTr, 1);
Tmeta.session_uid  = repmat(string(streams.session_uid{i}), nTr, 1);
Tmeta.animal_id    = repmat(string(streams.animal_id{i}), nTr, 1);
Tmeta.cell_type    = repmat(string(streams.cell_type{i}), nTr, 1);
Tmeta.hemi         = repmat(string(streams.side{i}), nTr, 1);

Tmeta.trial_idx    = double(Tr.trial_idx);
Tmeta.tone_type    = string(Tr.tone_type);      % "go"|"nogo"|"none"
Tmeta.go_is_high   = double(Tr.go_is_high);     % 1/0
Tmeta.outcome      = string(Tr.outcome);        % includes restart/truncated
Tmeta.rt           = double(Tr.rt);

Tmeta.t_trial_start = double(Tr.t_trial_start);
Tmeta.t_tone_start  = double(Tr.t_tone_start);
Tmeta.t_outcome     = double(Tr.t_outcome);

% tone played?
tonePlayed = ~(Tmeta.tone_type=="none" | Tmeta.outcome=="restart");
Tmeta.tone_played = double(tonePlayed);

% derive high/low tone label for trials where tone played
isHighTone = nan(nTr,1);
goIsHigh = logical(Tmeta.go_is_high);
for tr=1:nTr
    if ~tonePlayed(tr), continue; end
    if Tmeta.tone_type(tr)=="go"
        isHighTone(tr) = goIsHigh(tr);
    elseif Tmeta.tone_type(tr)=="nogo"
        isHighTone(tr) = ~goIsHigh(tr);
    end
end
Tmeta.is_high_tone = isHighTone;  % NaN if no tone

% previous outcome (within-session)
prev = strings(nTr,1);
prev(1) = missing;
prev(2:end) = Tmeta.outcome(1:end-1);
Tmeta.prev_outcome = prev;

% You may want a "clean" outcome excluding restart/truncated
Tmeta.is_clean_outcome = double(~(Tmeta.outcome=="restart" | Tmeta.outcome=="truncated"));

% --- per-trial metrics table (tidy, LME-friendly)
metrics = table();
metrics.stream_uid  = Tmeta.stream_uid;
metrics.session_uid = Tmeta.session_uid;
metrics.animal_id   = Tmeta.animal_id;
metrics.cell_type   = Tmeta.cell_type;
metrics.hemi        = Tmeta.hemi;

metrics.trial_idx   = Tmeta.trial_idx;
metrics.tone_type   = Tmeta.tone_type;
metrics.is_high_tone= Tmeta.is_high_tone;
metrics.outcome     = Tmeta.outcome;
metrics.prev_outcome= Tmeta.prev_outcome;
metrics.tone_played = Tmeta.tone_played;

metrics.auc_ts      = nan(nTr,1);
metrics.auc_tone    = nan(nTr,1);
metrics.pk_tone     = nan(nTr,1);

% metric windows (edit later)
win_auc_ts   = [0, 0.8];
win_auc_tone = [0, 0.5];
win_pk_tone  = [0, 0.4];

idx_auc_ts   = tTS   >= win_auc_ts(1)   & tTS   <= win_auc_ts(2);
idx_auc_tone = tTone >= win_auc_tone(1) & tTone <= win_auc_tone(2);
idx_pk_tone  = tTone >= win_pk_tone(1)  & tTone <= win_pk_tone(2);

% =========================
% Trial loop
% =========================
for tr = 1:nTr

    t0   = Tmeta.t_trial_start(tr);
    tt   = Tmeta.t_tone_start(tr);
    tout = Tmeta.t_outcome(tr);

    toneType = Tmeta.tone_type(tr);
    outType  = Tmeta.outcome(tr);
    tp       = logical(Tmeta.tone_played(tr));

    % -------------------------
    % (A) TrialStart-aligned residual:
    % y - (tone + outcome)
    % -------------------------
    tAbs = t0 + tTS;
    ySeg = extract_segment_dt(t, y, tAbs, dt);

    yhat_other = zeros(size(tTS), 'single');

    % subtract tone contribution (kernel support [0..1.5] via lagsTone)
    if tp && ~isnan(tt)
        tToneRel = tt - t0;

        % frequency coding via go_is_high and tone_type
        if toneType=="go"
            isHigh = logical(Tmeta.go_is_high(tr));
        elseif toneType=="nogo"
            isHigh = ~logical(Tmeta.go_is_high(tr));
        else
            isHigh = false; % should not happen if tp true
        end
        codeF = cfg.code.low;
        if isHigh, codeF = cfg.code.high; end

        yhat_other = addKernel_dt(yhat_other, tTS, tToneRel, kTone,  lagsTone, dt);
        yhat_other = addKernel_dt(yhat_other, tTS, tToneRel, single(codeF)*kToneF, lagsTone, dt);
    end

    % subtract outcome contribution (kernel support [0..2] via lagsOut)
    if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
        tOutRel = tout - t0;
        kout = outcome_kernel(outType, kHit, kFA, kCRM);
        yhat_other = addKernel_dt(yhat_other, tTS, tOutRel, kout, lagsOut, dt);
    end

    yResTS = single(ySeg) - yhat_other;
    Yts(:,tr) = yResTS;

    % metric: auc_ts
    metrics.auc_ts(tr) = trapz(tTS(idx_auc_ts), double(yResTS(idx_auc_ts)));

    % -------------------------
    % (B) Tone-aligned residual (window [-1,2]):
    % y - (trialStart + outcome)
    % -------------------------
    if ~tp || isnan(tt)
        continue;
    end

    tAbs = tt + tTone;
    ySeg = extract_segment_dt(t, y, tAbs, dt);

    yhat_other = zeros(size(tTone), 'single');

    % subtract trialStart contribution
    if ~isnan(t0)
        tTSrel = t0 - tt;  % trialStart relative to tone anchor
        yhat_other = addKernel_dt(yhat_other, tTone, tTSrel, kTS, lagsTS, dt);
    end

    % subtract outcome contribution
    if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
        tOutRel = tout - tt;
        kout = outcome_kernel(outType, kHit, kFA, kCRM);
        yhat_other = addKernel_dt(yhat_other, tTone, tOutRel, kout, lagsOut, dt);
    end

    yResTone_base = single(ySeg) - yhat_other;
Ytone_base(:,tr) = yResTone_base;

% --- additional residualization: subtract lickRate and withhold contributions (if present)
% Extract lickRate/withhold segments on the tone-aligned window using dt indexing.
% Since tTone is relative to tt, we just sample the precomputed full-session vectors at (tt + tTone).
tAbs = tt + tTone;  % absolute times of the tone-aligned window
lickSeg = extract_segment_dt(t, lickRate_full, tAbs, dt);
whSeg   = extract_segment_dt(t, withhold_full,  tAbs, dt);

yResTone_LW = yResTone_base - single(betaLick) * single(lickSeg) - single(betaWH) * single(whSeg);
Ytone_LW(:,tr) = yResTone_LW;

% metrics: you can keep metrics computed on base, or add parallel LW metrics (recommended)
metrics.auc_tone(tr) = trapz(tTone(idx_auc_tone), double(yResTone_base(idx_auc_tone)));
metrics.pk_tone(tr)  = max(double(yResTone_base(idx_pk_tone)), [], 'omitnan');

% OPTIONAL: add LW metrics (if you want for plotting / stats)
if ~ismember("auc_tone_LW", metrics.Properties.VariableNames)
    metrics.auc_tone_LW = nan(nTr,1);
    metrics.pk_tone_LW  = nan(nTr,1);
end
metrics.auc_tone_LW(tr) = trapz(tTone(idx_auc_tone), double(yResTone_LW(idx_auc_tone)));
metrics.pk_tone_LW(tr)  = max(double(yResTone_LW(idx_pk_tone)), [], 'omitnan');


end

% =========================
% Per-stream PSTHs (overall + stratified)
% =========================

OUT.stream_uid  = string(streams.stream_uid{i});
OUT.session_uid = string(streams.session_uid{i});
OUT.animal_id   = string(streams.animal_id{i});
OUT.cell_type   = string(streams.cell_type{i});
OUT.side        = string(streams.side{i});

OUT.t_trialStart = tTS;
OUT.t_tone       = tTone;

% overall
OUT.psth.trialStart_all = mean(Yts,   2, 'omitnan');
OUT.psth.tone_all_base = mean(Ytone_base, 2, 'omitnan');
OUT.psth.tone_all_LW   = mean(Ytone_LW,   2, 'omitnan');

OUT.nTrials.trialStart_all = sum(any(~isnan(Yts),1));
OUT.nTrials.tone_all_base = sum(any(~isnan(Ytone_base),1));
OUT.nTrials.tone_all_LW   = sum(any(~isnan(Ytone_LW),1));

% stratifications for tone PSTH
OUT = add_stratified_psths(OUT, Ytone_base, tTone, Tmeta, "tone_base");
OUT = add_stratified_psths(OUT, Ytone_LW,   tTone, Tmeta, "tone_LW");

% stratifications for trialStart PSTH (usually by outcome; also optionally by action/freq if you want)
OUT = add_stratified_psths(OUT, Yts, tTS, Tmeta, "trialStart");

% store metadata + metrics
OUT.trials  = Tmeta;
OUT.metrics = metrics;

end

% =====================================================================
function OUT = add_stratified_psths(OUT, Y, tvec, Tmeta, whichEvent)
% Adds PSTHs and counts for common strata.
% Y: [T x nTrials] residual matrix (internal)
% whichEvent: "tone" or "trialStart"

% helper to compute mean+count with a logical mask over trials
    function [m,n] = mean_mask(mask)
        if ~any(mask)
            m = nan(numel(tvec),1,'single'); n = 0; return;
        end
        m = mean(Y(:,mask), 2, 'omitnan');
        n = sum(any(~isnan(Y(:,mask)),1));
    end

whichEvent = string(whichEvent);
isTone = startsWith(lower(whichEvent), "tone");


% define "usable" trials for this event:
if isTone
    usable = logical(Tmeta.tone_played) & ~isnan(Tmeta.t_tone_start);
else
    usable = true(size(Tmeta.trial_idx));
end

% outcome usable (exclude restart/truncated)
cleanOut = usable & ~(Tmeta.outcome=="restart" | Tmeta.outcome=="truncated");

% -------------------------
% By outcome (current)
% -------------------------
labels = ["hit","fa","cr","miss"];
for lab = labels
    mask = cleanOut & (Tmeta.outcome==lab);
    [m,n] = mean_mask(mask);
    OUT.psth.(whichEvent + "_byOutcome").(lab) = m;
    OUT.nTrials.(whichEvent + "_byOutcome").(lab) = n;
end

% -------------------------
% By previous outcome (optional but computed)
% Exclude missing prev and exclude prev restart/truncated
% -------------------------
prevOk = cleanOut & ~(Tmeta.prev_outcome==missing) & ...
    ~(Tmeta.prev_outcome=="restart" | Tmeta.prev_outcome=="truncated");
for lab = labels
    mask = prevOk & (Tmeta.prev_outcome==lab);
    [m,n] = mean_mask(mask);
    OUT.psth.(whichEvent + "_byPrevOutcome").(lab) = m;
    OUT.nTrials.(whichEvent + "_byPrevOutcome").(lab) = n;
end

% -------------------------
% Tone-only strata: by action and by frequency
% -------------------------
if isTone
    % by action (go/nogo)
    keyA = whichEvent + "_byAction";
    for lab = ["go","nogo"]
        mask = usable & (Tmeta.tone_type==lab);
        [m,n] = mean_mask(mask);
        OUT.psth.(keyA).(lab) = m;
        OUT.nTrials.(keyA).(lab) = n;
    end

    % by frequency (high/low)
    keyF = whichEvent + "_byFreq";
    maskHigh = usable & (Tmeta.is_high_tone==1);
    maskLow  = usable & (Tmeta.is_high_tone==0);

    [mH,nH] = mean_mask(maskHigh);
    [mL,nL] = mean_mask(maskLow);

    OUT.psth.(keyF).high = mH;
    OUT.psth.(keyF).low  = mL;
    OUT.nTrials.(keyF).high = nH;
    OUT.nTrials.(keyF).low  = nL;

    % action×freq combos
    keyAF = whichEvent + "_byActionFreq";
    mask_go   = usable & (Tmeta.tone_type=="go");
    mask_nogo = usable & (Tmeta.tone_type=="nogo");
    mask_hi   = usable & (Tmeta.is_high_tone==1);
    mask_lo   = usable & (Tmeta.is_high_tone==0);

    [OUT.psth.(keyAF).high_go,   OUT.nTrials.(keyAF).high_go]   = mean_mask(mask_hi & mask_go);
    [OUT.psth.(keyAF).low_go,    OUT.nTrials.(keyAF).low_go]    = mean_mask(mask_lo & mask_go);
    [OUT.psth.(keyAF).high_nogo, OUT.nTrials.(keyAF).high_nogo] = mean_mask(mask_hi & mask_nogo);
    [OUT.psth.(keyAF).low_nogo,  OUT.nTrials.(keyAF).low_nogo]  = mean_mask(mask_lo & mask_nogo);
end

end

% =====================================================================
function kout = outcome_kernel(outType, kHit, kFA, kCRM)
% Maps outcome label to correct kernel
if outType=="hit"
    kout = kHit;
elseif outType=="fa"
    kout = kFA;
else
    % includes "cr" and "miss"
    kout = kCRM;
end
end

% =====================================================================
function ySeg = extract_segment_dt(t, y, tAbs, dt)
% Fast dt-aligned extraction
t0 = t(1);
idx = round((tAbs - t0)/dt) + 1;

ySeg = nan(size(tAbs), 'like', y);
valid = idx >= 1 & idx <= numel(y);
ySeg(valid) = y(idx(valid));
end

% =====================================================================
function yhat = addKernel_dt(yhat, tWin, tEventRel, k, lags, dt)
% Paint kernel samples into window, dt-aligned
tContrib = tEventRel + lags;          % times relative to anchor
win0 = tWin(1);
idx = round((tContrib - win0)/dt) + 1;

valid = idx >= 1 & idx <= numel(tWin);
idx = idx(valid);

yhat(idx) = yhat(idx) + k(valid);
end

% =====================================================================
function OUT = empty_out(streams, i, tTS, tTone)
OUT.stream_uid  = string(streams.stream_uid{i});
OUT.session_uid = string(streams.session_uid{i});
OUT.animal_id   = string(streams.animal_id{i});
OUT.cell_type   = string(streams.cell_type{i});
OUT.side        = string(streams.side{i});
OUT.t_trialStart = tTS;
OUT.t_tone       = tTone;
OUT.psth = struct();
OUT.nTrials = struct();
OUT.trials = table();
OUT.metrics = table();
end

% =====================================================================
function beta = get_beta_from_model(fitStruct, labelName)
% Returns scalar beta for a non-kernel predictor (e.g., LickRate), robust to absence.
beta = 0;
if ~isfield(fitStruct,'model') || ~isfield(fitStruct.model,'beta_hat') || ~isfield(fitStruct.model,'labels')
    return
end

labels = string(fitStruct.model.labels);
bh = double(fitStruct.model.beta_hat(:));  % includes intercept first

ix = find(labels == string(labelName), 1, 'first');
if isempty(ix)
    beta = 0;
    return
end

% labels correspond to beta_hat(2:end) (since beta_hat(1) is intercept)
bh_ix = ix + 1;
if bh_ix >= 1 && bh_ix <= numel(bh)
    beta = bh(bh_ix);
end
end

% =====================================================================
function lickRate = compute_lickrate_on_grid(t, lickTimes, cfg)
% Matches your GLM design-matrix lickRate code.
lickRate = zeros(size(t), 'single');

if isempty(lickTimes)
    return
end

dt = median(diff(t));
win = cfg.lickRate.win_s;
wSamp = max(1, round(win/dt));

% impulse train on t-grid
idx = round((lickTimes - t(1))/dt) + 1;
idx = idx(idx >= 1 & idx <= numel(t));
lickTrain = accumarray(idx, 1, [numel(t), 1], @sum, 0);

if cfg.lickRate.causal
    lickCount = filter(ones(wSamp,1), 1, lickTrain);   % causal
else
    lickCount = movsum(lickTrain, [floor(wSamp/2) ceil(wSamp/2)], 'Endpoints','shrink');
end

lickRate = single(lickCount / (wSamp*dt));  % Hz-ish

% optional clip
if isfield(cfg.lickRate,'clip_prctile') && cfg.lickRate.clip_prctile < 100
    hi = prctile(double(lickRate), cfg.lickRate.clip_prctile);
    lickRate = min(lickRate, single(hi));
end

% z-score (per stream/session)
if isfield(cfg.lickRate,'zscore') && cfg.lickRate.zscore
    m = mean(lickRate,'omitnan');
    s = std(lickRate,0,'omitnan');
    if s == 0, s = 1; end
    lickRate = (lickRate - m) / s;
end
end
