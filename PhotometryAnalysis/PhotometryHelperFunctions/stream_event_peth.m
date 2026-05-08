function out = stream_event_peth(streamRow, trials, cfg, varargin)
% stream_event_peth
% General event-aligned PETH from continuous photometry for ONE stream/session.
%
% REQUIRED
%   streamRow : 1x1 table row from `streams`
%   trials    : trials table
%   cfg.h5file        : path to .h5
%   cfg.signal_field  : e.g. "path_debleached"
%   cfg.time_field    : e.g. "path_time"
%
% NAME-VALUE OPTIONS
%   'AlignField'  : which trials time field to align to (default "t_trial_start")
%   'Win'         : [pre post] seconds relative to event (default [-1 2])
%   'ValidOnly'   : true/false, filter trials.is_valid==1 (default true)
%   'DropNaNAlign': true/false, drop NaN alignment times (default true)
%   'DemeanY'     : true/false, subtract mean(y) (default true)
%   'Baseline'    : [t0 t1] seconds rel event; subtract per-trial baseline mean (default [])
%   'SmoothS'     : smoothing window in seconds (moving average; default 0)
%   'DoPlot'      : true/false (default true)
%
% OUTPUT
%   out.t_rel, out.Y, out.peth_mean, out.peth_sem, out.nTrials
%   out.align_times, out.keepTrials, out.meta

