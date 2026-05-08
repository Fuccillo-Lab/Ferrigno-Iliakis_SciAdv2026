%% Single-trial kernel decomposition browser (Hit-by-default)
% Assumes you already have in workspace:
%   cfg (as you posted), streams (table), trials (table), summary (table), fits (struct 215x1), licks (table)
%
% Usage:
%   i = 1;                          % stream index (row into streams/summary/fits)
%   trial_browser(i, cfg, streams, trials, summary, fits, licks);
%
% Keys:
%   ←/→ : prev/next trial (within current trial set)
%   h   : toggle "hits only" vs "all valid"
%   r   : random trial (within set)
%   q/esc: quit

function trial_browser(i, cfg, streams, trials, summary, fits, licks)

  assert(i>=1 && i<=height(streams), 'i out of range');

  % ---- session & stream info ----
  sess = string(streams.session_uid(i));
  stream_uid = string(streams.stream_uid(i));

  % ---- load photometry time + signal ----
  t = h5read(cfg.h5file, streams.(cfg.time_field){i});   t = t(:);
  y = h5read(cfg.h5file, streams.(cfg.signal_field){i}); y = y(:);
  dt = median(diff(t));
  if isfield(cfg,'dt') && abs(dt - cfg.dt) > 1e-3
    warning('Observed dt=%.6f differs from cfg.dt=%.6f. Using observed dt.', dt, cfg.dt);
  end
  cfg_local = cfg;
  cfg_local.dt = dt;

  % ---- lick times for this session ----
  lickTimes = licks.lick_times(string(licks.session_uid)==sess);
  lickTimes = lickTimes(:);

  % ---- trials for this session ----
  sessTrials = trials(string(trials.session_uid)==sess & trials.is_valid==1, :);
  if isempty(sessTrials), error('No valid trials for session %s', sess); end

  % default set: hits only
  hitsOnly = true;

  % trial index pointer
  k = 1;

  % ---- figure ----
  f = figure('Name', sprintf('Trial Decomp | %s | %s | i=%d', sess, stream_uid, i), ...
             'Color','w', 'KeyPressFcn', @onKey);

  % initial draw
  redraw();

  % ================= nested funcs =================

  function onKey(~, evt)
    switch lower(evt.Key)
      case {'rightarrow','d'}
        k = min(k+1, height(get_trialset()));
        redraw();
      case {'leftarrow','a'}
        k = max(k-1, 1);
        redraw();
      case 'h'
        hitsOnly = ~hitsOnly;
        k = min(k, height(get_trialset()));
        redraw();
      case 'r'
        ts = get_trialset();
        k = randi(height(ts));
        redraw();
      case {'escape','q'}
        if isvalid(f), close(f); end
    end
  end

  function ts = get_trialset()
    if hitsOnly
      ts = sessTrials(sessTrials.outcome=="hit", :);
      if isempty(ts) % fallback
        ts = sessTrials;
      end
    else
      ts = sessTrials;
    end
  end

  function redraw()
    if ~isvalid(f), return; end
    clf(f);

    ts = get_trialset();
    k = max(1, min(k, height(ts)));
    tr = ts(k,:);

    % ---- window: [-2s from trial start, +3.5s from tone start] ----
    t0 = tr.t_trial_start - 2.0;
    if isnan(tr.t_tone_start)
      % restart/none trials: just show +4s from trial start
      t1 = tr.t_trial_start + 4.0;
    else
      t1 = tr.t_tone_start + 3.5;
    end

    % slice indices
    idxWin = find(t >= t0 & t <= t1);
    if numel(idxWin) < 10
      warning('Window too small / out of bounds for trial %s', string(tr.trial_uid));
      return;
    end
    tw = t(idxWin);
    yw = y(idxWin);

    % ---- build components on full time grid, then window ----
    comps = build_components_full(i, tr, t, cfg_local, fits, lickTimes, sessTrials);
    % window them
    fields = fieldnames(comps);
    for ff = 1:numel(fields)
      comps.(fields{ff}) = comps.(fields{ff})(idxWin);
    end

    % ---- plot layout ----
    % rows: events | trialStart | tone | outcome | withhold | lickrate | yhat | y
    nRows = 9;
    ax = gobjects(nRows,1);
    for r = 1:nRows
      ax(r) = subplot(nRows,1,r, 'Parent', f);
      hold(ax(r),'on');
      box(ax(r),'off');
      if r < nRows
        set(ax(r),'XTickLabel',[]);
      end
    end

    % ---- (1) events ----
    plot_events(ax(1), tw, tr);
    ylim_shared = 1.1 * max(abs(comps.yhat_noIntercept), [], 'omitnan');
    if ~isfinite(ylim_shared) || ylim_shared < 1e-6
        ylim_shared = 1;  % fallback; or pick something small like 0.1
    end

    % ---- (2-6) components ----
    plot(ax(2), tw, comps.trialStart, 'LineWidth', 1);
    ylabel(ax(2),'trialStart');
    ylim(ax(2), [-ylim_shared ylim_shared])

    plot(ax(3), tw, comps.tone_main, 'LineWidth', 1);
    ylabel(ax(3),'tone_main');
    ylim(ax(3), [-ylim_shared ylim_shared])
    
    plot(ax(4), tw, comps.tone_F, 'LineWidth', 1);
    ylabel(ax(4),'tone_F');
    ylim(ax(4), [-ylim_shared ylim_shared])

    plot(ax(5), tw, comps.outcome, 'LineWidth', 1);
    ylabel(ax(5),'outcome');
    ylim(ax(5), [-ylim_shared ylim_shared])

    plot(ax(6), tw, comps.withhold, 'LineWidth', 1);
    ylabel(ax(6),'withhold');
    ylim(ax(6), [-ylim_shared ylim_shared])

    plot(ax(7), tw, comps.lickRate, 'LineWidth', 1);
    ylabel(ax(7),'lickRate');
    ylim(ax(7), [-ylim_shared ylim_shared])

    % ---- (8) yhat (no intercept) ----
    plot(ax(8), tw, comps.yhat_noIntercept, 'LineWidth', 1.2);
    ylabel(ax(8),'yhat');
    ylim(ax(8), [-ylim_shared ylim_shared])

    % ---- (9) actual y ----
    plot(ax(9), tw, yw, 'LineWidth', 1.2);
    ylabel(ax(9),'dF/F');
    xlabel(ax(9),'photometry time (s)');
    linkaxes(ax,'x');      % x only
    set(ax(2:8),'YLimMode','manual');
    set(ax(9),'YLimMode','auto');
    for aa = 2:8
        ylim(ax(aa), [-ylim_shared ylim_shared]);
    end
    % 
    % % link x
    % linkaxes(ax,'x');

    % ---- title ----
    ttl = sprintf('%s | trial %d/%d | trial_uid=%s | outcome=%s | go_is_high=%d | rt=%.3f', ...
      sess, k, height(ts), string(tr.trial_uid), string(tr.outcome), tr.go_is_high, tr.rt);
    sgtitle(f, ttl, 'Interpreter','none');

  end
