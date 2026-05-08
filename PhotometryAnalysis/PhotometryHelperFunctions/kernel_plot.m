function S = kernel_plot(KD, varargin)
% kernel_plot
% Plot mean±SEM of a kernel or linear combination from KD (built by kernel_build_dataset).
%
% Examples:
%   kernel_plot(KD,'Which',"tone_main");
%   kernel_plot(KD,'Which',["tone_main","tone_F"], 'Weights',[1 0.5]);  % high-tone condition if your tone_F is coded ±0.5
%   kernel_plot(KD,'Which',"out_FA",'ApplyFARule',true,'MinNFA',20);
%   kernel_plot(KD,'Which',"tone_F",'MapToneFTo',"goTone");  % align tone_F across go_is_high mapping
%
% Options:
p = inputParser;
p.addParameter('Which', "tone_main", @(x) isstring(x) || ischar(x));
p.addParameter('Weights', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('Title', "", @(x) isstring(x) || ischar(x));
p.addParameter('ApplyFARule', false, @islogical);
p.addParameter('MinNFA', 0, @(x) isnumeric(x) && isscalar(x)); %%EI, 24/02/2026: I had this set to 5!
p.addParameter('MapToneFTo', "none", @(x) any(strcmpi(string(x),["none","goTone","nogoTone","acousticHighMinusLow"])));
p.addParameter('GoIsHigh', "any", @(x) ...
    (isstring(x) || ischar(x) || (isnumeric(x) && isscalar(x))) && ...
    any(strcmpi(string(x),["any","high","low"])) || any(x==[0 1]));
p.addParameter('DoPlot', true, @islogical);
p.addParameter('Color', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==3));
p.addParameter('FaceAlpha', 0.15, @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1);
p.addParameter('LineWidth', 2, @(x) isnumeric(x) && isscalar(x) && x>0);
p.parse(varargin{:});
opt = p.Results;

which = string(opt.Which);
if numel(which)==1
    which = which(:);
end
if isempty(opt.Weights)
    w = ones(numel(which),1);
else
    w = opt.Weights(:);
    assert(numel(w)==numel(which), "Weights must match Which length.");
end

rows = KD.rows;

% --- Filter by go_is_high (row-wise) ---
goSel = string(opt.GoIsHigh);

if isnumeric(opt.GoIsHigh)
    goSel = string(opt.GoIsHigh);
end

if any(goSel == ["1","high"])
    keep = arrayfun(@(r) r.go_is_high == 1, rows);
    rows = rows(keep);
elseif any(goSel == ["0","low"])
    keep = arrayfun(@(r) r.go_is_high == 0, rows);
    rows = rows(keep);
end


% FA rule gating
if opt.ApplyFARule && any(which=="out_FA")
    keep = arrayfun(@(r) r.n_fa >= opt.MinNFA, rows);
    rows = rows(keep);
end
assert(~isempty(rows), "No rows after filtering.");

% Determine time axis family
[t, family] = kernel_time_axis(KD, which);

% Build matrix (time x nUnits)
M = [];
for i = 1:numel(rows)
    y = zeros(numel(t),1);

    for j = 1:numel(which)
        nm = which(j);
        v = rows(i).kernels.(nm);

        % Select correct time family slices if needed (should match already)
        % Apply optional mapping for tone_F
        if nm=="tone_F" && string(opt.MapToneFTo)~="none"
            v = map_toneF(v, rows(i).go_is_high, string(opt.MapToneFTo));
        end

        y = y + w(j) * v(:);
    end

    M(:,i) = y; %#ok<AGROW>
end

mu = mean(M,2,'omitnan');
se = std(M,0,2,'omitnan') ./ sqrt(size(M,2));

S = struct();
S.t = t; S.mean = mu; S.sem = se; S.n = size(M,2);
S.M = M;          

if ~opt.DoPlot
    return
end

hold on;

% Resolve color
if isempty(opt.Color)
    h = plot(t, mu, 'LineWidth', opt.LineWidth);
    c = h.Color;
else
    c = opt.Color(:)'; % ensure 1x3
    h = plot(t, mu, 'LineWidth', opt.LineWidth, 'Color', c);
end

% SEM shading: same color, LOWER opacity
fill([t; flipud(t)], [mu-se; flipud(mu+se)], c, ...
    'FaceAlpha', opt.FaceAlpha, 'EdgeColor','none');

xline(0,'--');
grid on; box off;
xlabel(sprintf('Time from %s (s)', family), 'Interpreter','none');
ylabel('Kernel amplitude (a.u.)');

ttl = string(opt.Title);
if strlength(ttl)==0
    if numel(which)==1
        ttl = sprintf("%s (n=%d units; %s)", which(1), S.n, KD.unit);
    else
        expr = strjoin(arrayfun(@(j) sprintf("%+.2f*%s", w(j), which(j)), 1:numel(which), 'UniformOutput', false), " ");
        ttl = sprintf("%s (n=%d units; %s)", expr, S.n, KD.unit);
    end
end
title(ttl, 'Interpreter','none');

end

% ---------- helpers ----------

function [t, family] = kernel_time_axis(KD, which)
% Determine which lag family to use
% trialStart -> KD.t.trialStart
% tone_*     -> KD.t.tone
% out_*      -> KD.t.outcome
nm = which(1);
if nm=="trialStart"
    t = KD.t.trialStart; family = "trialStart";
elseif startsWith(nm,"tone")
    t = KD.t.tone; family = "tone";
elseif startsWith(nm,"out_")
    t = KD.t.outcome; family = "outcome";
elseif nm=="firstLick"
    % in your current fits lags doesn't include firstLick; avoid plotting or define separately
    error("No lag family for firstLick in fits(1).lags. Add it if you want to plot firstLick.");
else
    error("Unknown kernel name: %s", nm);
end
end

function v2 = map_toneF(v, go_is_high, mode)
% tone_F is coded as High(+0.5) vs Low(-0.5) acoustics.
% If you want to align across go mappings:
%   go_is_high==1 => Go tone = High, NoGo tone = Low
%   go_is_high==0 => Go tone = Low,  NoGo tone = High
%
% We return a sign-flipped version so that positive always means "Go-associated tone higher than NoGo-associated tone"
%
% mode:
%   "goTone"   : returns a kernel where + means Go-tone > NoGo-tone
%   "nogoTone" : returns + means NoGo-tone > Go-tone (just negative of goTone)
%   "acousticHighMinusLow": no change (explicit)
if mode=="acousticHighMinusLow"
    v2 = v;
    return
end

% sign to convert acoustic High-Low into Go-NoGo depending on mapping
% If go_is_high==1: Go=High => Go-NoGo == High-Low => sign +1
% If go_is_high==0: Go=Low  => Go-NoGo == Low-High => sign -1
sgn = 1;
if go_is_high==0
    sgn = -1;
end

if mode=="goTone"
    v2 = sgn * v;
elseif mode=="nogoTone"
    v2 = -sgn * v;
else
    v2 = v;
end
end