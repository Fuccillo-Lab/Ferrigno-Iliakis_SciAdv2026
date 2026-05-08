function h = plot_resid_population(allOUT, varargin)
%PLOT_RESID_POPULATION  Plot population residual PSTHs (animal-averaged).
%
% Parameters (name/value):
%   'Event'    : "tone" (default) or "trialStart"
%   'CellType' : "a2a" / "d1" / etc (required)
%
% For tone conditions (choose ONE of these, or leave empty for "all"):
%   'Tone'     : "all" | "go" | "nogo" | "high" | "low" |
%               "high_go" | "low_go" | "high_nogo" | "low_nogo"
%
% For outcome stratification (tone or trialStart):
%   'Outcome'      : "hit"|"fa"|"cr"|"miss" (optional)
%   'PrevOutcome'  : "hit"|"fa"|"cr"|"miss" (optional)
%
% Plot controls:
%   'ShowSEM'  : true/false (default false)
%   'LineWidth': default 2
%   'Label'    : legend label (default auto)
%
% Returns:
%   h: line handle (and if ShowSEM, also returns patch handle via h.UserData.semPatch)

p = inputParser;
p.addParameter('Event', "tone");  % "tone" | "tone_base" | "tone_LW" | "trialStart"
p.addParameter('CellType', "");
p.addParameter('Tone', "all");
p.addParameter('Outcome', "");
p.addParameter('PrevOutcome', "");
p.addParameter('ShowSEM', true);
p.addParameter('LineWidth', 2);
p.addParameter('Label', "");
p.addParameter('Color', []);
p.addParameter('ColorMode', "auto");  % "auto" | "cell" | "tone" | "outcome"
p.parse(varargin{:});
opt = p.Results;
% Backwards compat: "tone" means the original residual (trialStart+outcome removed)
if lower(string(opt.Event)) == "tone"
    opt.Event = "tone_base";
end


if opt.CellType == ""
    error('plot_resid_population: CellType is required (e.g., "a2a" or "d1").');
end

% collect streams matching cell type
S = allOUT(~cellfun('isempty', allOUT));
if isempty(S), error('No non-empty entries in allOUT.'); end

celltype = arrayfun(@(k) string(S{k}.cell_type), 1:numel(S))';
keep = lower(celltype) == lower(string(opt.CellType));
S = S(keep);
if isempty(S)
    error('No streams found for CellType = %s.', string(opt.CellType));
end

% pick x-axis
tvec = [];
ev = string(opt.Event);          % KEEP CASE for fieldnames
ev_lc = lower(ev);               % only for comparisons

for k = 1:numel(S)
    if startsWith(ev_lc, "tone")
        tvec = S{k}.t_tone;
    else
        tvec = S{k}.t_trialStart;
    end

    if ~isempty(tvec), break; end
end
if isempty(tvec), error('Could not find time vector for requested event.'); end

% per-stream trace getter
get_trace = @(O) get_stream_trace(O, opt);


% build matrix of per-stream PSTHs (T x nValidStreams) robustly
Ycells = {};
animals = strings(0,1);

for k = 1:numel(S)
    yk = get_trace(S{k});
    if isempty(yk), continue; end
    yk = double(yk(:));

    % enforce correct length
    if numel(yk) ~= numel(tvec)
        warning('Skipping stream %s: PSTH length %d != tvec length %d', ...
            string(S{k}.stream_uid), numel(yk), numel(tvec));
        continue;
    end

    if all(isnan(yk)), continue; end

    Ycells{end+1} = yk; %#ok<AGROW>
    animals(end+1,1) = string(S{k}.animal_id); %#ok<AGROW>
end

if isempty(Ycells)
    error('No valid traces for the requested condition (Event=%s, Tone=%s, Outcome=%s, PrevOutcome=%s).', ...
        opt.Event, opt.Tone, opt.Outcome, opt.PrevOutcome);
end

Y = cat(2, Ycells{:});   % [T x nValidStreams]
animal = animals;





% animal-average: average streams/hemis within animal, then mean/SEM across animals
[grp, ~, gidx] = unique(animal);
A = nan(size(Y,1), numel(grp));
for g = 1:numel(grp)
    A(:,g) = mean(Y(:,gidx==g), 2, 'omitnan');
end

mu  = mean(A, 2, 'omitnan');
sem = std(A, 0, 2, 'omitnan') / sqrt(size(A,2));

% label
if opt.Label ~= ""
    lab = opt.Label;
else
    lab = default_label(opt);
end

col = resolve_color(opt);

if isempty(col)
    h = plot(tvec, mu, 'LineWidth', opt.LineWidth, 'DisplayName', lab);
else
    h = plot(tvec, mu, 'LineWidth', opt.LineWidth, ...
        'Color', col, 'DisplayName', lab);
end

if opt.ShowSEM
    % shaded SEM (inherits current line color)
    c = h.Color;
    x = tvec(:);
    y1 = (mu - sem);
    y2 = (mu + sem);
    hp = fill([x; flipud(x)], [y1; flipud(y2)], c, ...
        'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility','off');
    h.UserData.semPatch = hp;
end

% enforce requested xlim suggestion if you want:
% xlim([-1 2]);

end

% -------------------------------------------------------------------------
function y = get_stream_trace(O, opt)