% -----------------------------
% Parse inputs
% -----------------------------
p = inputParser;
p.addParameter('AlignField', "t_trial_start", @(x) ischar(x) || isstring(x));
p.addParameter('Win', [-1 2], @(x) isnumeric(x) && numel(x)==2 && x(1)<x(2));
p.addParameter('ValidOnly', true, @islogical);
p.addParameter('DropNaNAlign', true, @islogical);
p.addParameter('DemeanY', true, @islogical);
p.addParameter('Baseline', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==2 && x(1)<x(2)));
p.addParameter('SmoothS', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
p.addParameter('DoPlot', true, @islogical);
p.parse(varargin{:});
opt = p.Results;

alignField = string(opt.AlignField);
win = opt.Win;

% -----------------------------
% Load continuous time and signal
% -----------------------------
t = h5read(cfg.h5file, streamRow.(cfg.time_field){1}); t = t(:);
y = h5read(cfg.h5file, streamRow.(cfg.signal_field){1}); y = y(:);

assert(numel(t)==numel(y), "t and y lengths mismatch.");

% Sampling rate
dt = median(diff(t), 'omitnan');
Fs = 1/dt;

% Optional demean (often helpful for interpretability; not required)
if opt.DemeanY
    y = y - mean(y, 'omitnan');
end

% -----------------------------
% Select trials for this session
% -----------------------------
sessTrials = trials(trials.session_uid == streamRow.session_uid, :);

if opt.ValidOnly && ismember('is_valid', sessTrials.Properties.VariableNames)
    sessTrials = sessTrials(sessTrials.is_valid == 1, :);
end

assert(height(sessTrials) > 0, "No trials after session/valid filtering.");

% Ensure alignField exists
assert(ismember(alignField, string(sessTrials.Properties.VariableNames)), ...
    "AlignField '%s' not found in trials table.", alignField);

alignTimes = sessTrials.(alignField);

% Robustness: convert string/cell to numeric if needed
if isstring(alignTimes) || iscellstr(alignTimes)
    alignTimes = str2double(alignTimes);
end
alignTimes = double(alignTimes);

% Drop NaNs if requested
keep = true(size(alignTimes));
if opt.DropNaNAlign
    keep = keep & ~isnan(alignTimes);
end

% Also drop trials where alignment is outside trace bounds (need full window)
tminNeeded = alignTimes + win(1);
tmaxNeeded = alignTimes + win(2);
keep = keep & (tminNeeded >= t(1)) & (tmaxNeeded <= t(end));

sessTrials_kept = sessTrials(keep, :);
alignTimes_kept = alignTimes(keep);

nTrials = numel(alignTimes_kept);
assert(nTrials > 0, "No trials remain after NaN/bounds filtering for %s.", alignField);

% -----------------------------
% Build trial-aligned matrix Y
% -----------------------------
nSamp = round((win(2)-win(1)) * Fs) + 1;
t_rel = linspace(win(1), win(2), nSamp)';  % relative time axis

Y = nan(nSamp, nTrials);

for i = 1:nTrials
    t0 = alignTimes_kept(i);
    % desired absolute times for this trial window
    t_abs = t0 + t_rel;

    % map to nearest indices (since t is regular at 40 Hz this is fine)
    idx0 = round((t_abs(1) - t(1)) * Fs) + 1;
    idx1 = idx0 + nSamp - 1;

    % safety check
    if idx0 < 1 || idx1 > numel(y)
        continue
    end
    Y(:, i) = y(idx0:idx1);
end

% Drop any all-NaN trials (shouldn’t happen often, but be safe)
goodTrial = ~all(isnan(Y), 1);
Y = Y(:, goodTrial);
alignTimes_kept = alignTimes_kept(goodTrial);
sessTrials_kept = sessTrials_kept(goodTrial, :);
nTrials = size(Y,2);

assert(nTrials > 0, "All trials became NaN after extraction.");

% -----------------------------
% Optional: per-trial baseline subtraction
% -----------------------------
if ~isempty(opt.Baseline)
    bMask = (t_rel >= opt.Baseline(1)) & (t_rel <= opt.Baseline(2));
    if ~any(bMask)
        warning("Baseline window has no samples. Skipping baseline subtraction.");
    else
        b = mean(Y(bMask, :), 1, 'omitnan');
        Y = Y - b;  % implicit expansion
    end
end

% -----------------------------
% Optional: smoothing
% -----------------------------
if opt.SmoothS > 0
    w = max(1, round(opt.SmoothS * Fs));
    if w > 1
        Y = movmean(Y, w, 1, 'omitnan');
    end
end

% -----------------------------
% Summary stats
% -----------------------------
peth_mean = mean(Y, 2, 'omitnan');
peth_sem  = std(Y, 0, 2, 'omitnan') ./ sqrt(nTrials);

% -----------------------------
% Output
% -----------------------------
out = struct();
out.t_rel = t_rel;
out.Y = Y;
out.peth_mean = peth_mean;
out.peth_sem = peth_sem;
out.nTrials = nTrials;
out.align_field = alignField;
out.align_times = alignTimes_kept;
out.keepTrials = keep;

out.meta = struct();
out.meta.stream_uid = streamRow.stream_uid;
out.meta.session_uid = streamRow.session_uid;
if ismember('animal_id', streamRow.Properties.VariableNames)
    out.meta.animal_id = streamRow.animal_id;
end
if ismember('cell_type', streamRow.Properties.VariableNames)
    out.meta.cell_type = streamRow.cell_type;
end
if ismember('go_is_high', streamRow.Properties.VariableNames)
    out.meta.go_is_high = streamRow.go_is_high;
end

% -----------------------------
% Plot
% -----------------------------
if opt.DoPlot
    figure('Color','w'); hold on;
    plot(t_rel, peth_mean, 'LineWidth', 2);
    % SEM band
    x = t_rel; y1 = peth_mean - peth_sem; y2 = peth_mean + peth_sem;
    fill([x; flipud(x)], [y1; flipud(y2)], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    xline(0, '--');
    xlabel(sprintf('Time from %s (s)', alignField), 'Interpreter','none');
    ylabel('Debleached \DeltaF/F (a.u.)');
    title(sprintf('Stream %s | Session %s | n=%d', string(out.meta.stream_uid), string(out.meta.session_uid), nTrials), ...
        'Interpreter','none');
    grid on; box off;
end
end