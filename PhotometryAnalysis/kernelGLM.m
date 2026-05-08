%Kernel GLM
%We would like to acknowledge the use of OpenAI’s ChatGPT (versions 4o, 5, 
% 5.1, 5.2) as an auxiliary tool for code optimization.
%% Import data
streamsPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\streams.csv";
trialsPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\trials.csv";
sessionsPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\sessions.csv";
licksPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\licks.csv";
signalsPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\signals2.h5";
streams = readtable(streamsPath, "TextType", "string");
trials = readtable(trialsPath, "TextType", "string");
sessions = readtable(sessionsPath, "TextType", "string");
licks = readtable(licksPath, "TextType", "string");

% Exclude Nrxn1a
streams = streams(streams.nrxn ==0,:);
trials = trials(trials.nrxn == 0,:);
sessions = sessions(sessions.nrxn ==0,:);
licks = licks(licks.nrxn ==0,:);
%

% Exclude mistargeted animals
%DATA QUALITY/CLEANING EXCLUSIONS + REASONS:
% Exclude:
% o	a2ac213 right - Reason: no right fiber
% o	d1c176 left - Reason: mistargeted (see histology)
% o	d1c209 left - Reason: mistargeted (see histology)
% o	d1c217 left - Reason: mistargeted (see histology)
exclusions = table( ...
    ["a2ac213"; "d1c176"; "d1c209"; "d1c217"], ...
    ["R";       "L";       "L";       "L"], ...
    ["no right fiber";
    "mistargeted (histology)";
    "mistargeted (histology)";
    "mistargeted (histology)"], ...
    'VariableNames', {'animal_id','side','reason'});
streams.include = true(height(streams),1);
streams.exclude_reason = strings(height(streams),1);

for k = 1:height(exclusions)
    mask = (streams.animal_id == exclusions.animal_id(k)) & ...
        (streams.side      == exclusions.side(k));
    streams.include(mask) = false;
    streams.exclude_reason(mask) = exclusions.reason(k);
end

streams = streams(streams.include == 1,:);
% no need to exclude trials or sessions because these are all unilateral
% exclusions. IF THIS CHANGES, WE NEED TO RECODE.


%% ===== Kernel-GLM config (edit here only) =====
cfg = struct();

% H5 + signal choice (IMPORTANT: use debleached, not normalized/zscored)
cfg.h5file = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\signals2.h5";
cfg.signal_field = "path_debleached";   % <-- streams.(cfg.signal_field); debleached is the non-z-scored one. normalized is the z-scored one
cfg.time_field   = "path_time";

% Sampling / binning
cfg.dt = 0.025;               % seconds; 0.025 = 40Hz, our recording rate
cfg.time_units = "seconds";  % for sanity

% Effect coding (±0.5)
cfg.code.high  = +0.5; cfg.code.low  = -0.5;
cfg.code.nogo  = +0.5; cfg.code.go   = -0.5;

% Event kernel windows (seconds, relative to event)
cfg.win.trialStart = [-1.0, 2.0]; %ITI length is predictable
cfg.win.tone       = [0.0, 1.5];
cfg.win.outcome    = [0.0, 2.0];   % applies to outcome+ and outcome-
cfg.win.firstLick  = [-0.2, 1.2];

% Basis sizes (splines) per kernel (easy to tune)
cfg.K.trialStart = 7;
cfg.K.tone       = 6;    % for 1.5s you could use 5–6; keep 6 unless you see wiggle
cfg.K.outcome    = 6;
cfg.K.firstLick  = 6;

% Lick-rate definition (continuous OR binarized covariate - modify below)
cfg.lickRate.win_s = 0.3;         % 200 ms causal window
cfg.lickRate.causal = false;       % use past-only window; if false, looks at licks between t-(win_s/2) and t+(win_s/2).
cfg.lickRate.zscore = true;       % recommended for ridge stability; ignored when binarized
cfg.lickRate.clip_prctile = 99.5; % optional: clip extreme bursts
cfg.lickRate.binarize = false;     % reports out licking state - i.e., licking vs. not licking currently