end

% ================= helpers =================

function comps = build_components_full(i, tr, t, cfg, fits, lickTimes, sessTrials)
  % Build full-length component predictions on the session time grid t.
  % Returns vectors same size as t.
  %
  % Components:
  %   trialStart, tone, outcome, withhold, lickRate, yhat_noIntercept

  n = numel(t);
  comps = struct();
  comps.trialStart = zeros(n,1);
  comps.tone       = zeros(n,1);
  comps.outcome    = zeros(n,1);
  comps.withhold   = zeros(n,1);
  comps.lickRate   = zeros(n,1);
  comps.yhat_noIntercept = zeros(n,1);

  dt = cfg.dt;

  % ---- kernels & lags ----
  K = fits(i).kernels;
  L = fits(i).lags;

  % ---- betas (intercept is beta_hat(1), unlabeled) ----
  beta = double(fits(i).model.beta_hat(:));
  labels = string(fits(i).model.labels(:));

  % find indices for continuous regressors
  bLick = 0; bWith = 0;
  idxL = find(labels=="LickRate", 1, 'first');
  if ~isempty(idxL), bLick = beta(idxL+1); end % +1 because intercept at 1
  idxW = find(labels=="WithholdBoxcar", 1, 'first');
  if ~isempty(idxW), bWith = beta(idxW+1); end

  % ---- trialStart component ----
  if isfield(K,'trialStart') && ~isnan(tr.t_trial_start)
    comps.trialStart = add_event_kernel(t, tr.t_trial_start, K.trialStart, L.trialStart, dt);
  end

  % ---- tone components (separate: main and frequency) ----
    comps.tone_main = zeros(n,1);
    comps.tone_F    = zeros(n,1);
    
    if ~isnan(tr.t_tone_start) && isfield(K,'tone_main')
      comps.tone_main = add_event_kernel(t, tr.t_tone_start, double(K.tone_main), L.tone, dt);
    
      if isfield(K,'tone_F')
        codeF = cfg.code.low;
        if tr.go_is_high == 1
          codeF = cfg.code.high;
        end
        comps.tone_F = codeF * add_event_kernel(t, tr.t_tone_start, double(K.tone_F), L.tone, dt);
      end
    end

    % keep a convenience "tone" sum if you want
    comps.tone = comps.tone_main + comps.tone_F;

  % ---- outcome component (hit / fa / cr / miss) ----
  if ~isnan(tr.t_outcome) && isfield(L,'outcome')
    oc = string(tr.outcome);
    if oc=="hit" && isfield(K,'out_hit')
      comps.outcome = add_event_kernel(t, tr.t_outcome, double(K.out_hit), L.outcome, dt);
    elseif oc=="fa" && isfield(K,'out_FA')
      comps.outcome = add_event_kernel(t, tr.t_outcome, double(K.out_FA), L.outcome, dt);
    elseif (oc=="cr" || oc=="miss") && isfield(K,'out_CRMiss')
      comps.outcome = add_event_kernel(t, tr.t_outcome, double(K.out_CRMiss), L.outcome, dt);
    else
      comps.outcome = zeros(n,1);
    end
  end

  % ---- withholding boxcar (tone -> outcome across session) ----
  if bWith ~= 0
    withhold = zeros(n,1);
    t0s = sessTrials.t_tone_start;
    t1s = sessTrials.t_outcome;
    for k = 1:numel(t0s)
      t0 = t0s(k); t1 = t1s(k);
      if isnan(t0) || isnan(t1) || t1 <= t0, continue; end
      withhold(t >= t0 & t < t1) = cfg.withhold.value;
    end
    comps.withhold = bWith * withhold;
  end

  % ---- lick rate (causal 200 ms, zscore) ----
  if bLick ~= 0
    lickRate = buildLickRate(t, lickTimes, cfg);
    comps.lickRate = bLick * lickRate(:);
  end

  % ---- sum (no intercept) ----
  comps.yhat_noIntercept = comps.trialStart + comps.tone_main + comps.tone_F + comps.outcome + comps.withhold + comps.lickRate;