evRaw = string(opt.Event);          % preserve case, e.g. "tone_LW"
evLow = lower(evRaw);

% --- Outcome / PrevOutcome take precedence
if opt.Outcome ~= ""
    key = evRaw + "_byOutcome";
    if isfield(O.psth, key) && isfield(O.psth.(key), opt.Outcome)
        y = O.psth.(key).(opt.Outcome);
    else
        y = [];
    end
    return
end

if opt.PrevOutcome ~= ""
    key = evRaw + "_byPrevOutcome";
    if isfield(O.psth, key) && isfield(O.psth.(key), opt.PrevOutcome)
        y = O.psth.(key).(opt.PrevOutcome);
    else
        y = [];
    end
    return
end

% --- Tone-like events
if startsWith(evLow, "tone")
    t = string(opt.Tone);

    % IMPORTANT: your pipeline stores tone_all_BASE/LW (not tone_BASE/LW_all)
    if t == "all"
        if evLow == "tone" || evLow == "tone_base"
            keyAll = "tone_all_base";
        elseif evLow == "tone_lw"
            keyAll = "tone_all_LW";
        else
            keyAll = "tone_all_base"; % fallback
        end

        if isfield(O.psth, keyAll)
            y = O.psth.(keyAll);
        else
            y = [];
        end
        return
    end

    if t == "go" || t == "nogo"
        key = evRaw + "_byAction";   % e.g. "tone_LW_byAction"
        if isfield(O.psth, key) && isfield(O.psth.(key), t)
            y = O.psth.(key).(t);
        else
            y = [];
        end
        return
    end

    if t == "high" || t == "low"
        key = evRaw + "_byFreq";
        if isfield(O.psth, key) && isfield(O.psth.(key), t)
            y = O.psth.(key).(t);
        else
            y = [];
        end
        return
    end

    if any(t == ["high_go","low_go","high_nogo","low_nogo"])
        key = evRaw + "_byActionFreq";
        if isfield(O.psth, key) && isfield(O.psth.(key), t)
            y = O.psth.(key).(t);
        else
            y = [];
        end
        return
    end
end

% --- trialStart
if lower(string(opt.Event)) == "trialstart"
    y = O.psth.trialStart_all;
else
    y = [];
end
end


% -------------------------------------------------------------------------
function lab = default_label(opt)
lab = string(opt.CellType) + " " + string(opt.Event);
lab = replace(lab, "tone_base", "tone (resid: TS+out)");
lab = replace(lab, "tone_LW",   "tone (resid: TS+out+lick+RW)");


if opt.Outcome ~= ""
    lab = lab + " " + string(opt.Outcome);
elseif opt.PrevOutcome ~= ""
    lab = lab + " prev:" + string(opt.PrevOutcome);
elseif opt.Event=="tone"
    lab = lab + " " + string(opt.Tone);
end
end


function col = resolve_color(opt)
C = my_plot_colors();

% explicit override always wins
if ~isempty(opt.Color)
    col = opt.Color;
    return
end

mode = lower(string(opt.ColorMode));

switch mode
    case "cell"
        ct = lower(string(opt.CellType));
        if isfield(C.cell, ct)
            col = C.cell.(ct);
        else
            col = [];
        end

    case "outcome"
        if opt.Outcome ~= ""
            oc = lower(string(opt.Outcome));
            if isfield(C.outcome, oc)
                col = C.outcome.(oc);
                return
            end
        end
        col = [];

    case "tone"
        t = lower(string(opt.Tone));
        if t == "go" || t == "nogo"
            col = C.action.(t);
        elseif t == "high" || t == "low"
            col = C.freq.(t);
        elseif contains(t,"high")
            col = C.freq.high;
        elseif contains(t,"low")
            col = C.freq.low;
        else
            col = [];
        end

    otherwise  % "auto"
        % Priority order:
        % outcome > tone > cell type
        if opt.Outcome ~= ""
            oc = lower(string(opt.Outcome));
            if isfield(C.outcome, oc)
                col = C.outcome.(oc);
                return
            end
        end
        if opt.Tone ~= "" && opt.Tone ~= "all"
            t = lower(string(opt.Tone));
            if t == "go" || t == "nogo"
                col = C.action.(t);
                return
            elseif t == "high" || t == "low"
                col = C.freq.(t);
                return
            elseif contains(t,"high")
                col = C.freq.high;
                return
            elseif contains(t,"low")
                col = C.freq.low;
                return
            end
        end
        ct = lower(string(opt.CellType));
        if isfield(C.cell, ct)
            col = C.cell.(ct);
        else
            col = [];
        end
end
end

function C = my_plot_colors()
% All colors normalized to [0,1]

C.cell.a2a = [255,51,153] / 255;
C.cell.d1  = [51,51,153]  / 255;

C.outcome.hit  = [0.20 0.65 0.35];
C.outcome.miss = [0.20 0.70 0.75];
C.outcome.fa   = [0.80 0.25 0.30];
C.outcome.cr   = [0.35 0.30 0.70];

C.action.go   = [0.25 0.60 0.40];
C.action.nogo = [0.75 0.30 0.30];

C.freq.high = [0.25 0.70 0.75];
C.freq.low  = [0.90 0.65 0.20];
end