% Withholding definition (trial-anchored state)
cfg.withhold.value = 1;               % boxcar amplitude (keep 1, don't effect-code this)


% Ridge regularization + CV
cfg.ridge.do_cv = true;
cfg.ridge.kfold = 5;
cfg.ridge.blocked_time_cv = true;   % contiguous time blocks
cfg.ridge.lambdas = logspace(0, 6, 50);  % editable

% Which predictors to include
cfg.use.trialStart = true;
cfg.use.tone_main  = true;
cfg.use.tone_F     = true; %F is frequency (high / low)
cfg.use.tone_I     = false; %I is instruction (go / nogo) %REDUNDANT WITH F, IT'S EITHER F or -F -- degenerate
cfg.use.tone_FI    = false; %REDUNDANT WITH F, degenerate
cfg.use.outcome_hit = true;   % reward==1
cfg.use.outcome_neg = false;   % reward==0
cfg.use.outcome_FA = true;
cfg.use.outcome_CRMiss = true;
cfg.use.firstLick   = false;
cfg.use.lickRate = true;
cfg.use.withholdingBoxcar = false;

cfg.basis.type = "rcos";   % "rcos" (default) or "spline" later if you want
cfg.addIntercept = true;   % global intercept column (recommended)




%% RUN KERNEL GLM ACROSS ALL STREAMS
% Assumes you already have in workspace:
%   streams (table), trials (table), cfg (struct)
% And helper functions on path:
%   make_rcos_basis, event_kernel_block, tone_blocks, trial_modulators,
%   block_idx, reconstruct_kernel

assert(isfield(cfg,'h5file') && isfile(cfg.h5file), "cfg.h5file not found.");
if ~isfield(cfg,'addIntercept'); cfg.addIntercept = true; end

% Which streams to run
runMask = (streams.include==1) & (streams.has_signal==1);
idxList = find(runMask);
nS = numel(idxList);

fprintf("KernelGLM: running %d streams...\n", nS);

% pick any representative stream index
i0 = idxList(1);
stream = streams(i0,:);
row = licks(licks.session_uid == stream.session_uid, :);
lickTimes = row.lick_times;   % numeric vector
template = fit_one_stream_kernelGLM(streams(i0,:), trials, cfg,lickTimes);

fits = repmat(template, nS, 1);


for si = 1:nS
    i = idxList(si);
    stream = streams(i,:);
    row = licks(licks.session_uid == stream.session_uid, :);
    lickTimes = row.lick_times;   % numeric vector

    try
        fitToFit = fit_one_stream_kernelGLM(stream, trials, cfg, lickTimes);
        fits(si) = fitToFit;
        fprintf("[%d/%d] OK  %s  (%s %s)\n", si, nS, ...
            string(stream.stream_uid), string(stream.animal_id), string(stream.cell_type));

    catch ME
        fprintf("[%d/%d] FAIL %s : %s\n", si, nS, ...
            string(stream.stream_uid), ME.message);

        fits(si) = struct();
        fits(si).failed = true;
        fits(si).error = ME;
        fits(si).meta = struct( ...
            'stream_uid', string(stream.stream_uid), ...
            'session_uid', string(stream.session_uid), ...
            'animal_id',  string(stream.animal_id), ...
            'cell_type',  string(stream.cell_type));
    end
end


% Build a compact summary table
summary = build_kernelGLM_summary(fits);


% Save
fitsLNonCausal = fits;
outFile = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\kernelGLM_fitsLNonCausal_allStreams_debleached.mat";
save(outFile, "fitsLNonCausal", "summary", "cfg", "-v7.3");
fprintf("Saved: %s\n", outFile);




%% Post hoc filter to separate Training vs. ALL-Expert
analyzeWhich = "training"; %toggle "training" or "expert"
excelPath = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\General_workspaces\Day1ExpertDates.xlsx";

filter_sessions_day1_expert(excelPath, analyzeWhich, fits, licks, sessions, streams, summary, trials, ...
    "assignInCaller", true);

%% Review kernels
figure;
for i = 1:numel(fits)
    clf;
    t = tiledlayout(2,3, ...
        'TileSpacing','compact', ...
        'Padding','compact');

    title(t, sprintf('Fit %d', i));

    nexttile; plot(fits(i).kernels.trialStart); title("trialStart");
    nexttile; plot(fits(i).kernels.tone_main);  title("tone main");
    nexttile; plot(fits(i).kernels.tone_F);      title("tone F");
    % nexttile; plot(fits(i).kernels.tone_I);      title("tone I");
    % nexttile; plot(fits(i).kernels.tone_FI);     title("tone FI");
    nexttile; plot(fits(i).kernels.out_hit);     title("out hit");
    nexttile; plot(fits(i).kernels.out_FA);     title("out FA");
    nexttile; plot(fits(i).kernels.out_CRMiss);     title("out CR Miss");
    %nexttile; plot(fits(i).kernels.firstLick);   title("firstLick");

    disp("Press any key or click to continue...");
    waitforbuttonpress;
end

%% Plot outputs
%build datasets for each cell type
KDa2a = kernel_build_dataset(fits, sessions, 'CellType',"a2a", 'Unit',"animal_hemi", 'UseOnlyGood',false);
KDd1  = kernel_build_dataset(fits, sessions, 'CellType',"d1",  'Unit',"animal_hemi", 'UseOnlyGood',false);

% Define colors for plotting
a2aColor = [255,51,153];
d1Color = [51,51,153];

hitColor = [0.20 0.65 0.35];
missColor = [0.20 0.70 0.75];
FAColor = [0.80 0.25 0.30];
CRColor = [0.35 0.30 0.70];

goColor = [0.25 0.60 0.40];
nogoColor = [0.75 0.30 0.30];

highToneColor = [0.25 0.70 0.75];
lowToneColor  = [0.90 0.65 0.20];

C = my_plot_colors();

%% plot tone kernels by high / low
figure;
tiledlayout(1,2);

nexttile;
S_d1_hi = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'Title',"d1 High tone",'Color', highToneColor,   'FaceAlpha', 0.15);
S_d1_lo = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5], 'Title',"d1 Low tone",'Color', lowToneColor,   'FaceAlpha', 0.15);
text(0.98, 0.95, 'High Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', highToneColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'Low Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lowToneColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
grid off;
S_hi = S_d1_hi;
S_lo = S_d1_lo;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;

ci_lo_d1_fr = muD-thr;
ci_hi_d1_fr = muD + thr;
muD_d1_fr = muD;

yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

nexttile;
S_a2a_hi = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'Title',"a2a High tone",'Color', highToneColor,   'FaceAlpha', 0.15);
S_a2a_lo = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5], 'Title',"a2a Low tone",'Color', lowToneColor,   'FaceAlpha', 0.15);
text(0.98, 0.95, 'High Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', highToneColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'Low Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lowToneColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
grid off;
S_hi = S_a2a_hi;
S_lo = S_a2a_lo;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;

ci_lo_a2a_fr = muD-thr;
ci_hi_a2a_fr = muD + thr;
muD_a2a_fr = muD;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%% plot tone kernels by go / no go
figure;
tiledlayout(1,2);

nexttile;
S_d1_go = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_d1_nogo = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
S_hi = S_d1_nogo;
S_lo = S_d1_go;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;

ci_lo_d1 = muD-thr;
ci_hi_d1 = muD + thr;
muD_d1 = muD;

yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

nexttile;
S_a2a_go = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_a2a_nogo = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
S_hi = S_a2a_nogo;
S_lo = S_a2a_go;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;
ci_lo_a2a = muD-thr;
ci_hi_a2a = muD + thr;
muD_a2a = muD;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%% plot diffs
t = 0:0.025:1.5;
t = t';
W = (t >= 0) & (t <= 0.5);


figure; tiledlayout(1,2);
nexttile;hold on

plot(t, muD_d1_fr, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_d1_fr; flipud(ci_hi_d1_fr)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('High − Low (a.u.)')
title("D1+ SPN");
box off; grid off
xlim([0,1]);

nexttile;hold on

plot(t, muD_a2a_fr, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_a2a_fr; flipud(ci_hi_a2a_fr)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('High − Low (a.u.)')
title("A2A+ SPN");
box off; grid off
xlim([0,1]);


figure; tiledlayout(1,2);
nexttile;hold on

plot(t, muD_d1, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_d1; flipud(ci_hi_d1)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('NoGo − Go (a.u.)')
title("D1+ SPN");
box off; grid off
xlim([0,1]);




nexttile;hold on

plot(t, muD_a2a, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_a2a; flipud(ci_hi_a2a)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('NoGo − Go (a.u.)')
title("A2A+ SPN");
box off; grid off
xlim([0,1]);

%% AUC analysis - terciles, per animal

%go no go D1, A2A
[dD1gonogo,dD1gonogo_p] = getAUCsTerciles(S_d1_go.M,S_d1_nogo.M);
[dA2Agonogo,dA2Agonogo_p] = getAUCsTerciles(S_a2a_go.M,S_a2a_nogo.M);

%hi lo D1, A2A
[dD1hilo,dD1hilo_p] = getAUCsTerciles(S_d1_hi.M,S_d1_lo.M);
[dA2Ahilo,dA2Ahilo_p] = getAUCsTerciles(S_a2a_hi.M,S_a2a_lo.M);

% ---- Inputs ----
X{1} = dD1gonogo;  P{1} = dD1gonogo_p;  titles{1} = 'D1: Go - NoGo';
X{2} = dA2Agonogo; P{2} = dA2Agonogo_p; titles{2} = 'A2A: Go - NoGo';
X{3} = dD1hilo;    P{3} = dD1hilo_p;    titles{3} = 'D1: Hi - Lo';
X{4} = dA2Ahilo;   P{4} = dA2Ahilo_p;   titles{4} = 'A2A: Hi - Lo';

figure('Color','w');
tiledlayout(1,4,'TileSpacing','compact','Padding','compact');
%
% % Optional: consistent y-lims across panels
% allVals = cell2mat(cellfun(@(a) a(:), X, 'UniformOutput', false));
% yPad = 0.08 * range(allVals); if yPad==0, yPad = 0.1; end
% yL = [min(allVals)-yPad, max(allVals)+yPad];

for i = 1:4
    nexttile;
    plotDeltaAUCTerciles_barScatter(X{i}, P{i}, titles{i}, []);
end

%% AUC analysis - two bins, stream-level w/mixed effects
KDd1_stream = KD_fromFitsStreams(fits, streams, KDd1, 'CellType',"d1");
KDa2a_stream = KD_fromFitsStreams(fits, streams, KDa2a, 'CellType',"a2a");



% now RECOMPUTE these using the stream KDs (not the old KDs)
S_d1_go   = kernel_plot(KDd1_stream,  'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"goTone",   'DoPlot',false);
S_d1_nogo = kernel_plot(KDd1_stream,  'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"nogoTone", 'DoPlot',false);

S_d1_hi   = kernel_plot(KDd1_stream,  'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"acousticHighMinusLow", 'DoPlot',false);
S_d1_lo   = kernel_plot(KDd1_stream,  'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"acousticHighMinusLow", 'DoPlot',false);

S_a2a_go   = kernel_plot(KDa2a_stream,'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"goTone",   'DoPlot',false);
S_a2a_nogo = kernel_plot(KDa2a_stream,'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"nogoTone", 'DoPlot',false);

S_a2a_hi   = kernel_plot(KDa2a_stream,'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'MapToneFTo',"acousticHighMinusLow", 'DoPlot',false);
S_a2a_lo   = kernel_plot(KDa2a_stream,'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"acousticHighMinusLow", 'DoPlot',false);


t = S_d1_go.t;              % don’t hardcode
t0 = 0.15; tEnd = 1.15;
tMid = (t0 + tEnd)/2;       % or choose a biologically motivated split

dD1gonogo   = getAUCs2Bins(t, t0, tMid, tEnd, S_d1_go.M,   S_d1_nogo.M);
dA2Agonogo  = getAUCs2Bins(t, t0, tMid, tEnd, S_a2a_go.M,  S_a2a_nogo.M);
dD1hilo     = getAUCs2Bins(t, t0, tMid, tEnd, S_d1_hi.M,   S_d1_lo.M);
dA2Ahilo    = getAUCs2Bins(t, t0, tMid, tEnd, S_a2a_hi.M,  S_a2a_lo.M);


animal_id = string({KDd1_stream.rows.animal_id})';
pD1gonogo = pvalsLME_vsZero(dD1gonogo, animal_id);
pD1hilo = pvalsLME_vsZero(dD1hilo, animal_id);
animal_id = string({KDa2a_stream.rows.animal_id})';
pA2Agonogo = pvalsLME_vsZero(dA2Agonogo, animal_id);
pA2Ahilo = pvalsLME_vsZero(dA2Ahilo, animal_id);

p_all = [ ...
    pD1gonogo(:); ...
    pA2Agonogo(:); ...
    pD1hilo(:); ...
    pA2Ahilo(:) ...
];

[q_all, sig_all, pcrit] = bh_fdr(p_all, 0.05);

q_mat  = reshape(q_all,  [2 4]);   % rows: early/late, cols: panels in the same order
sig_mat = reshape(sig_all,[2 4]);

% ---- Inputs (BH-corrected) ----
X{1} = dD1gonogo;  P{1} = q_mat(:,1); titles{1} = 'D1: Go - NoGo';
X{2} = dA2Agonogo; P{2} = q_mat(:,2); titles{2} = 'A2A: Go - NoGo';
X{3} = dD1hilo;    P{3} = q_mat(:,3); titles{3} = 'D1: Hi - Lo';
X{4} = dA2Ahilo;   P{4} = q_mat(:,4); titles{4} = 'A2A: Hi - Lo';


animal_d1  = string({KDd1_stream.rows.animal_id})';
animal_a2a = string({KDa2a_stream.rows.animal_id})';
figure('Color','w');
tiledlayout(1,4,'TileSpacing','compact','Padding','compact');

nexttile; plotDeltaAUC2Bins_barScatter_animals(dD1gonogo,  animal_d1,  P{1}, titles{1}, []);
nexttile; plotDeltaAUC2Bins_barScatter_animals(dA2Agonogo, animal_a2a, P{2}, titles{2}, []);
nexttile; plotDeltaAUC2Bins_barScatter_animals(dD1hilo,    animal_d1,  P{3}, titles{3}, []);
nexttile; plotDeltaAUC2Bins_barScatter_animals(dA2Ahilo,   animal_a2a, P{4}, titles{4}, []);
fprintf("\nNOTE!!! The p values shown here are actually BH-corrected q-values across all comparisons\n");

p_all = [ ...
    pD1gonogo(:); ...
    pA2Agonogo(:)];

[q_all, sig_all, pcrit] = bh_fdr(p_all, 0.05);

q_mat  = reshape(q_all,  [2 2]);   % rows: early/late, cols: panels in the same order
sig_mat = reshape(sig_all,[2 2]);

% ---- Inputs (BH-corrected) ----
X{1} = dD1gonogo;  P{1} = q_mat(:,1); titles{1} = 'D1: Go - NoGo';
X{2} = dA2Agonogo; P{2} = q_mat(:,2); titles{2} = 'A2A: Go - NoGo';



animal_d1  = string({KDd1_stream.rows.animal_id})';
animal_a2a = string({KDa2a_stream.rows.animal_id})';
figure('Color','w');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

nexttile; plotDeltaAUC2Bins_barScatter_animals(dD1gonogo,  animal_d1,  P{1}, titles{1}, []);
nexttile; plotDeltaAUC2Bins_barScatter_animals(dA2Agonogo, animal_a2a, P{2}, titles{2}, []);

fprintf("\nNOTE!!! The p values shown here are actually BH-corrected q-values across all comparisons\n");

%
p_all = [ ...
    pD1hilo(:); ...
    pA2Ahilo(:)];

[q_all, sig_all, pcrit] = bh_fdr(p_all, 0.05);

q_mat  = reshape(q_all,  [2 2]);   % rows: early/late, cols: panels in the same order
sig_mat = reshape(sig_all,[2 2]);

% ---- Inputs (BH-corrected) ----
X{1} = dD1hilo;  P{1} = q_mat(:,1); titles{1} = 'D1: Hi - Lo';
X{2} = dA2Ahilo; P{2} = q_mat(:,2); titles{2} = 'A2A: Ho - Lo';



animal_d1  = string({KDd1_stream.rows.animal_id})';
animal_a2a = string({KDa2a_stream.rows.animal_id})';
figure('Color','w');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

nexttile; plotDeltaAUC2Bins_barScatter_animals(dD1hilo,  animal_d1,  P{1}, titles{1}, []);
nexttile; plotDeltaAUC2Bins_barScatter_animals(dA2Ahilo, animal_a2a, P{2}, titles{2}, []);

fprintf("\nNOTE!!! The p values shown here are actually BH-corrected q-values across all comparisons\n");


%% Disaggregate go vs. no go kernels by tone counterbalancing condition
figure;
tiledlayout(2,2);

%D1 high go
nexttile;
S_d1_go_h = kernel_plot(KDd1, 'Which', ["tone_main","tone_F"],'Weights', [1 0.5],'MapToneFTo', "goTone",'GoIsHigh', "high", 'Title', "Go (High tone only)", 'Color', goColor, 'FaceAlpha', 0.15);
S_d1_nogo_h = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'GoIsHigh', "high",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go (High)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go (Low)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
S_hi = S_d1_nogo_h;
S_lo = S_d1_go_h;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;

ci_lo_d1 = muD-thr;
ci_hi_d1 = muD + thr;
muD_d1 = muD;

yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%D1 low go
nexttile;
S_d1_go_l = kernel_plot(KDd1, 'Which', ["tone_main","tone_F"],'Weights', [1 0.5],'MapToneFTo', "goTone",'GoIsHigh', "low", 'Title', "Go (High tone only)", 'Color', goColor, 'FaceAlpha', 0.15);
S_d1_nogo_l = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'GoIsHigh', "low",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go (Low)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go (High)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
S_hi = S_d1_nogo_l;
S_lo = S_d1_go_l;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;

ci_lo_d1 = muD-thr;
ci_hi_d1 = muD + thr;
muD_d1 = muD;

yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%a2a high go
nexttile;
S_a2a_go_h = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'GoIsHigh', "high", 'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_a2a_nogo_h = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'GoIsHigh', "high", 'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go (high)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go (low)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
S_hi = S_a2a_nogo_h;
S_lo = S_a2a_go_h;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;
ci_lo_a2a = muD-thr;
ci_hi_a2a = muD + thr;
muD_a2a = muD;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%a2a low go
nexttile;
S_a2a_go_l = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'GoIsHigh', "low", 'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_a2a_nogo_l = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'GoIsHigh', "low", 'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go (low)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go (high)', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
S_hi = S_a2a_nogo_l;
S_lo = S_a2a_go_l;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;
ci_lo_a2a = muD-thr;
ci_hi_a2a = muD + thr;
muD_a2a = muD;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

%% just look at all kernels - trial start, tone start, hit, FA, and CR/miss

figure;
tiledlayout(2,6);
nexttile;
kernel_plot(KDd1,'Which',"trialStart",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDd1,'Which',"tone_main",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDd1, 'Which', "tone_F", 'MapToneFTo', "goTone", 'Color', d1Color./255,'FaceAlpha', 0.15,'Title','Tone-Instruction'); %Go-NoGo
nexttile;
kernel_plot(KDd1,'Which',"out_hit",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDd1,'Which',"out_FA",'ApplyFARule',true,'MinNFA',10,'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDd1,'Which',"out_CRMiss",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDa2a,'Which',"trialStart",'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDa2a,'Which',"tone_main",'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDa2a, 'Which', "tone_F", 'MapToneFTo', "goTone", 'Color', d1Color./255,'FaceAlpha', 0.15,'Title','Tone-Instruction'); %Go-NoGo
nexttile;
kernel_plot(KDa2a,'Which',"out_hit",'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDa2a,'Which',"out_FA",'ApplyFARule',true,'MinNFA',10,'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDa2a,'Which',"out_CRMiss",'Color', a2aColor./255,   'FaceAlpha', 0.15);



%% ===== Kernel-GLM CONTROL MODEL!! config (edit here only) =====
cfg = struct();

% H5 + signal choice (IMPORTANT: use debleached, not normalized/zscored)
cfg.h5file = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\signals2.h5";
cfg.signal_field = "path_debleached";   % <-- streams.(cfg.signal_field); debleached is the non-z-scored one. normalized is the z-scored one
cfg.time_field   = "path_time";

% Sampling / binning
cfg.dt = 0.025;               % seconds; 0.025 = 40Hz, our recording rate
cfg.time_units = "seconds";  % for sanity

% Effect coding (±0.5)
cfg.code.high  = +0.5; cfg.code.low  = -0.5;
cfg.code.nogo  = +0.5; cfg.code.go   = -0.5;

% Event kernel windows (seconds, relative to event)
cfg.win.trialStart = [-1.0, 2.0]; %ITI length is predictable
cfg.win.tone       = [0.0, 1.5];
cfg.win.outcome    = [0.0, 2.0];   % applies to outcome+ and outcome-
cfg.win.firstLick  = [-0.2, 1.2];

% Basis sizes (splines) per kernel (easy to tune)
cfg.K.trialStart = 7;
cfg.K.tone       = 6;    % for 1.5s you could use 5–6; keep 6 unless you see wiggle
cfg.K.outcome    = 6;
cfg.K.firstLick  = 6;

% Ridge regularization + CV
cfg.ridge.do_cv = true;
cfg.ridge.kfold = 5;
cfg.ridge.blocked_time_cv = true;   % contiguous time blocks
cfg.ridge.lambdas = logspace(0, 6, 50);  % editable

% Which predictors to include
cfg.use.trialStart = true;
cfg.use.tone_main  = true;
cfg.use.tone_F     = true; %F is frequency (high / low)
cfg.use.tone_I     = false; %I is instruction (go / nogo) %REDUNDANT WITH F, IT'S EITHER F or -F -- degenerate
cfg.use.tone_FI    = false; %REDUNDANT WITH F, degenerate
cfg.use.outcome_hit = false;   % reward==1
cfg.use.outcome_neg = false;   % reward==0
cfg.use.outcome_FA = false;
cfg.use.outcome_CRMiss = false;
cfg.use.firstLick   = false;

cfg.basis.type = "rcos";   % "rcos" (default) or "spline" later if you want
cfg.addIntercept = true;   % global intercept column (recommended)
cfg_B = cfg;

%% RUN KERNEL GLM ACROSS ALL STREAMS
% Assumes you already have in workspace:
%   streams (table), trials (table), cfg (struct)
% And helper functions on path:
%   make_rcos_basis, event_kernel_block, tone_blocks, trial_modulators,
%   block_idx, reconstruct_kernel

assert(isfield(cfg,'h5file') && isfile(cfg.h5file), "cfg.h5file not found.");
if ~isfield(cfg,'addIntercept'); cfg.addIntercept = true; end

% Which streams to run
runMask = (streams.include==1) & (streams.has_signal==1);
idxList = find(runMask);
nS = numel(idxList);

fprintf("KernelGLM: running %d streams...\n", nS);

% pick any representative stream index
i0 = idxList(1);
template = fit_one_stream_kernelGLM(streams(i0,:), trials, cfg);

fitsCtrl = repmat(template, nS, 1);


for si = 1:nS
    i = idxList(si);
    stream = streams(i,:);

    try
        fitToFit = fit_one_stream_kernelGLM(stream, trials, cfg);
        fitsCtrl(si) = fitToFit;
        fprintf("[%d/%d] OK  %s  (%s %s)\n", si, nS, ...
            string(stream.stream_uid), string(stream.animal_id), string(stream.cell_type));

    catch ME
        fprintf("[%d/%d] FAIL %s : %s\n", si, nS, ...
            string(stream.stream_uid), ME.message);

        fitsCtrl(si) = struct();
        fitsCtrl(si).failed = true;
        fitsCtrl(si).error = ME;
        fitsCtrl(si).meta = struct( ...
            'stream_uid', string(stream.stream_uid), ...
            'session_uid', string(stream.session_uid), ...
            'animal_id',  string(stream.animal_id), ...
            'cell_type',  string(stream.cell_type));
    end
end


% Build a compact summary table
summaryCtrl = build_kernelGLM_summary(fitsCtrl);


% Save
outFile = "kernelGLM_fitsCtrl_allStreams_debleached.mat";
save(outFile, "fitsCtrl", "summaryCtrl", "cfg", "-v7.3");
fprintf("Saved: %s\n", outFile);

%% build datasets for each cell type
KDCa2a = kernel_build_dataset(fitsCtrl, sessions, 'CellType',"a2a", 'Unit',"animal_hemi", 'UseOnlyGood',true);
KDCd1  = kernel_build_dataset(fitsCtrl, sessions, 'CellType',"d1",  'Unit',"animal_hemi", 'UseOnlyGood',true);

%% Look at no-outcome-model kernels
% just look at all kernels - trial start, tone start, hit, FA, and CR/miss

figure;
tiledlayout(2,3);
nexttile;
kernel_plot(KDCd1,'Which',"trialStart",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDCd1,'Which',"tone_main",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDCd1,'Which',"tone_F",'Color', d1Color./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDCa2a,'Which',"trialStart",'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDCa2a,'Which',"tone_main",'Color', a2aColor./255,   'FaceAlpha', 0.15);
nexttile;
kernel_plot(KDCa2a,'Which',"tone_F",'Color', a2aColor./255,   'FaceAlpha', 0.15);



%% Go - No Go in NO-OUTCOMES model
%plot tone kernels by go / no go
figure;
tiledlayout(1,2);

nexttile;
S_d1_go = kernel_plot(KDCd1, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_d1_nogo = kernel_plot(KDCd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
S_hi = S_d1_nogo;
S_lo = S_d1_go;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

B = 10000;
[T, nA] = size(D);
boot_mu = nan(T,B);

for b = 1:B
    idx = randi(nA,[nA 1]);
    boot_mu(:,b) = mean(D(:,idx),2,'omitnan');
end

ci_lo_d1_ctrl = prctile(boot_mu,  2.5, 2);
ci_hi_d1_ctrl = prctile(boot_mu, 97.5, 2);
muD_d1_ctrl = muD;

ci_lo_d1_ctrl = muD-thr;
ci_hi_d1_ctrl = muD + thr;


nexttile;
S_a2a_go = kernel_plot(KDCa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);
S_a2a_nogo = kernel_plot(KDCa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
grid off;
text(0.98, 0.95, 'Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'No Go', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
S_hi = S_a2a_nogo;
S_lo = S_a2a_go;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

B = 10000;
[T, nA] = size(D);
boot_mu = nan(T,B);

for b = 1:B
    idx = randi(nA,[nA 1]);
    boot_mu(:,b) = mean(D(:,idx),2,'omitnan');
end

ci_lo_a2a_ctrl = prctile(boot_mu,  2.5, 2);
ci_hi_a2a_ctrl = prctile(boot_mu, 97.5, 2);
muD_a2a_ctrl = muD;

ci_lo_a2a_ctrl = muD-thr;
ci_hi_a2a_ctrl = muD + thr;




%% plot tone kernels by high / low NO OUTCOME ODEL
figure;
tiledlayout(1,2);

nexttile;
S_d1_hi = kernel_plot(KDCd1, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'Title',"d1 High tone",'Color', highToneColor,   'FaceAlpha', 0.15);
S_d1_lo = kernel_plot(KDCd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5], 'Title',"d1 Low tone",'Color', lowToneColor,   'FaceAlpha', 0.15);
text(0.98, 0.95, 'High Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', highToneColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'Low Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lowToneColor,'FontWeight','bold','FontSize', 12);
title('D1+ SPN');
xlim([0,1]);
grid off;
S_hi = S_d1_hi;
S_lo = S_d1_lo;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

B = 10000;
[T, nA] = size(D);
boot_mu = nan(T,B);

for b = 1:B
    idx = randi(nA,[nA 1]);
    boot_mu(:,b) = mean(D(:,idx),2,'omitnan');
end

ci_lo_d1_fr_ctrl = prctile(boot_mu,  2.5, 2);
ci_hi_d1_fr_ctrl = prctile(boot_mu, 97.5, 2);
muD_d1_fr_ctrl = muD;

ci_lo_d1_fr_ctrl = muD-thr;
ci_hi_d1_fr_ctrl = muD + thr;



nexttile;
S_a2a_hi = kernel_plot(KDCa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5], 'Title',"a2a High tone",'Color', highToneColor,   'FaceAlpha', 0.15);
S_a2a_lo = kernel_plot(KDCa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5], 'Title',"a2a Low tone",'Color', lowToneColor,   'FaceAlpha', 0.15);
text(0.98, 0.95, 'High Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', highToneColor,'FontWeight','bold','FontSize', 12);
text(0.98, 0.88, 'Low Frequencies', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lowToneColor,'FontWeight','bold','FontSize', 12);
title('A2A+ SPN');
xlim([0,1]);
grid off;
S_hi = S_a2a_hi;
S_lo = S_a2a_lo;
D = S_hi.M - S_lo.M;    % time × nAnimals
muD = mean(D,2,'omitnan');

B = 10000;
[nT, nA] = size(D);

maxstat = nan(1,B);

for b = 1:B
    sgn = (rand(nA,1) > 0.5)*2 - 1;     % +/-1 per animal
    Dp  = D .* reshape(sgn, 1, []);     % sign-flip columns
    muDp = mean(Dp,2,'omitnan');
    maxstat(b) = max(abs(muDp));
end

thr = prctile(maxstat, 95);
sig = abs(muD) > thr;


yl = ylim;
ybar = yl(2) - 0.02*range(yl);
plot(S_hi.t(sig), ybar*ones(sum(sig),1), 'k.', 'MarkerSize',10);

B = 10000;
[T, nA] = size(D);
boot_mu = nan(T,B);

for b = 1:B
    idx = randi(nA,[nA 1]);
    boot_mu(:,b) = mean(D(:,idx),2,'omitnan');
end

ci_lo_a2a_fr_ctrl = prctile(boot_mu,  2.5, 2);
ci_hi_a2a_fr_ctrl = prctile(boot_mu, 97.5, 2);
muD_a2a_fr_ctrl = muD;

ci_lo_a2a_fr_ctrl = muD-thr;
ci_hi_a2a_fr_ctrl = muD + thr;


%% plot diffs - no outcome model
t = 0:0.025:1.5;
t = t';
W = (t >= 0) & (t <= 0.5);


figure; tiledlayout(1,2);
nexttile;hold on

plot(t, muD_d1_fr_ctrl, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_d1_fr_ctrl; flipud(ci_hi_d1_fr_ctrl)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('High − Low (a.u.)')
title("D1+ SPN");
box off; grid off
xlim([0,1]);

nexttile;hold on

plot(t, muD_a2a_fr_ctrl, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_a2a_fr_ctrl; flipud(ci_hi_a2a_fr_ctrl)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('High − Low (a.u.)')
title("A2A+ SPN");
box off; grid off
xlim([0,1]);


figure; tiledlayout(1,2);
nexttile;hold on

plot(t, muD_d1_ctrl, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_d1_ctrl; flipud(ci_hi_d1_ctrl)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('NoGo − Go (a.u.)')
title("D1+ SPN");
box off; grid off
xlim([0,1]);

M_go = S_a2a_go.M;
M_nogo = S_a2a_nogo.M;
auc_go   = trapz(t(W), M_go(W,:), 1);    % 1 × nAnimals
auc_nogo = trapz(t(W), M_nogo(W,:), 1);  % 1 × nAnimals

delta_auc = auc_go - auc_nogo;           % paired difference


nexttile;hold on

plot(t, muD_a2a_ctrl, 'k', 'LineWidth', 2)

fill([t; flipud(t)], ...
    [ci_lo_a2a_ctrl; flipud(ci_hi_a2a_ctrl)], ...
    'k', 'FaceAlpha', 0.25, 'EdgeColor','none')

yline(0,'--')
xline(0,'--')
xlabel('Time from tone (s)')
ylabel('NoGo − Go (a.u.)')
title("A2A+ SPN");
box off; grid off
xlim([0,1]);

%% Get the deltaCVs
mse_A = nan(numel(fits),1);
mse_B = nan(numel(fits),1);
fits_A = fitsLW;
fits_B = fits;
for i = 1:numel(fits_A)
    L = fits_A(i).cv.lambda_star;
    lambdas = fits_A(i).cv.lambdas;
    [~, idx] = min(abs(lambdas - L));
    mse_A(i) = mean(fits_A(i).cv.fold_mse(:,idx));

    L = fits_B(i).cv.lambda_star;
    lambdas = fits_B(i).cv.lambdas;
    [~, idx] = min(abs(lambdas - L));
    mse_B(i) = mean(fits_B(i).cv.fold_mse(:,idx));
end


% Sanity checks
assert(height(summary)==numel(mse_A) && numel(mse_A)==numel(mse_B), 'Size mismatch.');

summary.mse_full    = mse_A(:);
summary.mse_reduced = mse_B(:);
summary.delta_mse   = summary.mse_full - summary.mse_reduced;  % negative = full better

% Optional: drop failed rows
if ismember("failed", string(summary.Properties.VariableNames))
    summary_use = summary(~summary.failed, :);
else
    summary_use = summary;
end


G = groupsummary(summary_use, ["cell_type","animal_id"], "mean", "delta_mse");
G.Properties.VariableNames{'mean_delta_mse'} = 'delta_mse_animal';

cts = ["d1","a2a"];              % fixed order
x = 1:2;

means = nan(1,2);
sems  = nan(1,2);

for i = 1:2
    v = G.delta_mse_animal(G.cell_type==cts(i));
    means(i) = mean(v, 'omitnan');
    sems(i)  = std(v, 'omitnan') / sqrt(sum(~isnan(v)));
end

figure; hold on

% Bars
bar(x, means);

% Errorbars (SEM; change to CI if you want)
errorbar(x, means, sems, 'k.', 'LineWidth', 1);

% Overlay dots with jitter
rng(0);
for i = 1:2
    v = G.delta_mse_animal(G.cell_type==cts(i));
    xi = x(i) + 0.08*(rand(size(v))-0.5);  % jitter
    plot(xi, v, 'k.', 'MarkerSize', 14);
end

% Cosmetics
xticks(x);
xticklabels(cts);
yline(0,'--');
ylabel('\DeltaMSE = MSE_{lick+withhold} - MSE_{base}');
title('Lick and withholding regressors improve fit (animal-level)');
box off; grid off

disp(groupsummary(G, "cell_type", ["mean","median"], "delta_mse_animal"));
fprintf('Frac animals with ΔMSE<0 (full better):\n');
for i = 1:2
    v = G.delta_mse_animal(G.cell_type==cts(i));
    fprintf('%s: %.2f\n', cts(i), mean(v<0,'omitnan'));
end

%% Show how model (vs. reduced) predicts held out data
pickStream = 158; %pick a stream
stream = streams(pickStream,:);


%start with full model
cfg = cfg_A;

% ---------- Load t, y ----------
t = h5read(cfg.h5file, stream.(cfg.time_field){1});  t = t(:);
y = h5read(cfg.h5file, stream.(cfg.signal_field){1}); y = y(:);

assert(numel(t)==numel(y), "t and y lengths mismatch.");

% Optional: remove mean (recommended, helps intercept interpretability)
y0 = y;
y = y - mean(y, 'omitnan');

% ---------- Session trials ----------
sessTrials = trials(trials.session_uid == stream.session_uid & trials.is_valid == 1, :);
assert(height(sessTrials) > 10, "Too few valid trials for session.");

dt = cfg.dt;

% ---------- Build design matrix X for full (NO intercept here; add later) ----------

[X, labels, bases, lags] = build_design_matrix(t, sessTrials, cfg);

% ---------- Blocked time CV for ridge ----------

Kfold   = cfg.ridge.kfold;
T       = numel(y);
edges = round(linspace(1, T+1, Kfold+1));
k = 3;
test_idx  = edges(k):edges(k+1)-1;
train_idx = setdiff(1:T, test_idx);
Xtr0 = X(train_idx,:);
Xte0 = X(test_idx,:);
ytr  = y(train_idx);
yte  = y(test_idx);

% fold-specific standardization (TRAIN ONLY)
mu = mean(Xtr0, 1);
sd = std(Xtr0, 0, 1);
sd(sd==0) = 1;

Xtr = (Xtr0 - mu) ./ sd;
Xte = (Xte0 - mu) ./ sd;

lam = fits(pickStream).cv.lambda_star;  % adjust field name

% Add intercept
XtrI = [ones(size(Xtr,1),1) Xtr];
XteI = [ones(size(Xte,1),1) Xte];

% Ridge penalty matrix: don't penalize intercept
p = size(XtrI,2);
P = diag([0; ones(p-1,1)]);

beta = (XtrI'*XtrI + lam*P) \ (XtrI'*ytr);

yhat_full = XteI * beta;

%now do reduced
cfg = cfg_B;

% ---------- Load t, y ----------
t = h5read(cfg.h5file, stream.(cfg.time_field){1});  t = t(:);
y = h5read(cfg.h5file, stream.(cfg.signal_field){1}); y = y(:);

assert(numel(t)==numel(y), "t and y lengths mismatch.");

% Optional: remove mean (recommended, helps intercept interpretability)
y0 = y;
y = y - mean(y, 'omitnan');

% ---------- Session trials ----------
sessTrials = trials(trials.session_uid == stream.session_uid & trials.is_valid == 1, :);
assert(height(sessTrials) > 10, "Too few valid trials for session.");

dt = cfg.dt;

% ---------- Build design matrix X for full (NO intercept here; add later) ----------

[X, labels, bases, lags] = build_design_matrix(t, sessTrials, cfg);

% ---------- Blocked time CV for ridge ----------

Kfold   = cfg.ridge.kfold;
T       = numel(y);
edges = round(linspace(1, T+1, Kfold+1));
k = 3;
test_idx  = edges(k):edges(k+1)-1;
train_idx = setdiff(1:T, test_idx);
Xtr0 = X(train_idx,:);
Xte0 = X(test_idx,:);
ytr  = y(train_idx);
yte  = y(test_idx);

% fold-specific standardization (TRAIN ONLY)
mu = mean(Xtr0, 1);
sd = std(Xtr0, 0, 1);
sd(sd==0) = 1;

Xtr = (Xtr0 - mu) ./ sd;
Xte = (Xte0 - mu) ./ sd;

lam = fitsCtrl(pickStream).cv.lambda_star;  % adjust field name

% Add intercept
XtrI = [ones(size(Xtr,1),1) Xtr];
XteI = [ones(size(Xte,1),1) Xte];

% Ridge penalty matrix: don't penalize intercept
p = size(XtrI,2);
P = diag([0; ones(p-1,1)]);

beta = (XtrI'*XtrI + lam*P) \ (XtrI'*ytr);

yhat_red = XteI * beta;

% ---- Plot held-out prediction: actual vs full vs reduced ----

% Reconstruct held-out time axis
t_te = t(test_idx);      % uses the *current* t (from reduced model load); OK since same stream/h5/dt
% If you want to be extra safe, save t from the full model block as t_full, and use that instead.

% Sanity check lengths
assert(numel(yte) == numel(yhat_full) && numel(yte) == numel(yhat_red), ...
    "Held-out vectors length mismatch.");

% Compute held-out MSEs (optional but nice for title)
mse_full = mean((yte - yhat_full).^2, 'omitnan');
mse_red  = mean((yte - yhat_red ).^2, 'omitnan');
dMSE     = mse_full - mse_red;

% Choose a readable window inside held-out segment (e.g., 30 s)
win_s = 30;                                 % seconds to show
Nwin  = min(numel(t_te), round(win_s/dt));  % samples
i0    = 1;                                  % start index within held-out segment (change if you want)
ii    = i0:(i0+Nwin-1);

figure; tiledlayout(2,1);

% --- Top: actual + predictions ---
nexttile; hold on
plot(t_te(ii) - t_te(ii(1)), yte(ii),      'k', 'LineWidth', 1.25);
plot(t_te(ii) - t_te(ii(1)), yhat_full(ii),'b', 'LineWidth', 1.25);
plot(t_te(ii) - t_te(ii(1)), yhat_red(ii), 'r', 'LineWidth', 1.00);

xlabel('Time within held-out window (s)');
ylabel('\DeltaF/F (mean-centered)');
legend({'Actual (held-out)','Full model','No-outcome'}, 'Location','best');
title(sprintf('Held-out prediction (stream %d, fold %d): MSE_full=%.3g, MSE_red=%.3g, \\Delta=%.3g', ...
    pickStream, k, mse_full, mse_red, dMSE));
box off; grid off

% --- Bottom: residuals (shows structure the reduced model misses) ---
nexttile; hold on
plot(t_te(ii) - t_te(ii(1)), yte(ii) - yhat_full(ii), 'b', 'LineWidth', 1.1);
plot(t_te(ii) - t_te(ii(1)), yte(ii) - yhat_red(ii),  'r', 'LineWidth', 1.0);
yline(0,'k--');

xlabel('Time within held-out window (s)');
ylabel('Residual (Actual - Pred)');
legend({'Full residual','No-outcome residual'}, 'Location','best');
box off; grid off

%% Residualized PSTH pipeline
%cfg = struct();
cfg.dt = 0.025;
cfg.h5file = "C:\Users\walki\Box\Filtering Paper\resubmission\Figures\Photometry Figure\Extra_Stuff\EvanStorage\signals2.h5";
cfg.time_field   = "path_time";
cfg.signal_field = "path_debleached";

cfg.win.trialStart_extract = [-1 2];
cfg.win.tone_extract       = [-1 2];

cfg.code.high = +0.5;  % HIGH tone
cfg.code.low  = -0.5;  % LOW tone

[allOUT, metricsAll] = resid_psth_pipeline(streams, trials, fits, cfg, licks);

%% Residualized PSTH sanity checks
% pick a stream with data
% k = find(~cellfun('isempty',allOUT),1,'first');
% S = allOUT{k};
% 
% figure; plot(S.t_tone, S.psth.tone_byFreq.high); hold on;
% plot(S.t_tone, S.psth.tone_byFreq.low);
% xlim([-1 2]); xlabel('Time from tone (s)'); ylabel('\DeltaF/F residual');
% legend({'High','Low'});

[i, trRow] = pick_clean_stream_trial(streams, trials, allOUT);
sanity_plot_one_trial(streams, fits, cfg, trRow, i);


[i, trRow] = pick_clean_stream_trial(streams, trials, allOUT);
sanity_roundtrip_identity(streams, fits, cfg, trRow, i);

sanity_counts(allOUT);

% Peruse trials
[i, trRow] = pick_random_clean_stream_trial(streams, trials, allOUT);
sanity_plot_one_trial(streams, fits, cfg, trRow, i);


%% D1 A2A Go-No Go Resid PSTH -BASE
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Tone',"go", ...
    'Label',"A2A go",'Color',goColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Tone',"nogo", ...
    'Label',"A2A nogo",'Color',nogoColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');

nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Tone',"go", ...
    'Label',"D1 go",'Color',goColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Tone',"nogo", ...
    'Label',"D1 nogo",'Color',nogoColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');

%% D1 A2A Go-No Go Resid PSTH + Lick + Withhold
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"a2a", 'Tone',"go", ...
    'Label',"A2A go",'Color',goColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"a2a", 'Tone',"nogo", ...
    'Label',"A2A nogo",'Color',nogoColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');

nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"d1", 'Tone',"go", ...
    'Label',"D1 go",'Color',goColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"d1", 'Tone',"nogo", ...
    'Label',"D1 nogo",'Color',nogoColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');


%
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Tone',"high", ...
    'Label',"A2A high",'Color',highToneColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Tone',"low", ...
    'Label',"A2A low",'Color',lowToneColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');


nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Tone',"high", ...
    'Label',"D1 high",'Color',highToneColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Tone',"low", ...
    'Label',"D1 low",'Color',lowToneColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');



%% D1 A2A Tone-aligned activity by outcome type - BASE
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Outcome',"hit", ...
    'Label',"A2A hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Outcome',"cr", ...
    'Label',"A2A CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"a2a", 'Outcome',"fa", ...
    'Label',"A2A FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');


nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Outcome',"hit", ...
    'Label',"D1 hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Outcome',"cr", ...
    'Label',"D1 CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"tone", 'CellType',"d1", 'Outcome',"fa", ...
    'Label',"D1 FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');

%% D1 A2A Tone-aligned activity by outcome type - BASE + Lick + Withholding
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"a2a", 'Outcome',"hit", ...
    'Label',"A2A hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"a2a", 'Outcome',"cr", ...
    'Label',"A2A CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"a2a", 'Outcome',"fa", ...
    'Label',"A2A FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');


nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"d1", 'Outcome',"hit", ...
    'Label',"D1 hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"d1", 'Outcome',"cr", ...
    'Label',"D1 CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"tone_LW", 'CellType',"d1", 'Outcome',"fa", ...
    'Label',"D1 FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from tone start (s)');
ylabel('DeltaF/F (Residualized)');

%
figure; 
tiledlayout(1,2);
nexttile;
hold on;

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"a2a", 'Outcome',"hit", ...
    'Label',"A2A hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"a2a", 'Outcome',"cr", ...
    'Label',"A2A CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"a2a", 'Outcome',"fa", ...
    'Label',"A2A FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from trial start (s)');
ylabel('DeltaF/F (Residualized)');


nexttile; hold on;

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"d1", 'Outcome',"hit", ...
    'Label',"D1 hit",'Color',hitColor);

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"d1", 'Outcome',"cr", ...
    'Label',"D1 CR",'Color',CRColor);

plot_resid_population(allOUT, ...
    'Event',"trialStart", 'CellType',"d1", 'Outcome',"fa", ...
    'Label',"D1 FA",'Color',FAColor);

xlim([-1 2]); legend;
xlabel('Time from trial start (s)');
ylabel('DeltaF/F (Residualized)');

%% Comparing base, baseL, baseW and baseLW - full time

% Requires in workspace:
%   fits, fitsL, fitsW, fitsLW   (same length, same stream order)
%   summary                      (table with animal_id, cell_type, failed)
%
% Output:
%   streamTbl, animalTbl
%   plots for ΔMSE and betas

% ---------- SETTINGS ----------
USE_BASE_LAMBDA_FOR_ALL = false;  % true => evaluate all models at base lambda_star (Option B)
MIN_STREAMS_PER_ANIMAL  = 1;      % if you have multiple fibers per animal, can average

% Beta label strings (adjust if needed)
LICK_LABEL_CANDIDATES    = ["LickRate","lickRate","LICKRATE"];
WITHHOLD_LABEL_CANDIDATES= ["Withhold","Withholding","withhold","WITHHOLD","WithholdBoxcar"];

% ---------- BASIC SANITY ----------
n = numel(fits);
assert(numel(fitsL)==n && numel(fitsW)==n && numel(fitsLW)==n, "fits arrays differ in length.");
assert(height(summary)==n, "summary height must match fits length.");

ok = ~summary.failed;
fprintf("Streams total: %d | ok: %d | failed: %d\n", n, nnz(ok), nnz(~ok));

% ---------- Helper: get CV MSE at lambda_star ----------
get_mse_at_lambda = @(fit, lam) fit.cv.cv_mse( find(fit.cv.lambdas==lam, 1, 'first') );



% ---------- Compute per-stream MSEs ----------
mseB  = nan(n,1);
mseL  = nan(n,1);
mseW  = nan(n,1);
mseLW = nan(n,1);

lamB = nan(n,1);
lamL = nan(n,1);
lamW = nan(n,1);
lamLW= nan(n,1);

for i = 1:n
    if ~ok(i), continue; end

    lamB(i)  = fits(i).cv.lambda_star;
    lamL(i)  = fitsL(i).cv.lambda_star;
    lamW(i)  = fitsW(i).cv.lambda_star;
    lamLW(i) = fitsLW(i).cv.lambda_star;

    if USE_BASE_LAMBDA_FOR_ALL
        lam = lamB(i);
        mseB(i)  = get_mse_at(fits(i), lam);
        mseL(i)  = get_mse_at(fitsL(i), lam);
        mseW(i)  = get_mse_at(fitsW(i), lam);
        mseLW(i) = get_mse_at(fitsLW(i), lam);
    else
        mseB(i)  = get_mse_star(fits(i));
        mseL(i)  = get_mse_star(fitsL(i));
        mseW(i)  = get_mse_star(fitsW(i));
        mseLW(i) = get_mse_star(fitsLW(i));
    end
end

% ---------- ΔMSEs (negative is improvement) ----------
dL  = mseL  - mseB;    % add lick to base
dW  = mseW  - mseB;    % add withhold to base
dLW = mseLW - mseB;    % add both to base

% Incremental adds
dAddL_givenW = mseLW - mseW;  % add lick on top of withhold
dAddW_givenL = mseLW - mseL;  % add withhold on top of lick

% ---------- Build stream-level table ----------
streamTbl = table();
streamTbl.stream_uid  = summary.stream_uid;
streamTbl.session_uid = summary.session_uid;
streamTbl.animal_id   = summary.animal_id;
streamTbl.cell_type   = summary.cell_type;
streamTbl.ok          = ok;

streamTbl.mseB  = mseB;
streamTbl.mseL  = mseL;
streamTbl.mseW  = mseW;
streamTbl.mseLW = mseLW;

streamTbl.dL  = dL;
streamTbl.dW  = dW;
streamTbl.dLW = dLW;

streamTbl.dAddL_givenW = dAddL_givenW;
streamTbl.dAddW_givenL = dAddW_givenL;

streamTbl.lamB  = lamB;
streamTbl.lamL  = lamL;
streamTbl.lamW  = lamW;
streamTbl.lamLW = lamLW;

% ---------- Animal-level aggregation (recommended) ----------
% Average across streams within animal (and within cell_type if you have both)
streamOk = streamTbl(streamTbl.ok,:);
[G, animalKeys, cellKeys] = findgroups(streamOk.animal_id, streamOk.cell_type);

animalTbl = table();
animalTbl.animal_id = animalKeys;
animalTbl.cell_type = cellKeys;

animalTbl.mseB  = splitapply(@mean, streamOk.mseB,  G);
animalTbl.mseL  = splitapply(@mean, streamOk.mseL,  G);
animalTbl.mseW  = splitapply(@mean, streamOk.mseW,  G);
animalTbl.mseLW = splitapply(@mean, streamOk.mseLW, G);

animalTbl.dL  = splitapply(@mean, streamOk.dL,  G);
animalTbl.dW  = splitapply(@mean, streamOk.dW,  G);
animalTbl.dLW = splitapply(@mean, streamOk.dLW, G);

animalTbl.dAddL_givenW = splitapply(@mean, streamOk.dAddL_givenW, G);
animalTbl.dAddW_givenL = splitapply(@mean, streamOk.dAddW_givenL, G);

animalTbl.n_streams = splitapply(@numel, streamOk.dLW, G);

% optional filter
animalTbl = animalTbl(animalTbl.n_streams >= MIN_STREAMS_PER_ANIMAL, :);

% ---------- Normalize deltas (optional but handy) ----------
animalTbl.fracImprove_L  = (animalTbl.mseB - animalTbl.mseL)  ./ animalTbl.mseB;
animalTbl.fracImprove_W  = (animalTbl.mseB - animalTbl.mseW)  ./ animalTbl.mseB;
animalTbl.fracImprove_LW = (animalTbl.mseB - animalTbl.mseLW) ./ animalTbl.mseB;

% ---------- Plot: ΔMSE by model (animal-level dots) ----------
figure; hold on;
isD1  = animalTbl.cell_type=="d1";
isA2A = animalTbl.cell_type=="a2a";

xD1  = 1; xA2A = 2;

% Base->Lick
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dL(isD1),  'filled'); 
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dL(isA2A),'filled');
yline(0,'--');
title("ΔMSE: Base -> Base+Lick (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dW(isD1),  'filled'); 
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dW(isA2A),'filled');
yline(0,'--');
title("ΔMSE: Base -> Base+Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dLW(isD1),  'filled'); 
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dLW(isA2A),'filled');
yline(0,'--');
title("ΔMSE: Base -> Base+Lick+Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dAddW_givenL(isD1),  'filled'); 
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dAddW_givenL(isA2A),'filled');
yline(0,'--');
title("ΔMSE: Add Withhold on top of Lick (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dAddL_givenW(isD1),  'filled'); 
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dAddL_givenW(isA2A),'filled');
yline(0,'--');
title("ΔMSE: Add Lick on top of Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

% ---------- Beta extraction per stream ----------
betaL = nan(n,1);
betaW = nan(n,1);

for i = 1:n
    if ~ok(i), continue; end
    if ~isfield(fitsLW(i),'model') || ~isfield(fitsLW(i).model,'labels'), continue; end

    labels = string(fitsLW(i).model.labels);

    % find lick label
    idxL = find(ismember(labels, LICK_LABEL_CANDIDATES), 1, 'first');
    idxW = find(ismember(labels, WITHHOLD_LABEL_CANDIDATES), 1, 'first');

    if ~isempty(idxL)
        betaL(i) = fitsLW(i).model.beta_hat(1 + idxL);
    end
    if ~isempty(idxW)
        betaW(i) = fitsLW(i).model.beta_hat(1 + idxW);
    end
end

streamTbl.betaLick     = betaL;
streamTbl.betaWithhold = betaW;

% animal-level betas
streamOk = streamTbl(streamTbl.ok,:);
[G, animalKeys, cellKeys] = findgroups(streamOk.animal_id, streamOk.cell_type);

betaTbl = table();
betaTbl.animal_id = animalKeys;
betaTbl.cell_type = cellKeys;
betaTbl.betaLick     = splitapply(@mean, streamOk.betaLick, G);
betaTbl.betaWithhold = splitapply(@mean, streamOk.betaWithhold, G);

% ---------- Plot betas ----------
figure; hold on;
isD1  = betaTbl.cell_type=="d1";
isA2A = betaTbl.cell_type=="a2a";
scatter(1*ones(nnz(isD1),1),  betaTbl.betaLick(isD1),  'filled');
scatter(2*ones(nnz(isA2A),1), betaTbl.betaLick(isA2A), 'filled');
yline(0,'--');
title("β for LickRate (from Base+Lick+Withhold model; animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("β (Δsignal per 1 SD lickRate)");
hold off;

figure; hold on;
scatter(1*ones(nnz(isD1),1),  betaTbl.betaWithhold(isD1),  'filled');
scatter(2*ones(nnz(isA2A),1), betaTbl.betaWithhold(isA2A), 'filled');
yline(0,'--');
title("β for Withhold (from Base+Lick+Withhold model; animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("β (state effect; sign meaningful)");
hold off;

fprintf("Done. streamTbl, animalTbl, betaTbl in workspace.\n");


%% Comparing base, baseL, baseW and baseLW (RESPONSE-WINDOW MSE @ each model's lambda_star)

% Requires in workspace:
%   fitsBase, fitsL, fitsW, fitsLW   (same length, same stream order)
%   summary                          (table with animal_id, cell_type, failed)
%
% Output:
%   streamTbl, animalTbl, betaTbl
%   plots for ΔMSE and betas


% ---------- SETTINGS ----------
MIN_STREAMS_PER_ANIMAL  = 1;      % if you have multiple fibers per animal, can average

% Beta label strings (adjust if needed)
LICK_LABEL_CANDIDATES     = ["LickRate","lickRate","LICKRATE"];
WITHHOLD_LABEL_CANDIDATES = ["Withhold","Withholding","withhold","WITHHOLD","WithholdBoxcar"];

% ---------- BASIC SANITY ----------
n = numel(fitsBase);
assert(numel(fitsL)==n && numel(fitsW)==n && numel(fitsLW)==n, "fits arrays differ in length.");
assert(height(summary)==n, "summary height must match fits length.");

ok = ~summary.failed;
fprintf("Streams total: %d | ok: %d | failed: %d\n", n, nnz(ok), nnz(~ok));

% ---------- Helper: cached resp-window MSE at lambda_star ----------
get_mse_resp_star = @(fit) fit.cv.mse_resp_go_at_lambda_star;

% ---------- Compute per-stream MSEs (response window only) ----------
mseB  = nan(n,1);
mseL  = nan(n,1);
mseW  = nan(n,1);
mseLW = nan(n,1);

for i = 1:n
    if ~ok(i), continue; end

    % Each is a scalar already evaluated at THAT model's lambda_star
    mseB(i)  = get_mse_resp_star(fitsBase(i));
    mseL(i)  = get_mse_resp_star(fitsL(i));
    mseW(i)  = get_mse_resp_star(fitsW(i));
    mseLW(i) = get_mse_resp_star(fitsLW(i));
end

% Optional sanity print
fprintf("NaNs in resp-window MSEs among ok? B=%d L=%d W=%d LW=%d\n", ...
    nnz(isnan(mseB(ok))), nnz(isnan(mseL(ok))), nnz(isnan(mseW(ok))), nnz(isnan(mseLW(ok))));

% ---------- ΔMSEs (negative is improvement) ----------
dL  = mseL  - mseB;    % add lick to base
dW  = mseW  - mseB;    % add withhold to base
dLW = mseLW - mseB;    % add both to base

% Incremental adds
dAddL_givenW = mseLW - mseW;  % add lick on top of withhold
dAddW_givenL = mseLW - mseL;  % add withhold on top of lick

% ---------- Build stream-level table ----------
streamTbl = table();
streamTbl.stream_uid  = summary.stream_uid;
streamTbl.session_uid = summary.session_uid;
streamTbl.animal_id   = summary.animal_id;
streamTbl.cell_type   = summary.cell_type;
streamTbl.ok          = ok;

streamTbl.mseB  = mseB;
streamTbl.mseL  = mseL;
streamTbl.mseW  = mseW;
streamTbl.mseLW = mseLW;

streamTbl.dL  = dL;
streamTbl.dW  = dW;
streamTbl.dLW = dLW;

streamTbl.dAddL_givenW = dAddL_givenW;
streamTbl.dAddW_givenL = dAddW_givenL;

% ---------- Animal-level aggregation (recommended) ----------
% Average across streams within animal (and within cell_type if you have both)
streamOk = streamTbl(streamTbl.ok,:);
[G, animalKeys, cellKeys] = findgroups(streamOk.animal_id, streamOk.cell_type);

animalTbl = table();
animalTbl.animal_id = animalKeys;
animalTbl.cell_type = cellKeys;

animalTbl.mseB  = splitapply(@mean, streamOk.mseB,  G);
animalTbl.mseL  = splitapply(@mean, streamOk.mseL,  G);
animalTbl.mseW  = splitapply(@mean, streamOk.mseW,  G);
animalTbl.mseLW = splitapply(@mean, streamOk.mseLW, G);

animalTbl.dL  = splitapply(@mean, streamOk.dL,  G);
animalTbl.dW  = splitapply(@mean, streamOk.dW,  G);
animalTbl.dLW = splitapply(@mean, streamOk.dLW, G);

animalTbl.dAddL_givenW = splitapply(@mean, streamOk.dAddL_givenW, G);
animalTbl.dAddW_givenL = splitapply(@mean, streamOk.dAddW_givenL, G);

animalTbl.n_streams = splitapply(@numel, streamOk.dLW, G);

% optional filter
animalTbl = animalTbl(animalTbl.n_streams >= MIN_STREAMS_PER_ANIMAL, :);

% ---------- Normalize deltas (optional but handy) ----------
animalTbl.fracImprove_L  = (animalTbl.mseB - animalTbl.mseL)  ./ animalTbl.mseB;
animalTbl.fracImprove_W  = (animalTbl.mseB - animalTbl.mseW)  ./ animalTbl.mseB;
animalTbl.fracImprove_LW = (animalTbl.mseB - animalTbl.mseLW) ./ animalTbl.mseB;

% ---------- Plot: ΔMSE by model (animal-level dots) ----------
figure; hold on;
isD1  = animalTbl.cell_type=="d1";
isA2A = animalTbl.cell_type=="a2a";

xD1  = 1; xA2A = 2;

% Base->Lick
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dL(isD1),  'filled');
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dL(isA2A),'filled');
yline(0,'--');
title("ΔMSE (resp win): Base -> Base+Lick (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dW(isD1),  'filled');
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dW(isA2A),'filled');
yline(0,'--');
title("ΔMSE (resp win): Base -> Base+Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dLW(isD1),  'filled');
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dLW(isA2A),'filled');
yline(0,'--');
title("ΔMSE (resp win): Base -> Base+Lick+Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dAddW_givenL(isD1),  'filled');
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dAddW_givenL(isA2A),'filled');
yline(0,'--');
title("ΔMSE (resp win): Add Withhold on top of Lick (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

figure; hold on;
scatter(xD1*ones(nnz(isD1),1),  animalTbl.dAddL_givenW(isD1),  'filled');
scatter(xA2A*ones(nnz(isA2A),1),animalTbl.dAddL_givenW(isA2A),'filled');
yline(0,'--');
title("ΔMSE (resp win): Add Lick on top of Withhold (animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("ΔMSE (neg = better)");
hold off;

% ---------- Beta extraction per stream ----------
betaL = nan(n,1);
betaW = nan(n,1);

for i = 1:n
    if ~ok(i), continue; end
    if ~isfield(fitsLW(i),'model') || ~isfield(fitsLW(i).model,'labels'), continue; end

    labels = string(fitsLW(i).model.labels);

    % find lick label
    idxL = find(ismember(labels, LICK_LABEL_CANDIDATES), 1, 'first');
    idxW = find(ismember(labels, WITHHOLD_LABEL_CANDIDATES), 1, 'first');

    if ~isempty(idxL)
        betaL(i) = fitsLW(i).model.beta_hat(1 + idxL);  % +1 for intercept
    end
    if ~isempty(idxW)
        betaW(i) = fitsLW(i).model.beta_hat(1 + idxW);  % +1 for intercept
    end
end

streamTbl.betaLick     = betaL;
streamTbl.betaWithhold = betaW;

% animal-level betas
streamOk = streamTbl(streamTbl.ok,:);
[G, animalKeys, cellKeys] = findgroups(streamOk.animal_id, streamOk.cell_type);

betaTbl = table();
betaTbl.animal_id = animalKeys;
betaTbl.cell_type = cellKeys;
betaTbl.betaLick     = splitapply(@mean, streamOk.betaLick, G);
betaTbl.betaWithhold = splitapply(@mean, streamOk.betaWithhold, G);

% ---------- Plot betas ----------
figure; hold on;
isD1  = betaTbl.cell_type=="d1";
isA2A = betaTbl.cell_type=="a2a";
scatter(1*ones(nnz(isD1),1),  betaTbl.betaLick(isD1),  'filled');
scatter(2*ones(nnz(isA2A),1), betaTbl.betaLick(isA2A), 'filled');
yline(0,'--');
title("β for LickRate (from Base+Lick+Withhold model; animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("β (Δsignal per 1 SD lickRate)");
hold off;

figure; hold on;
scatter(1*ones(nnz(isD1),1),  betaTbl.betaWithhold(isD1),  'filled');
scatter(2*ones(nnz(isA2A),1), betaTbl.betaWithhold(isA2A), 'filled');
yline(0,'--');
title("β for Withhold (from Base+Lick+Withhold model; animal means)");
set(gca,'XTick',[1 2],'XTickLabel',{'D1','A2A'});
ylabel("β (state effect; sign meaningful)");
hold off;

fprintf("Done. streamTbl, animalTbl, betaTbl in workspace.\n");

%% Partial predictions - generate

out = partialPred_lick_withhold(streams,trials,licks,fits,cfg);

%% Partial predictions - plot 
withholdColor = [0.85 0.33 0.10];
lickColor = [0 0 0];
figure;
tiledlayout(2,2);
nexttile;

S_d1a_nogo = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
plot_partial_component(out, "withhold", "d1", "nogo", ...
    'Color', withholdColor, ... 
    'XLine0', true);
plot_partial_component(out, "lick", "d1", "nogo", ...
    'Color', lickColor, ...   
    'XLine0', true);
ylim([-.3,1.5]);
xlim([0,1]);
title("D1 No Go - Partial model contributions (Xβ)");
grid off
text(0.98, 0.97, 'No Go Tone', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.92, 'Withhold', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', withholdColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.87, 'Lick rate', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lickColor,'FontWeight','bold','FontSize', 10);
ylabel("Partial prediction (ΔF/F, a.u.)");
yline(0,'k--');

nexttile;
S_d1_go = kernel_plot(KDd1, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);

plot_partial_component(out, "withhold", "d1", "go", ...
    'Color', withholdColor, ...  
    'XLine0', true);
plot_partial_component(out, "lick", "d1", "go", ...
    'Color', lickColor, ...   
    'XLine0', true);
ylim([-.3,1.5]);
xlim([0,1]);
title("D1 Go - Partial model contributions (Xβ)");
grid off
text(0.98, 0.97, 'Go Tone', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.92, 'Withhold', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', withholdColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.87, 'Lick rate', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lickColor,'FontWeight','bold','FontSize', 10);
ylabel("Partial prediction (ΔF/F, a.u.)");
yline(0,'k--');

nexttile;

S_a2a_nogo = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 -0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', nogoColor,   'FaceAlpha', 0.15);
plot_partial_component(out, "withhold", "a2a", "nogo", ...
    'Color', withholdColor, ...   % orange
    'XLine0', true);
plot_partial_component(out, "lick", "a2a", "nogo", ...
    'Color', lickColor, ...   
    'XLine0', true);
ylim([-.3,.6]);
xlim([0,1]);
title("A2A No Go - Partial model contributions (Xβ)");
grid off
text(0.98, 0.97, 'No Go Tone', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', nogoColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.92, 'Withhold', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', withholdColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.87, 'Lick rate', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lickColor,'FontWeight','bold','FontSize', 10);
ylabel("Partial prediction (ΔF/F, a.u.)");
yline(0,'k--');

nexttile;
S_a2a_go = kernel_plot(KDa2a, 'Which',["tone_main","tone_F"], 'Weights',[1 0.5],'MapToneFTo',"goTone",'Title',"Go vs NoGo",'Color', goColor,   'FaceAlpha', 0.15);

plot_partial_component(out, "withhold", "a2a", "go", ...
    'Color', withholdColor, ...   % orange
    'XLine0', true);
plot_partial_component(out, "lick", "a2a", "go", ...
    'Color', lickColor, ...   
    'XLine0', true);
ylim([-.3,.6]);
xlim([0,1]);
title("A2A Go - Partial model contributions (Xβ)");
grid off
text(0.98, 0.97, 'Go Tone', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', goColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.92, 'Withhold', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', withholdColor,'FontWeight','bold','FontSize', 10);
text(0.98, 0.87, 'Lick rate', 'Units','normalized','HorizontalAlignment','right', 'VerticalAlignment','top','Color', lickColor,'FontWeight','bold','FontSize', 10);
ylabel("Partial prediction (ΔF/F, a.u.)");
yline(0,'k--')




%% Local Helper Functions

function fit = fit_one_stream_kernelGLM(stream, trials, cfg, lickTimes)

% ---------- Load t, y ----------
t = h5read(cfg.h5file, stream.(cfg.time_field){1});  t = t(:);
y = h5read(cfg.h5file, stream.(cfg.signal_field){1}); y = y(:);

assert(numel(t)==numel(y), "t and y lengths mismatch.");

% Optional: remove mean (recommended, helps intercept interpretability)
y0 = y;
y = y - mean(y, 'omitnan');

% ---------- Session trials ----------
sessTrials = trials(trials.session_uid == stream.session_uid & trials.is_valid == 1, :);
assert(height(sessTrials) > 10, "Too few valid trials for session.");
% ---------- Build response-window masks (fixed 1.15s post-tone) ----------
respWin_s = 1.15;

% Filter trials used to define response windows:
% - valid (already filtered above, but keep robust)
% - tone_type is go/nogo (exclude "none")
% - outcome not "restart"
tone_type = string(sessTrials.tone_type);
outcome   = string(sessTrials.outcome);

useTrials = sessTrials.is_valid == 1 & ...
           (tone_type == "go" | tone_type == "nogo") & ...
           (outcome ~= "restart") & ...
           ~isnan(sessTrials.t_tone_start);

t0s = sessTrials.t_tone_start(useTrials);
tt  = tone_type(useTrials);

respMask_all  = false(size(t));
respMask_go   = false(size(t));
respMask_nogo = false(size(t));

for k0 = 1:numel(t0s)
    t0 = t0s(k0);
    t1 = t0 + respWin_s;
    m  = (t >= t0) & (t < t1);

    respMask_all = respMask_all | m;

    if tt(k0) == "go"
        respMask_go = respMask_go | m;
    else % "nogo"
        respMask_nogo = respMask_nogo | m;
    end
end
% fprintf("RespMask: all=%d go=%d nogo=%d samples (dt=%.3f)\n", ...
%     nnz(respMask_all), nnz(respMask_go), nnz(respMask_nogo), cfg.dt);


dt = cfg.dt;

% ---------- Build design matrix X (NO intercept here; add later) ----------
[X, labels, bases, lags] = build_design_matrix(t, sessTrials, cfg, lickTimes);

% ---------- Blocked time CV for ridge ----------
lambdas = cfg.ridge.lambdas(:);
Kfold   = cfg.ridge.kfold;
T       = numel(y);

edges = round(linspace(1, T+1, Kfold+1));
fold_mse = nan(Kfold, numel(lambdas));
fold_mse_resp_all  = nan(Kfold, numel(lambdas));
fold_mse_resp_go   = nan(Kfold, numel(lambdas));
fold_mse_resp_nogo = nan(Kfold, numel(lambdas));


for k = 1:Kfold
    test_idx  = edges(k):edges(k+1)-1;
    train_idx = setdiff(1:T, test_idx);

    Xtr0 = X(train_idx,:);
    Xte0 = X(test_idx,:);
    ytr  = y(train_idx);
    yte  = y(test_idx);

    % fold-specific standardization (TRAIN ONLY)
    mu = mean(Xtr0, 1);
    sd = std(Xtr0, 0, 1);
    sd(sd==0) = 1;

    Xtr = (Xtr0 - mu) ./ sd;
    Xte = (Xte0 - mu) ./ sd;

    for il = 1:numel(lambdas)
        lam = lambdas(il);

        beta = ridge(ytr, Xtr, lam, 0); % returns [intercept; coefs]
        yhat = beta(1) + Xte * beta(2:end);

        fold_mse(k, il) = mean((yte - yhat).^2);
        % --- Response-window MSE on HELD-OUT samples only ---
        % Map global response mask into the fold's test segment
        m_all  = respMask_all(test_idx);
        m_go   = respMask_go(test_idx);
        m_nogo = respMask_nogo(test_idx);
        
        % Pooled response-window MSE
        if any(m_all)
            fold_mse_resp_all(k, il) = mean((yte(m_all) - yhat(m_all)).^2);
        else
            fold_mse_resp_all(k, il) = NaN;
        end
        
        % Go-only response-window MSE
        if any(m_go)
            fold_mse_resp_go(k, il) = mean((yte(m_go) - yhat(m_go)).^2);
        else
            fold_mse_resp_go(k, il) = NaN;
        end
        
        % NoGo-only response-window MSE
        if any(m_nogo)
            fold_mse_resp_nogo(k, il) = mean((yte(m_nogo) - yhat(m_nogo)).^2);
        else
            fold_mse_resp_nogo(k, il) = NaN;
        end

    end
end


cv_mse = mean(fold_mse, 1);
[~, bestIdx] = min(cv_mse);
lambda_star = lambdas(bestIdx);
cv_mse_resp_all  = nanmean(fold_mse_resp_all,  1);
cv_mse_resp_go   = nanmean(fold_mse_resp_go,   1);
cv_mse_resp_nogo = nanmean(fold_mse_resp_nogo, 1);

mse_resp_all_at_lambda_star  = cv_mse_resp_all(bestIdx);
mse_resp_go_at_lambda_star   = cv_mse_resp_go(bestIdx);
mse_resp_nogo_at_lambda_star = cv_mse_resp_nogo(bestIdx);


% after lambda_star is chosen:
mu_all = mean(X,1);
sd_all = std(X,0,1);
sd_all(sd_all==0) = 1;

Xz = (X - mu_all) ./ sd_all;

% ---------- Fit final model on all timepoints ----------
beta_hat = ridge(y, Xz, lambda_star, 0);

% ---------- Reconstruct kernels (in original signal units) ----------
K = reconstruct_all_kernels(beta_hat, sd_all, labels, bases);



% ---------- Package output ----------
fit = struct();

fit.failed = false;

% Meta
fit.meta = struct( ...
    'stream_uid',  string(stream.stream_uid), ...
    'session_uid', string(stream.session_uid), ...
    'animal_id',   string(stream.animal_id), ...
    'cell_type',   string(stream.cell_type), ...
    'side',        string(stream.side), ...
    'fiber',       stream.fiber, ...
    'nrxn',        stream.nrxn, ...
    'go_is_high',  stream.go_is_high, ...
    'task_phase',  stream.task_phase, ...
    'dt',          dt, ...
    'n_time',      T, ...
    't0',          t(1), ...
    't1',          t(end), ...
    'n_trials',    height(sessTrials));

% CV
fit.cv = struct( ...
    'lambdas', lambdas, ...
    'fold_mse', fold_mse, ...
    'cv_mse', cv_mse, ...
    'lambda_star', lambda_star, ...
    'kfold', Kfold, ...
    'blocked_time_cv', cfg.ridge.blocked_time_cv, ...
    ...
    'fold_mse_resp_all',  fold_mse_resp_all, ...
    'fold_mse_resp_go',   fold_mse_resp_go, ...
    'fold_mse_resp_nogo', fold_mse_resp_nogo, ...
    'cv_mse_resp_all',    cv_mse_resp_all, ...
    'cv_mse_resp_go',     cv_mse_resp_go, ...
    'cv_mse_resp_nogo',   cv_mse_resp_nogo, ...
    'mse_resp_all_at_lambda_star',  mse_resp_all_at_lambda_star, ...
    'mse_resp_go_at_lambda_star',   mse_resp_go_at_lambda_star, ...
    'mse_resp_nogo_at_lambda_star', mse_resp_nogo_at_lambda_star, ...
    'respWin_s', respWin_s ...
);


%Model
fit.model = struct( ...
    'beta_hat', beta_hat, ...
    'labels', labels, ...
    'mu_X', mu_all, ...
    'sd_X', sd_all, ...
    'y_mean_removed', true);

% Kernels
fit.lags = lags;
fit.kernels = K;

% Optional: store y summary
fit.qc = struct( ...
    'y_mean', mean(y0,'omitnan'), ...
    'y_sd', std(y0,0,'omitnan'));

end

function summary = build_kernelGLM_summary(fits)

n = numel(fits);

stream_uid  = strings(n,1);
animal_id   = strings(n,1);
cell_type   = strings(n,1);
session_uid = strings(n,1);
lambda_star = nan(n,1);
failed      = false(n,1);

for i = 1:n
    if isfield(fits(i),'failed') && fits(i).failed
        failed(i) = true;
        if isfield(fits(i),'meta')
            stream_uid(i)  = fits(i).meta.stream_uid;
            animal_id(i)   = fits(i).meta.animal_id;
            cell_type(i)   = fits(i).meta.cell_type;
            session_uid(i) = fits(i).meta.session_uid;
        end
        continue
    end

    stream_uid(i)  = fits(i).meta.stream_uid;
    animal_id(i)   = fits(i).meta.animal_id;
    cell_type(i)   = fits(i).meta.cell_type;
    session_uid(i) = fits(i).meta.session_uid;
    lambda_star(i) = fits(i).cv.lambda_star;
end

summary = table(stream_uid, session_uid, animal_id, cell_type, lambda_star, failed);

end


function [sig, p, pcrit] = bh_ttest_mask(D, q, min_n)
% BH correction across time on paired t-test p-values for D(t,animal)
% D: T × nAnimals difference matrix
% q: desired FDR (e.g., 0.05)
% min_n: minimum animals needed at a timepoint to test (e.g., 3)

if nargin < 2 || isempty(q), q = 0.05; end
if nargin < 3 || isempty(min_n), min_n = 3; end

T = size(D,1);
p = nan(T,1);

for ii = 1:T
    x = D(ii,:);
    x = x(~isnan(x));
    if numel(x) >= min_n
        [~, p(ii)] = ttest(x, 0);   % test mean difference vs 0
    end
end

sig = false(T,1);
pcrit = NaN;

valid = ~isnan(p);
pv = p(valid);

[p_sorted, idx] = sort(pv);
m = numel(pv);
thresh = (1:m)'/m * q;

k = find(p_sorted <= thresh, 1, 'last');
if ~isempty(k)
    tmp = false(m,1);
    tmp(idx(1:k)) = true;
    sig(valid) = tmp;
    pcrit = p_sorted(k);
end
end

%get AUC differences
function delta_auc = getDeltaAUC(t,t_min,t_max,S1,S2)
%t = 0:0.025:1.5;
t = t';
%t_min = 0.8;
%t_max = 1.1;
W = (t >= t_min) & (t <= t_max);
%S1 = S_a2a_go.M;
M_go = S1;
%S2 = S_a2a_nogo.M;
M_nogo = S2;
auc_go   = trapz(t(W), M_go(W,:), 1);    % 1 × nAnimals
auc_nogo = trapz(t(W), M_nogo(W,:), 1);  % 1 × nAnimals


delta_auc = auc_go - auc_nogo;           % paired difference
end

function [delta_auc,delta_p] = getAUCsTerciles(S1,S2)
delta_auc = zeros(3,size(S1,2));
delta_auc(1,:) = getDeltaAUC(0:0.025:1.5,0,.3833,S1,S2);

delta_auc(2,:) = getDeltaAUC(0:0.025:1.5,.3834,.7666,S1,S2);

delta_auc(3,:) = getDeltaAUC(0:0.025:1.5,.7667,1.15,S1,S2);


delta_p = zeros(3,1);
[~, delta_p(1,1), ~, ~] = ttest(delta_auc(1,:), 0);
[~, delta_p(2,1), ~, ~] = ttest(delta_auc(2,:), 0);
[~, delta_p(3,1), ~, ~] = ttest(delta_auc(3,:), 0);

end


% ---- Helper function ----
function plotDeltaAUCTerciles_barScatter(dAUC_3xN, p_3, panelTitle, yLims)

dAUC = dAUC_3xN;
if size(dAUC,1) ~= 3
    error('Expected dAUC to be 3xN (3 terciles by animals).');
end
N = size(dAUC,2);

p = p_3(:);
if numel(p) ~= 3
    p = []; % skip p-annotation if unexpected shape
end

x = 1:3;

% mean ± SEM across animals
m = mean(dAUC, 2, 'omitnan');
s = std(dAUC, 0, 2, 'omitnan');
nEff = sum(~isnan(dAUC), 2);
sem = s ./ max(sqrt(nEff),1);

hold on;

% Bars + errorbars
bar(x, m, 0.7);
errorbar(x, m, sem, 'LineStyle','none', 'LineWidth', 1);

% Individual points with jitter
jitterAmp = 0.12;
for t = 1:3
    y = dAUC(t,:);
    xj = x(t) + (rand(1,N)-0.5)*2*jitterAmp;
    scatter(xj, y, 28, 'filled', 'MarkerFaceAlpha', 0.85);
end

% zero line
yline(0,'--','LineWidth',1);

% p-value annotations per tercile (optional)
if ~isempty(p)
    % Choose an offset scale: use yLims if provided, otherwise use data range
    if nargin >= 4 && ~isempty(yLims)
        ySpan = range(yLims);
    else
        ySpan = max(dAUC(:), [], 'omitnan') - min(dAUC(:), [], 'omitnan');
        if ySpan == 0 || isnan(ySpan), ySpan = 1; end
    end

    yTop = max([m + sem, max(dAUC,[],2,'omitnan')], [], 2) + 0.06*ySpan;

    for t = 1:3
        text(x(t), yTop(t), sprintf('p=%.3g', p(t)), ...
            'HorizontalAlignment','center', 'FontSize', 9);
    end
end


xlim([0.5 3.5]);
xticks(1:3);
xticklabels({'0–0.383s','0.383–0.767s','0.767–1.15s'}); % edit if needed
xtickangle(35);

ylabel('\DeltaAUC');
title(panelTitle, 'Interpreter','none');

if nargin >= 4 && ~isempty(yLims)
    ylim(yLims);
end

box off;
set(gca,'TickDir','out');
hold off;
end

function [i, trRow] = pick_clean_stream_trial(streams, trials, allOUT)
% Returns stream index i (into fits/streams) and a trial row (from trials table)
% with tone played and non-truncated outcome.

idxStreams = find(~cellfun('isempty', allOUT));
if isempty(idxStreams), error('No non-empty outputs in allOUT.'); end

for k = 1:numel(idxStreams)
    iCand = idxStreams(k);
    sid = streams.session_uid{iCand};
    Tr = trials(strcmp(trials.session_uid, sid) & trials.is_valid==1, :);
    if isempty(Tr), continue; end
    Tr = sortrows(Tr, "trial_idx");

    tonePlayed = ~(string(Tr.tone_type)=="none" | string(Tr.outcome)=="restart");
    cleanOut   = ~(string(Tr.outcome)=="truncated" | string(Tr.outcome)=="restart");
    ok = tonePlayed & cleanOut & ~isnan(Tr.t_tone_start) & ~isnan(Tr.t_outcome) & ~isnan(Tr.t_trial_start);

    if any(ok)
        i = iCand;
        trRow = Tr(find(ok,1,'first'), :);
        return
    end
end

error('Could not find a clean trial in any non-empty stream.');
end

function sanity_plot_one_trial(streams, fits, cfg, trRow, i)
% Plots for one stream i and one trial row:
% trialStart window: raw, pred(tone+out), resid
% tone window: raw, pred(trialStart+out), resid
%
% xlim forced to [-1 2] for both.

dt = cfg.dt;

% windows
tTS   = (cfg.win.trialStart_extract(1):dt:cfg.win.trialStart_extract(2))';
tTone = (cfg.win.tone_extract(1):dt:cfg.win.tone_extract(2))';

% load time + signal
t = h5read(cfg.h5file, streams.(cfg.time_field){i}); t = t(:);
y = h5read(cfg.h5file, streams.(cfg.signal_field){i}); y = y(:);

% kernels + lags
K = fits(i).kernels;
lagsTS   = fits(i).lags.trialStart(:);
lagsTone = fits(i).lags.tone(:);
lagsOut  = fits(i).lags.outcome(:);

kTS    = single(K.trialStart(:));
kTone  = single(K.tone_main(:));
kToneF = single(K.tone_F(:));
kHit = single(K.out_hit(:));  kFA = single(K.out_FA(:));  kCRM = single(K.out_CRMiss(:));

% trial info
t0   = double(trRow.t_trial_start);
tt   = double(trRow.t_tone_start);
tout = double(trRow.t_outcome);

toneType = string(trRow.tone_type);  % go/nogo/none
outType  = string(trRow.outcome);    % hit/fa/cr/miss/...
goIsHigh = logical(trRow.go_is_high);

tonePlayed = ~(toneType=="none" | outType=="restart");

% ---- A) trialStart window: subtract tone+outcome
tAbs = t0 + tTS;
rawTS = extract_segment_dt(t, y, tAbs, dt);

predOtherTS = zeros(size(tTS),'single');
if tonePlayed && ~isnan(tt)
    tToneRel = tt - t0;

    if toneType=="go"
        isHigh = goIsHigh;
    elseif toneType=="nogo"
        isHigh = ~goIsHigh;
    else
        isHigh = false;
    end
    codeF = cfg.code.low; if isHigh, codeF = cfg.code.high; end

    predOtherTS = addKernel_dt(predOtherTS, tTS, tToneRel, kTone,  lagsTone, dt);
    predOtherTS = addKernel_dt(predOtherTS, tTS, tToneRel, single(codeF)*kToneF, lagsTone, dt);
end

if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
    tOutRel = tout - t0;
    kout = outcome_kernel(outType, kHit, kFA, kCRM);
    predOtherTS = addKernel_dt(predOtherTS, tTS, tOutRel, kout, lagsOut, dt);
end

residTS = single(rawTS) - predOtherTS;

% ---- B) tone window [-1,2]: subtract trialStart+outcome
if tonePlayed && ~isnan(tt)
    tAbs = tt + tTone;
    rawTone = extract_segment_dt(t, y, tAbs, dt);

    predOtherTone = zeros(size(tTone),'single');

    % trialStart relative to tone
    tTSrel = t0 - tt;
    predOtherTone = addKernel_dt(predOtherTone, tTone, tTSrel, kTS, lagsTS, dt);

    % outcome relative to tone
    if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
        tOutRel = tout - tt;
        kout = outcome_kernel(outType, kHit, kFA, kCRM);
        predOtherTone = addKernel_dt(predOtherTone, tTone, tOutRel, kout, lagsOut, dt);
    end

    residTone = single(rawTone) - predOtherTone;
else
    rawTone = nan(size(tTone));
    predOtherTone = nan(size(tTone));
    residTone = nan(size(tTone));
end

% ---- Plot
figure('Name',sprintf('Stream %d, session %s, trial %d', i, string(trRow.session_uid), trRow.trial_idx));

subplot(2,1,1);
plot(tTS, rawTS, 'DisplayName','raw'); hold on;
plot(tTS, predOtherTS, 'DisplayName','pred other (tone+out)');
plot(tTS, residTS, 'DisplayName','resid (raw - other)');
xlim([-1 2]); xlabel('Time from trialStart (s)'); ylabel('\DeltaF/F');
title('TrialStart window'); legend('Location','best'); grid on;
xTone = tt - t0;
xOut  = tout - t0;
xline(xTone, '--', 'tone'); 
xline(xOut,  '--', 'outcome');

subplot(2,1,2);
plot(tTone, rawTone, 'DisplayName','raw'); hold on;
plot(tTone, predOtherTone, 'DisplayName','pred other (trialStart+out)');
plot(tTone, residTone, 'DisplayName','resid (raw - other)');
xlim([-1 2]); xlabel('Time from tone (s)'); ylabel('\DeltaF/F');
title('Tone window'); legend('Location','best'); grid on;
xTS   = t0 - tt;
xOut2 = tout - tt;
xline(xTS,  '--', 'trialStart');
xline(xOut2,'--', 'outcome');

end

% ---- small helpers used above
function kout = outcome_kernel(outType, kHit, kFA, kCRM)
if outType=="hit", kout = kHit;
elseif outType=="fa", kout = kFA;
else, kout = kCRM; end
end

function ySeg = extract_segment_dt(t, y, tAbs, dt)
t0 = t(1);
idx = round((tAbs - t0)/dt) + 1;
ySeg = nan(size(tAbs), 'like', y);
valid = idx>=1 & idx<=numel(y);
ySeg(valid) = y(idx(valid));
end

function yhat = addKernel_dt(yhat, tWin, tEventRel, k, lags, dt)
tContrib = tEventRel + lags;
idx = round((tContrib - tWin(1))/dt) + 1;
valid = idx>=1 & idx<=numel(tWin);
yhat(idx(valid)) = yhat(idx(valid)) + k(valid);
end

function sanity_roundtrip_identity(streams, fits, cfg, trRow, i)
% Checks:
% trialStart: raw ≈ resid + pred(tone+out)
% tone: raw ≈ resid + pred(trialStart+out)
% Prints max abs error within window.

dt = cfg.dt;
tTS   = (cfg.win.trialStart_extract(1):dt:cfg.win.trialStart_extract(2))';
tTone = (cfg.win.tone_extract(1):dt:cfg.win.tone_extract(2))';

% load time + signal
t = h5read(cfg.h5file, streams.(cfg.time_field){i}); t = t(:);
y = h5read(cfg.h5file, streams.(cfg.signal_field){i}); y = y(:);

% kernels + lags
K = fits(i).kernels;
lagsTS   = fits(i).lags.trialStart(:);
lagsTone = fits(i).lags.tone(:);
lagsOut  = fits(i).lags.outcome(:);

kTS    = single(K.trialStart(:));
kTone  = single(K.tone_main(:));
kToneF = single(K.tone_F(:));
kHit = single(K.out_hit(:));  kFA = single(K.out_FA(:));  kCRM = single(K.out_CRMiss(:));

% trial info
t0   = double(trRow.t_trial_start);
tt   = double(trRow.t_tone_start);
tout = double(trRow.t_outcome);

toneType = string(trRow.tone_type);
outType  = string(trRow.outcome);
goIsHigh = logical(trRow.go_is_high);
tonePlayed = ~(toneType=="none" | outType=="restart");

% ---------- trialStart window
rawTS = extract_segment_dt(t, y, t0 + tTS, dt);
predOtherTS = zeros(size(tTS),'single');

if tonePlayed && ~isnan(tt)
    tToneRel = tt - t0;
    if toneType=="go", isHigh = goIsHigh;
    elseif toneType=="nogo", isHigh = ~goIsHigh;
    else, isHigh = false; end
    codeF = cfg.code.low; if isHigh, codeF = cfg.code.high; end
    predOtherTS = addKernel_dt(predOtherTS, tTS, tToneRel, kTone,  lagsTone, dt);
    predOtherTS = addKernel_dt(predOtherTS, tTS, tToneRel, single(codeF)*kToneF, lagsTone, dt);
end
if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
    predOtherTS = addKernel_dt(predOtherTS, tTS, tout - t0, outcome_kernel(outType,kHit,kFA,kCRM), lagsOut, dt);
end

residTS = single(rawTS) - predOtherTS;
reconTS = residTS + predOtherTS;

errTS = max(abs(double(rawTS) - double(reconTS)), [], 'omitnan');

% ---------- tone window
if tonePlayed && ~isnan(tt)
    rawTone = extract_segment_dt(t, y, tt + tTone, dt);
    predOtherTone = zeros(size(tTone),'single');

    predOtherTone = addKernel_dt(predOtherTone, tTone, t0 - tt, kTS, lagsTS, dt);
    if ~isnan(tout) && ~(outType=="restart" | outType=="truncated")
        predOtherTone = addKernel_dt(predOtherTone, tTone, tout - tt, outcome_kernel(outType,kHit,kFA,kCRM), lagsOut, dt);
    end

    residTone = single(rawTone) - predOtherTone;
    reconTone = residTone + predOtherTone;
    errTone = max(abs(double(rawTone) - double(reconTone)), [], 'omitnan');
else
    errTone = NaN;
end

fprintf('Round-trip max abs error (trialStart window): %.3g\n', errTS);
fprintf('Round-trip max abs error (tone window):      %.3g\n', errTone);

end

function sanity_counts(allOUT)
S = allOUT(~cellfun('isempty',allOUT));
for k=1:numel(S)
    O = S{k};

    % tone totals
    nAll = getfield_safe(O.nTrials,"tone_all",NaN);
    nGo  = getfield_safe(O.nTrials,"tone_byAction","go",0);
    nNo  = getfield_safe(O.nTrials,"tone_byAction","nogo",0);
    nHi  = getfield_safe(O.nTrials,"tone_byFreq","high",0);
    nLo  = getfield_safe(O.nTrials,"tone_byFreq","low",0);

    if ~isnan(nAll)
        if nAll ~= (nGo+nNo)
            fprintf('Stream %s: tone_all (%d) != go+nogo (%d)\n', O.stream_uid, nAll, nGo+nNo);
        end
        if nAll ~= (nHi+nLo)
            fprintf('Stream %s: tone_all (%d) != high+low (%d)\n', O.stream_uid, nAll, nHi+nLo);
        end
    end
end
disp('Count sanity done.');
end

function v = getfield_safe(s, f1, f2, f3, default)
% allows nested fields; usage:
% getfield_safe(O.nTrials,"tone_byAction","go",0)
try
    if nargin==3
        v = s.(f1); return;
    elseif nargin==4
        v = s.(f1).(f2); return;
    elseif nargin==5
        v = s.(f1).(f2).(f3); return;
    end
catch
    v = default;
end
end

function [i, trRow] = pick_random_clean_stream_trial(streams, trials, allOUT)

% candidate streams with non-empty outputs
idxStreams = find(~cellfun('isempty', allOUT));
if isempty(idxStreams)
    error('No non-empty streams in allOUT.');
end

% shuffle streams
idxStreams = idxStreams(randperm(numel(idxStreams)));

for k = 1:numel(idxStreams)
    iCand = idxStreams(k);

    sid = streams.session_uid{iCand};

    % all valid trials for this session
    Tr = trials(strcmp(trials.session_uid, sid) & trials.is_valid==1, :);
    if isempty(Tr), continue; end

    % clean trial criteria
    tonePlayed = ~(string(Tr.tone_type)=="none" | string(Tr.outcome)=="restart");
    cleanOut   = ~(string(Tr.outcome)=="restart" | string(Tr.outcome)=="truncated");

    ok = tonePlayed & cleanOut & ...
         ~isnan(Tr.t_trial_start) & ...
         ~isnan(Tr.t_tone_start) & ...
         ~isnan(Tr.t_outcome);

    if any(ok)
        TrOK = Tr(ok, :);
        trRow = TrOK(randi(height(TrOK)), :);  % random trial from this session
        i = iCand;
        return
    end
end

error('Could not find any clean (stream, trial) pair.');
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

% Robust: if exact equality fails due to float representation
function idx = find_lambda_idx(lambdas, lam)
    [~, idx] = min(abs(lambdas - lam));
end

function mse_star = get_mse_star(fit)
    idx = find_lambda_idx(fit.cv.lambdas(:), fit.cv.lambda_star);
    mse_star = fit.cv.cv_mse(idx);
end

function mse_at = get_mse_at(fit, lam)
    idx = find_lambda_idx(fit.cv.lambdas(:), lam);
    mse_at = fit.cv.cv_mse(idx);
end

function out = partialPred_lick_withhold(streams,trials,licks,fits,cfg)
% Computes partial predictions y_lick(t)=beta_L*lickRate(t)
% and y_withhold(t)=beta_W*withhold(t), aligns to tone onset [0,1.15],
% averages: stream -> animal -> cell_type, split go/nogo.

dt = cfg.dt;
win = [0 1.15];
t_rel = (win(1):dt:win(2))';

cellTypes = ["a2a","d1"];
conds = ["go","nogo"];

% per celltype/cond: map animal_id -> struct with fields lick_list, withhold_list
A = struct();
for ct = cellTypes
  for c = conds
    A.(ct).(c) = containers.Map();
  end
end

for i = 1:height(streams)
  if ismember('include', streams.Properties.VariableNames) && ~streams.include(i), continue; end

  ct = lower(string(streams.cell_type(i)));
  if ~ismember(ct, cellTypes), continue; end

  % model betas
  mdl = fits(i).model;
  labels = string(mdl.labels(:));
  beta_all = double(mdl.beta_hat(:));
  if cfg.addIntercept
    beta = beta_all(2:end);
  else
    beta = beta_all;
  end

  idxL = find(labels=="LickRate",1);
  idxW = find(labels=="WithholdBoxcar",1);
  if isempty(idxL) || isempty(idxW), continue; end
  bL = beta(idxL);
  bW = beta(idxW);

  % time vector for this stream
  t = h5read(cfg.h5file, streams.(cfg.time_field)(i));
  t = double(t(:));

  % ---------- Build lickRate PER STREAM (this is the critical line) ----------
  lkMask = (string(licks.session_uid) == string(streams.session_uid(i))) & ...
         (string(licks.animal_id)  == string(streams.animal_id(i))) & ...
         (lower(string(licks.cell_type)) == lower(string(streams.cell_type(i))));
  lickTimes = double(licks.lick_times(lkMask));
  lickRate = buildLickRate(t, lickTimes, cfg);   % <-- called here, per stream
  yL = bL * lickRate;

  % ---------- Build withhold boxcar PER STREAM ----------
  trMaskAll = (string(trials.session_uid) == string(streams.session_uid(i))) & ...
            (string(trials.animal_id)  == string(streams.animal_id(i))) & ...
            (lower(string(trials.cell_type)) == lower(string(streams.cell_type(i)))) & ...
            logical(trials.is_valid) & ...
            (trials.tone_type=="go" | trials.tone_type=="nogo");

  withhold = zeros(size(t));
  idxTrAll = find(trMaskAll)';
  for k = idxTrAll
    t0 = trials.t_tone_start(k);
    t1 = trials.t_outcome(k);
    if isnan(t0) || isnan(t1) || t1<=t0, continue; end
    withhold(t>=t0 & t<t1) = cfg.withhold.value;
  end
  yW = bW * withhold;

  % ---------- Align to tone onset and average within stream, per condition ----------
  for cond = conds
    trMask = trMaskAll & (trials.tone_type == cond);
    if nnz(trMask) < 10, continue; end

    Lmat = [];
    Wmat = [];

    for k = find(trMask)'
      t0 = trials.t_tone_start(k);

      % sample exactly on t0 + t_rel (robust to minor dt jitter)
      tq = t0 + t_rel;
      Lsnip = interp1(t, yL, tq, 'linear', 'extrap');
      Wsnip = interp1(t, yW, tq, 'linear', 'extrap');

      Lmat = [Lmat, Lsnip];
      Wmat = [Wmat, Wsnip];
    end

    streamMeanL = mean(Lmat, 2, 'omitnan');
    streamMeanW = mean(Wmat, 2, 'omitnan');

    animal = string(streams.animal_id(i));
    M = A.(ct).(cond);
    if ~isKey(M, animal)
      M(animal) = struct('lick_list', [], 'withhold_list', []);
    end
    s = M(animal);
    s.lick_list      = [s.lick_list, streamMeanL];
    s.withhold_list  = [s.withhold_list, streamMeanW];
    M(animal) = s;
    A.(ct).(cond) = M;
  end
end

% ---------- Hierarchical averaging: stream -> animal -> cell type ----------
out = struct();
out.t_rel = t_rel;

for ct = cellTypes
  for cond = conds
    M = A.(ct).(cond);
    if M.Count == 0, continue; end

    animals = keys(M);
    L_anim = [];
    W_anim = [];

    for a = 1:numel(animals)
      s = M(animals{a});
      % average across streams within animal
      L_anim(:,a) = mean(s.lick_list, 2, 'omitnan');
      W_anim(:,a) = mean(s.withhold_list, 2, 'omitnan');
    end

    % equal-animal weighting
    out.(ct).(cond).lick = mean(L_anim, 2, 'omitnan');
    out.(ct).(cond).withhold = mean(W_anim, 2, 'omitnan');
    out.(ct).(cond).lick_byAnimal = L_anim;
    out.(ct).(cond).withhold_byAnimal = W_anim;
    out.(ct).(cond).animal_ids = string(animals);
  end
end
end

% =================== LOCAL FUNCTION ===================
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

if isfield(cfg.lickRate,'zscore') && cfg.lickRate.zscore
  m = mean(lickRate,'omitnan');
  s = std(lickRate,0,'omitnan'); if s==0, s=1; end
  lickRate = (lickRate-m)/s;
end
end

function [h, stats] = plot_partial_component(out, component, cellType, cond, varargin)
% [h, stats] = plot_partial_component(...)
% Mean ± SEM plot for partial predictions, with customizable color.

component = lower(string(component));
cellType  = lower(string(cellType));
cond      = lower(string(cond));

validComp = ["lick","withhold"];
validCT   = ["a2a","d1"];
validCond = ["go","nogo"];

assert(ismember(component, validComp));
assert(ismember(cellType, validCT));
assert(ismember(cond, validCond));

p = inputParser;
p.addParameter('ax', [], @(x) isempty(x) || ishghandle(x));
p.addParameter('LineWidth', 2, @isscalar);
p.addParameter('FaceAlpha', 0.2, @isscalar);
p.addParameter('ShowSEM', true, @islogical);
p.addParameter('Label', "", @(x) isstring(x) || ischar(x));
p.addParameter('XLine0', false, @islogical);
p.addParameter('ReturnOnly', false, @islogical);
p.addParameter('Color', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==3));
p.parse(varargin{:});
opt = p.Results;

if isempty(opt.ax), opt.ax = gca; end
ax = opt.ax;

% ---- fetch data ----
field = component + "_byAnimal";
X = out.(cellType).(cond).(field);   % T x Nanimals
t = out.t_rel(:);

% ---- compute stats ----
mu = mean(X, 2, 'omitnan');
sd = std(X, 0, 2, 'omitnan');
n  = sum(~all(isnan(X),1));
se = sd ./ max(1, sqrt(n));

stats = struct('t', t, 'mu', mu, 'se', se, 'n', n, ...
               'component', component, 'cellType', cellType, 'cond', cond);

h = struct('band', [], 'line', [], 'x0', []);

if opt.ReturnOnly
    return
end

axes(ax); %#ok<LAXES>
hold(ax, 'on');

if opt.XLine0
    h.x0 = xline(ax, 0, '-');
end

% ---- SEM band ----
if opt.ShowSEM
    xx = [t; flipud(t)];
    yy = [mu - se; flipud(mu + se)];
    h.band = fill(ax, xx, yy, 1, 'LineStyle', 'none');
    if ~isempty(opt.Color)
        set(h.band, 'FaceColor', opt.Color);
    end
    set(h.band, 'FaceAlpha', opt.FaceAlpha);
end

% ---- mean line ----
if isempty(opt.Color)
    h.line = plot(ax, t, mu, 'LineWidth', opt.LineWidth);
else
    h.line = plot(ax, t, mu, 'LineWidth', opt.LineWidth, 'Color', opt.Color);
end

% ---- legend label ----
if strlength(string(opt.Label)) > 0
    h.line.DisplayName = string(opt.Label);
else
    h.line.DisplayName = sprintf('%s %s %s (n=%d)', upper(cellType), upper(cond), component, n);
end
end

function S = normalize_sarah_table(T)
  % Expect columns: Animal, Date, Time
  % Date format: dd-mm-yy (e.g., 02-12-24)
  % Time format: HH_MM_SS (e.g., 11_09_58)

  % Normalize column names robustly
  vars = lower(string(T.Properties.VariableNames));
  iA = find(vars=="animal",1);  if isempty(iA), iA = find(contains(vars,"animal"),1); end
  iD = find(vars=="date",1);    if isempty(iD), iD = find(contains(vars,"date"),1); end
  iT = find(vars=="time",1);    if isempty(iT), iT = find(contains(vars,"time"),1); end
  assert(~isempty(iA)&&~isempty(iD)&&~isempty(iT), 'Could not find Animal/Date/Time columns.');

  animal = string(T{:,iA});
  date_s = string(T{:,iD});
  time_s = string(T{:,iT});

  % parse date: dd-mm-yy
  d = datetime(date_s);   % let MATLAB infer format

  % parse time: HH_MM_SS (underscores)
  time_s = replace(time_s,"_",":");
  tt = datetime(time_s, 'InputFormat','HH:mm:ss');

  % combine date+time into one datetime
  dt = datetime(year(d), month(d), day(d), hour(tt), minute(tt), second(tt));

  % build session_stamp: eYYYYMMDDHHMMSS
  stamp = "e" + string(dt, 'yyyyMMddHHmmss');

  S = table(animal, stamp, 'VariableNames', {'animal_id','session_stamp'});
end


function varargout = filter_sessions_day1_expert(excelPath, keepMode, fits, varargin)
%FILTER_SESSIONS_DAY1_EXPERT Filter tables + fits by training(day1) or expert(>=expert_date).
%
% Training rule: session_date == day1 (per animal)
% Expert rule:   session_date >= expert_date (per animal)
%
% Inputs:
%   excelPath : path to xlsx with columns: animal_id, day1, expert_date
%   keepMode  : "training" or "expert"
%   fits      : struct array OR scalar struct with row-aligned fields (same length as summary)
%   varargin  : one or more tables (e.g., licks, sessions, streams, summary, trials, ...)
%
% Name-Value:
%   "assignInCaller"   : overwrite caller vars (default false)
%   "requireMapping"   : if true, drop rows lacking an excel mapping (default true)
%   "dateSource"       : "sessions" or "summary" (default "sessions" if provided else "summary")
%   "excludeDay1FromExpert" : if true, expert keeps >= expert_date BUT excludes day1 (default true)
%   "verbose"          : print counts (default true)
%
% Outputs (in order):
%   same tables you passed in (same order), then fits, then info
%
% Example:
%   [licks,sessions,streams,summary,trials,fits,info] = ...
%       filter_sessions_day1_expert(excelPath,"expert",fits,licks,sessions,streams,summary,trials);

% ----------------- parse name-value from varargin -----------------
% allow trailing name-value pairs after tables
assignInCaller = false;
requireMapping = true;
dateSource     = "";   % decide later
excludeDay1FromExpert = true;
verbose        = true;

% Split varargin into (tables) and (name-value)
isNVStart = find(cellfun(@(x) ischar(x) || (isstring(x) && isscalar(x)), varargin), 1, 'first');
% Heuristic: name-value starts at first string that matches a known parameter name
known = ["assignInCaller","requireMapping","dateSource","excludeDay1FromExpert","verbose"];
nvIdx = [];
for k = 1:numel(varargin)
    if (ischar(varargin{k}) || (isstring(varargin{k}) && isscalar(varargin{k}))) ...
            && any(strcmpi(string(varargin{k}), known))
        nvIdx = k;
        break;
    end
end

if ~isempty(nvIdx)
    tableArgs = varargin(1:nvIdx-1);
    nvArgs    = varargin(nvIdx:end);
else
    tableArgs = varargin;
    nvArgs    = {};
end

% parse NV
if ~isempty(nvArgs)
    if mod(numel(nvArgs),2) ~= 0
        error("Name-value arguments must come in pairs.");
    end
    for i = 1:2:numel(nvArgs)
        name = lower(string(nvArgs{i}));
        val  = nvArgs{i+1};
        switch name
            case "assignincaller"
                assignInCaller = logical(val);
            case "requiremapping"
                requireMapping = logical(val);
            case "datesource"
                dateSource = lower(string(val));
            case "excludeday1fromexpert"
                excludeDay1FromExpert = logical(val);
            case "verbose"
                verbose = logical(val);
            otherwise
                error("Unknown parameter: %s", name);
        end
    end
end

keepMode = lower(string(keepMode));
if ~any(keepMode == ["training","expert"])
    error('keepMode must be "training" or "expert".');
end

% ----------------- validate table inputs -----------------
if isempty(tableArgs)
    error("Pass at least one table (e.g., summary, sessions, ...).");
end
nTables = numel(tableArgs);
tblNames = strings(1,nTables);
for i = 1:nTables
    if ~istable(tableArgs{i})
        error("Argument %d after fits is not a table.", i);
    end
    nm = string(inputname(i+3)); % (1)excelPath (2)keepMode (3)fits then tables
    if strlength(nm)==0
        % if user passed an expression, we can't overwrite by name
        nm = "table" + i;
    end
    tblNames(i) = nm;
end

% Find the summary table among inputs (needed to filter fits)
isSummary = strcmpi(tblNames, "summary");
if ~any(isSummary)
    error('One of the table inputs must be named "summary" (pass your summary table variable as "summary").');
end
summaryIdx = find(isSummary, 1, 'first');
summaryTbl = tableArgs{summaryIdx};

% choose dateSource
if strlength(dateSource)==0
    if any(strcmpi(tblNames, "sessions"))
        dateSource = "sessions";
    else
        dateSource = "summary";
    end
end
srcIdx = find(strcmpi(tblNames, dateSource), 1, 'first');
if isempty(srcIdx)
    error('dateSource="%s" requested, but you did not pass a table named "%s".', dateSource, dateSource);
end
srcTbl = tableArgs{srcIdx};

% check required vars in source table
needVars = ["session_uid","animal_id"];
for v = needVars
    if ~ismember(v, string(srcTbl.Properties.VariableNames))
        error('Source table "%s" must contain variable "%s".', dateSource, v);
    end
end

% ----------------- read and normalize excel mapping -----------------
map = readtable(excelPath, "TextType", "string");
reqMapVars = ["animal_id","day1","expert_date"];
for v = reqMapVars
    if ~ismember(v, string(map.Properties.VariableNames))
        error('Excel file must contain columns: animal_id, day1, expert_date. Missing: %s', v);
    end
end

map.animal_id   = string(map.animal_id);
map.day1        = local_to_yyyymmdd_num(map.day1);
map.expert_date = local_to_yyyymmdd_num(map.expert_date);

% ----------------- extract session date YYYYMMDD from session_uid -----------------
session_uid = string(srcTbl.session_uid);
sessionDateNum = local_extract_yyyymmdd_from_session_uid(session_uid); % Nx1 double

srcAnimal = string(srcTbl.animal_id);
[tfMap, loc] = ismember(srcAnimal, map.animal_id);

if requireMapping
    mappedMask = tfMap;
else
    mappedMask = true(size(tfMap));
end

day1Num   = nan(size(sessionDateNum));
expertNum = nan(size(sessionDateNum));
day1Num(tfMap)   = map.day1(loc(tfMap));
expertNum(tfMap) = map.expert_date(loc(tfMap));

isTraining = (sessionDateNum == day1Num);
isExpert   = (sessionDateNum >= expertNum);

switch keepMode
    case "training"
        keepSessionMask = mappedMask & isTraining;
    case "expert"
        if excludeDay1FromExpert
            keepSessionMask = mappedMask & isExpert & ~isTraining;
        else
            keepSessionMask = mappedMask & isExpert;
        end
end

keepSessionUIDs = unique(session_uid(keepSessionMask));

% ----------------- filter each passed table by session_uid -----------------
filteredTables = tableArgs;
keptRowsPerTable = zeros(1,nTables);
droppedRowsPerTable = zeros(1,nTables);

for i = 1:nTables
    T = tableArgs{i};

    if ismember("session_uid", string(T.Properties.VariableNames))
        su = string(T.session_uid);
        keepRow = ismember(su, keepSessionUIDs);

        filteredTables{i} = T(keepRow, :);
        keptRowsPerTable(i) = nnz(keepRow);
        droppedRowsPerTable(i) = height(T) - nnz(keepRow);
    else
        % If a table doesn't have session_uid, we leave it untouched.
        filteredTables{i} = T;
        keptRowsPerTable(i) = height(T);
        droppedRowsPerTable(i) = 0;
    end
end

% ----------------- filter fits by summary rows (fits aligns 1:1 with summary) -----------------
newSummary = filteredTables{summaryIdx};
keepSummaryRows = true(height(summaryTbl),1);
if ismember("session_uid", string(summaryTbl.Properties.VariableNames))
    keepSummaryRows = ismember(string(summaryTbl.session_uid), keepSessionUIDs);
else
    error('summary table must contain "session_uid" to filter fits consistently.');
end

fitsFiltered = local_filter_fits_by_mask(fits, keepSummaryRows);

% ----------------- info struct -----------------
info = struct();
info.keepMode = keepMode;
info.dateSource = dateSource;
info.excludeDay1FromExpert = excludeDay1FromExpert;
info.nSessionsKept = numel(keepSessionUIDs);
info.tableNames = tblNames;
info.keptRowsPerTable = keptRowsPerTable;
info.droppedRowsPerTable = droppedRowsPerTable;
info.nSummaryBefore = height(summaryTbl);
info.nSummaryAfter  = height(newSummary);
info.nFitsBefore = local_len_fits(fits);
info.nFitsAfter  = local_len_fits(fitsFiltered);

if verbose
    fprintf("[filter_sessions_day1_expert] keep=%s | dateSource=%s | sessions kept=%d\n", ...
        keepMode, dateSource, info.nSessionsKept);
    for i = 1:nTables
        fprintf("  %s: %d -> %d (dropped %d)\n", tblNames(i), height(tableArgs{i}), height(filteredTables{i}), droppedRowsPerTable(i));
    end
    fprintf("  fits: %d -> %d\n", info.nFitsBefore, info.nFitsAfter);
end

% ----------------- optionally overwrite caller variables -----------------
if assignInCaller
    for i = 1:nTables
        nm = tblNames(i);
        % only overwrite if we have a real variable name
        if ~startsWith(nm, "table")
            assignin("caller", nm, filteredTables{i});
        end
    end
    % overwrite fits if caller provided a variable name
    fitsName = string(inputname(3));
    if strlength(fitsName) > 0
        assignin("caller", fitsName, fitsFiltered);
    end
    % also drop info in caller (optional; name is stable)
    assignin("caller", "filter_info", info);
end

% ----------------- outputs -----------------
% return tables in the same order passed, then fits, then info
varargout = [filteredTables, {fitsFiltered}, {info}];

end

% ================= local helpers =================

function y = local_to_yyyymmdd_num(x)
% Convert excel column to numeric YYYYMMDD safely (string/numeric/datetime)
if isdatetime(x)
    y = year(x)*10000 + month(x)*100 + day(x);
    y = double(y);
elseif isnumeric(x)
    y = double(x);
else
    xs = string(x);
    xs = strtrim(xs);
    xs(xs=="") = "NaN";
    y = double(xs);
end
end

function d = local_extract_yyyymmdd_from_session_uid(session_uid)
% session_uid like "e20241126113002_a1" -> 20241126
% We take characters 2..9 if present; else regexp fallback.
d = nan(numel(session_uid),1);
s = string(session_uid);

% fast path: char 2..9 are digits
okLen = strlength(s) >= 9;
cand = extractBetween(s(okLen), 2, 9);
isDig = ~isnan(str2double(cand));
d(okLen) = str2double(cand);

% fallback for anything weird
need = isnan(d);
if any(need)
    for i = find(need').'
        tok = regexp(s(i), '^e(\d{8})', 'tokens', 'once');
        if ~isempty(tok)
            d(i) = str2double(tok{1});
        end
    end
end

if any(isnan(d))
    bad = find(isnan(d), 1, 'first');
    error('Failed to parse YYYYMMDD from session_uid at index %d: "%s"', bad, s(bad));
end
end

function fitsOut = local_filter_fits_by_mask(fitsIn, keepMask)
% Support common fits storage patterns.
if isstruct(fitsIn)
    if numel(fitsIn) == numel(keepMask)
        % struct array, 1 element per row
        fitsOut = fitsIn(keepMask);
        return;
    else
        % scalar struct with fields that are row-aligned vectors/cells
        fitsOut = fitsIn;
        fns = fieldnames(fitsIn);
        for k = 1:numel(fns)
            v = fitsIn.(fns{k});
            try
                if isnumeric(v) || islogical(v)
                    if size(v,1) == numel(keepMask)
                        fitsOut.(fns{k}) = v(keepMask,:);
                    end
                elseif iscell(v) || isstring(v)
                    if size(v,1) == numel(keepMask)
                        fitsOut.(fns{k}) = v(keepMask,:);
                    end
                end
            catch
                % leave field unchanged if indexing fails
            end
        end
        return;
    end
else
    error("fits must be a struct (either struct array or scalar struct with row-aligned fields).");
end
end

function n = local_len_fits(f)
if isstruct(f)
    n = numel(f);
else
    n = NaN;
end
end



function [delta_auc, delta_p] = getAUCs2Bins(t, t0, tMid, tEnd, S1, S2)

delta_auc = zeros(2, size(S1,2));
delta_auc(1,:) = getDeltaAUC(t, t0,   tMid, S1, S2);
delta_auc(2,:) = getDeltaAUC(t, tMid, tEnd, S1, S2);

delta_p = zeros(2,1);
[~, delta_p(1)] = ttest(delta_auc(1,:), 0);
[~, delta_p(2)] = ttest(delta_auc(2,:), 0);

end

function p = pvalsLME_vsZero(dAUC_2xN, animal_id)
% p is 2x1 p-values for intercept vs 0 in each bin

p = nan(2,1);
animal = categorical(animal_id);

for b = 1:2
    y = dAUC_2xN(b,:)';
    T = table(y, animal, 'VariableNames', {'dAUC','animal'});
    lme = fitlme(T, 'dAUC ~ 1 + (1|animal)');
    coef = lme.Coefficients;
    p(b) = coef.pValue(strcmp(coef.Name,'(Intercept)'));
end
end

function p = pvalsLME_vsZero_bins(D_BxN, animal_id)
% D_BxN: B x N (bins x streams), each column corresponds to a stream
% animal_id: N x 1 or 1 x N identifiers (strings/cellstr/etc.)
% Returns p: B x 1 p-values for intercept vs 0 per bin

animal_id = string(animal_id(:));
animal = categorical(animal_id);

B = size(D_BxN,1);
N = size(D_BxN,2);
assert(numel(animal)==N, 'animal_id must have length N = number of columns in D_BxN.');

p = nan(B,1);

for b = 1:B
    y = D_BxN(b,:)';
    T = table(y, animal, 'VariableNames', {'y','animal'});
    lme = fitlme(T, 'y ~ 1 + (1|animal)');
    coef = lme.Coefficients;
    p(b) = coef.pValue(strcmp(coef.Name,'(Intercept)'));
end
end

function plotDeltaAUC2Bins_barScatter(dAUC_2xN, p_2, panelTitle, yLims)

if size(dAUC_2xN,1) ~= 2
    error('Expected dAUC to be 2xN (2 bins by units).');
end

N = size(dAUC_2xN,2);
x = 1:2;

% mean ± SEM
m = mean(dAUC_2xN, 2, 'omitnan');
s = std(dAUC_2xN, 0, 2, 'omitnan');
nEff = sum(~isnan(dAUC_2xN), 2);
sem = s ./ max(sqrt(nEff),1);

hold on;

bar(x, m, 0.7);
errorbar(x, m, sem, 'LineStyle','none', 'LineWidth', 1);

% individual points
jitterAmp = 0.12;
for b = 1:2
    y = dAUC_2xN(b,:);
    xj = x(b) + (rand(1,N)-0.5)*2*jitterAmp;
    scatter(xj, y, 28, 'filled', 'MarkerFaceAlpha', 0.85);
end

yline(0,'--','LineWidth',1);

% p-value annotation
if nargin >= 2 && ~isempty(p_2)
    ySpan = max(dAUC_2xN(:),[],'omitnan') - min(dAUC_2xN(:),[],'omitnan');
    if ySpan==0 || isnan(ySpan), ySpan=1; end
    yTop = max([m + sem, max(dAUC_2xN,[],2,'omitnan')], [], 2) + 0.06*ySpan;
    for b = 1:2
        text(x(b), yTop(b), sprintf('p=%.3g', p_2(b)), ...
            'HorizontalAlignment','center', 'FontSize', 9);
    end
end

xlim([0.5 2.5]);
xticks(1:2);
xticklabels({'early','late'});
xtickangle(35);

ylabel('\DeltaAUC');
title(panelTitle, 'Interpreter','none');

if nargin >= 4 && ~isempty(yLims)
    ylim(yLims);
end

box off;
set(gca,'TickDir','out');
hold off;
end

function [dAUC_animal, animals] = collapseToAnimalMeans(dAUC_stream, animal_id)
% dAUC_stream: B x Nstreams
% animal_id:   Nstreams x 1 (or 1 x Nstreams)
% dAUC_animal: B x Nanimals (mean across streams within animal)

animal_id = string(animal_id(:));  % force column
N = size(dAUC_stream,2);
assert(numel(animal_id)==N, 'animal_id length must match # columns in dAUC');

animals = unique(animal_id, 'stable');
nA = numel(animals);
B = size(dAUC_stream,1);

dAUC_animal = nan(B, nA);

for a = 1:nA
    idx = (animal_id == animals(a));
    dAUC_animal(:,a) = mean(dAUC_stream(:,idx), 2, 'omitnan');
end
end

function plotDeltaAUC2Bins_barScatter_animals(dAUC_stream_2xN, animal_id, p_2, panelTitle, yLims)

% collapse streams -> per-animal means
animal_id = string(animal_id(:));
animals = unique(animal_id, 'stable');
B = size(dAUC_stream_2xN,1);
nA = numel(animals);

dAUC = nan(B, nA);
for a = 1:nA
    idx = animal_id == animals(a);
    dAUC(:,a) = mean(dAUC_stream_2xN(:,idx), 2, 'omitnan');
end

x = 1:2;

% mean ± SEM across animals
m = mean(dAUC, 2, 'omitnan');
s = std(dAUC, 0, 2, 'omitnan');
nEff = sum(~isnan(dAUC), 2);
sem = s ./ max(sqrt(nEff),1);

hold on;

bar(x, m, 0.7);
errorbar(x, m, sem, 'LineStyle','none', 'LineWidth', 1);
yline(0,'--','LineWidth',1);

% per-animal dots (no lines, I promise)
jitterAmp = 0.10;
for b = 1:2
    xj = x(b) + (rand(1,nA)-0.5)*2*jitterAmp;
    scatter(xj, dAUC(b,:), 36, 'filled', 'MarkerFaceAlpha', 0.85);
end

% p-value annotation
if nargin >= 3 && ~isempty(p_2) && numel(p_2)==2
    ySpan = max(dAUC(:),[],'omitnan') - min(dAUC(:),[],'omitnan');
    if ySpan==0 || isnan(ySpan), ySpan=1; end
    yTop = max([m + sem, max(dAUC,[],2,'omitnan')], [], 2) + 0.06*ySpan;
    for b = 1:2
        text(x(b), yTop(b), sprintf('p=%.3g', p_2(b)), ...
            'HorizontalAlignment','center', 'FontSize', 9);
    end
end

xlim([0.5 2.5]);
xticks(1:2);
xticklabels({'early','late'});
xtickangle(35);

ylabel('\DeltaAUC');
title(sprintf('%s (n=%d animals)', panelTitle, nA), 'Interpreter','none');

if nargin >= 5 && ~isempty(yLims)
    ylim(yLims);
end

box off;
set(gca,'TickDir','out');
hold off;
end


function [qvals, sig, pcrit] = bh_fdr(pvals, q)
% bh_fdr: Benjamini-Hochberg FDR correction for a vector of p-values
% pvals: vector (m x 1 or 1 x m)
% q: desired FDR level (default 0.05)
%
% qvals: BH-adjusted q-values (same shape as pvals)
% sig: boolean mask of discoveries at level q
% pcrit: critical p threshold (largest p called significant); NaN if none

if nargin < 2 || isempty(q), q = 0.05; end

p = pvals(:);
m = numel(p);

% handle NaNs (keep them as NaN in qvals; ignore in procedure)
valid = ~isnan(p);
pv = p(valid);
m0 = numel(pv);

qvals = nan(size(p));
sig   = false(size(p));
pcrit = NaN;

if m0 == 0
    qvals = reshape(qvals, size(pvals));
    sig   = reshape(sig,   size(pvals));
    return
end

[p_sorted, order] = sort(pv, 'ascend');

% BH "step-up" thresholding
thresh = (1:m0)'/m0 * q;
k = find(p_sorted <= thresh, 1, 'last');
if ~isempty(k)
    sig_sorted = false(m0,1);
    sig_sorted(1:k) = true;
    sig_valid = false(m0,1);
    sig_valid(order) = sig_sorted;
    sig(valid) = sig_valid;
    pcrit = p_sorted(k);
end

% BH-adjusted q-values (monotone)
q_sorted = p_sorted .* (m0 ./ (1:m0)');
q_sorted = min( cummin(flipud(q_sorted)), 1 );
q_sorted = flipud(q_sorted);

q_valid = nan(m0,1);
q_valid(order) = q_sorted;
qvals(valid) = q_valid;

% reshape to match input
qvals = reshape(qvals, size(pvals));
sig   = reshape(sig,   size(pvals));
end

function pk = peak_anchor_topk(t, M, tPeakWin, tAnchor, k)
% t: nTime x 1 (or 1 x nTime)
% M: nTime x nStreams
% pk: 1 x nStreams

if nargin < 3 || isempty(tPeakWin), tPeakWin = [0 0.4]; end
if nargin < 4 || isempty(tAnchor),  tAnchor  = 0;      end
if nargin < 5 || isempty(k),        k = 5;            end

t = t(:);
assert(size(M,1) == numel(t), 'M must be time x nStreams.');

ixP = t>=tPeakWin(1) & t<=tPeakWin(2);
assert(any(ixP), 'No samples in peak window.');

[~, i0] = min(abs(t - tAnchor));

X = M(ixP, :).';                 % nStreams x nWin
pkPeak = mean(maxk(X, k, 2), 2); % nStreams x 1 (robust peak)
pk0 = M(i0,:).';                 % nStreams x 1

pk = (pkPeak - pk0).';           % 1 x nStreams
end

function dpk = getDeltaPeak(t, M1, M2, tPeakWin, tAnchor, k)
pk1 = peak_anchor_topk(t, M1, tPeakWin, tAnchor, k);
pk2 = peak_anchor_topk(t, M2, tPeakWin, tAnchor, k);
dpk = pk1 - pk2;   % 1 x nStreams
end