end

function y = add_event_kernel(t, tEvent, kernel, lags, dt)
  % Place a causal (or general) kernel at time tEvent on grid t using explicit lag indexing.
  % kernel: vector length m
  % lags: vector length m, in seconds (can be >=0; if includes negatives, this supports it too)

  n = numel(t);
  y = zeros(n,1);

  if isnan(tEvent), return; end

  % event index on t-grid
  idx0 = round((tEvent - t(1))/dt) + 1;
  if idx0 < 1 || idx0 > n, return; end

  lagIdx = round(double(lags(:)) / dt);   % integer sample offsets
  tgt = idx0 + lagIdx;

  ok = (tgt >= 1) & (tgt <= n);
  tgt = tgt(ok);
  kval = double(kernel(:));
  kval = kval(ok);

  y(tgt) = y(tgt) + kval;
end

function plot_events(ax, tw, tr)
  % Minimal event markers (trial start, tone start/end, outcome)
  yl = [0 1];
  plot(ax, [tw(1) tw(end)], [0 0], 'k-'); % baseline

  % trial start at time = tr.t_trial_start (may be inside window)
  x = tr.t_trial_start;
  if x>=tw(1) && x<=tw(end)
    line(ax, [x x], yl, 'LineStyle','-', 'LineWidth',1);
    text(ax, x, 1.02, 'trial', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
  end

  % tone start/end
  if ~isnan(tr.t_tone_start)
    x = tr.t_tone_start;
    if x>=tw(1) && x<=tw(end)
      line(ax, [x x], yl, 'LineStyle','-', 'LineWidth',1);
      text(ax, x, 1.02, 'tone', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    end
  end
  if ~isnan(tr.t_tone_end)
    x = tr.t_tone_end;
    if x>=tw(1) && x<=tw(end)
      line(ax, [x x], yl, 'LineStyle','--', 'LineWidth',1);
    end
  end

  % outcome (same as response/first lick in your coding)
  if ~isnan(tr.t_outcome)
    x = tr.t_outcome;
    if x>=tw(1) && x<=tw(end)
      line(ax, [x x], yl, 'LineStyle','-', 'LineWidth',1.2);
      text(ax, x, 1.02, 'outcome', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    end
  end

  ylim(ax, [-0.1 1.2]);
  ylabel(ax,'events');
  set(ax,'YTick',[]);
end

% ---- your lickRate helper (as provided) ----
function lickRate = buildLickRate(t, lickTimes, cfg)
  dt = median(diff(t));
  win = cfg.lickRate.win_s;
  wSamp = max(1, round(win/dt));

  lickTrain = zeros(numel(t),1);
  if ~isempty(lickTimes)
    idx = round((lickTimes - t(1))/dt) + 1;
    idx = idx(idx>=1 & idx<=numel(t));
    lickTrain = accumarray(idx,1,[numel(t),1],@sum,0);
  end

  if cfg.lickRate.causal
    lickCount = filter(ones(wSamp,1),1,lickTrain);
  else
    lickCount = movsum(lickTrain,[floor(wSamp/2), ceil(wSamp/2)], 'Endpoints','shrink');
  end

  lickRate = lickCount / (wSamp*dt);

  if isfield(cfg.lickRate,'clip_prctile') && cfg.lickRate.clip_prctile < 100
    hi = prctile(lickRate, cfg.lickRate.clip_prctile);
    lickRate = min(lickRate, hi);
  end

  isBinarize = isfield(cfg.lickRate,'binarize') && cfg.lickRate.binarize;
  if isBinarize
    lickState = ones(size(lickRate));
    lickState(lickCount == 0) = -1;
    lickRate = lickState;
  end

  doZ = isfield(cfg.lickRate,'zscore') && cfg.lickRate.zscore && ~isBinarize;
  if doZ
    m = mean(lickRate,'omitnan');
    s = std(lickRate,0,'omitnan'); if s==0, s=1; end
    lickRate = (lickRate-m)/s;
  end
end