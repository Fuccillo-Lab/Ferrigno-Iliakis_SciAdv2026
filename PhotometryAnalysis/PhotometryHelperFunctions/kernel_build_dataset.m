function KD = kernel_build_dataset(fits, sessions, varargin)
% kernel_build_dataset
% Build a tidy dataset of kernels + metadata by joining fits to sessions.
%
% KD = kernel_build_dataset(fits, sessions, 'CellType',"a2a", 'UseOnlyGood',true, ...
%     'Unit',"animal_hemi", 'HemiFrom',"stream_uid");
%
% OUTPUT KD fields:
%   KD.rows : struct array, one per unit (stream OR animal_hemi OR animal)
%       .stream_uid .session_uid .animal_id .cell_type .go_is_high .n_fa .lambda_star
%       .hemi (if inferred)
%       .kernels.<kernelName> : vector
%   KD.t : time axes struct: .trialStart .tone .outcome
%
% Assumptions from your data:
%   - fits(i).kernels has the kernel vectors
%   - fits(i).lags has time vectors for trialStart/tone/outcome (shared across relevant kernels)
%   - session_uid links fits <-> sessions
%   - sessions has n_fa and go_is_high etc.

p = inputParser;
p.addParameter('CellType', "", @(x) isstring(x) || ischar(x));
p.addParameter('UseOnlyGood', true, @islogical);     % drop failed / qc.bad if present
p.addParameter('Unit', "animal_hemi", @(x) any(strcmpi(string(x), ["stream","animal_hemi","animal"])));
p.addParameter('HemiFrom', "stream_uid", @(x) any(strcmpi(string(x), ["stream_uid","meta","none"])));
p.addParameter('IncludeOutcome', "auto", @(x) any(strcmpi(string(x), ["auto","true","false"])));
p.parse(varargin{:});
opt = p.Results;

incOut = string(opt.IncludeOutcome);


% Basic checks
assert(isstruct(fits), "fits must be a struct array.");
assert(istable(sessions), "sessions must be a table.");

% Pull time axes once
KD = struct();
KD.t = struct();

% trialStart and tone are required for your use-case, but guard anyway
assert(isfield(fits(1),'lags'), "fits(1) missing lags.");
assert(isfield(fits(1).lags,'trialStart') && isfield(fits(1).lags,'tone'), ...
    "fits(1).lags must contain trialStart and tone.");

KD.t.trialStart = fits(1).lags.trialStart(:);
KD.t.tone       = fits(1).lags.tone(:);

% Outcome is optional
hasOutcomeLag = isfield(fits(1).lags,'outcome') && ~isempty(fits(1).lags.outcome);

if incOut=="true"
    assert(hasOutcomeLag, "IncludeOutcome=true but fits(1).lags.outcome is missing.");
    KD.t.outcome = fits(1).lags.outcome(:);
elseif incOut=="false"
    KD.t.outcome = [];
else % auto
    KD.t.outcome = [];
    if hasOutcomeLag
        KD.t.outcome = fits(1).lags.outcome(:);
    end
end


% kernels to keep (ignore dummies downstream, but keep them if you want)
kernelNames = string(fieldnames(fits(1).kernels));

% ---- Predefine template row struct (critical in MATLAB) ----
template = struct();
template.stream_uid  = "";
template.session_uid = "";
template.animal_id   = "";
template.cell_type   = "";
template.go_is_high  = NaN;
template.n_fa        = NaN;
template.lambda_star = NaN;
template.hemi        = "";

% Predefine kernels substruct with ALL kernel fields
template.kernels = struct();
for k = 1:numel(kernelNames)
    nm = kernelNames(k);
    template.kernels.(nm) = [];   % will become column vectors
end

% Preallocate maximum possible (fits count), then trim
rows = repmat(template, numel(fits), 1);
n = 0;

for i = 1:numel(fits)
    f = fits(i);

    % Drop failed/qc if requested
    if opt.UseOnlyGood
        if isfield(f,'failed') && any(f.failed), continue; end
        if isfield(f,'qc')
            if isfield(f.qc,'bad') && any(f.qc.bad), continue; end
            if isfield(f.qc,'is_bad') && any(f.qc.is_bad), continue; end
        end
    end

    % session_uid / stream_uid
    session_uid = "";
    stream_uid  = "";
    if isfield(f,'meta')
        if isfield(f.meta,'session_uid'), session_uid = string(f.meta.session_uid); end
        if isfield(f.meta,'stream_uid'),  stream_uid  = string(f.meta.stream_uid);  end
    end
    if strlength(session_uid)==0
        error("fit %d missing meta.session_uid", i);
    end

    % Join to sessions
    sidx = find(sessions.session_uid == session_uid, 1, 'first');
    if isempty(sidx), continue; end
    sess = sessions(sidx,:);

    % Cell type filter
    ct = string(sess.cell_type);
    if strlength(string(opt.CellType))>0 && ct ~= string(opt.CellType)
        continue;
    end

    % ---- Fill row ----
    n = n + 1;
    R = template;  % copy template so structure is identical

    R.stream_uid  = string(stream_uid);
    R.session_uid = string(session_uid);
    R.animal_id   = string(sess.animal_id);
    R.cell_type   = ct;
    R.go_is_high  = double(sess.go_is_high);
    R.n_fa        = double(sess.n_fa);

    % lambda
    if isfield(f,'cv') && isfield(f.cv,'lambda_star')
        R.lambda_star = double(f.cv.lambda_star);
    elseif isfield(f,'meta') && isfield(f.meta,'lambda_star')
        R.lambda_star = double(f.meta.lambda_star);
    end

    % hemi
    if opt.HemiFrom == "stream_uid"
        R.hemi = infer_hemi_from_stream_uid(string(stream_uid));
    elseif opt.HemiFrom == "meta"
        if isfield(f,'meta') && isfield(f.meta,'hemi'), R.hemi = string(f.meta.hemi); end
    end

    % kernels (force column vectors)
    for k = 1:numel(kernelNames)
        nm = kernelNames(k);
        R.kernels.(nm) = f.kernels.(nm)(:);
    end

    rows(n) = R;  % safe: identical structure
end

rows = rows(1:n);  % trim

assert(~isempty(rows), "No fits survived filtering.");

% Aggregate into chosen Unit
KD.rows = aggregate_rows(rows, opt.Unit, kernelNames);

KD.kernelNames = kernelNames;
KD.unit = string(opt.Unit);

end

% ---------------- Helpers ----------------

function hemi = infer_hemi_from_stream_uid(stream_uid)
% Heuristic: looks for trailing _L/_R or '-L'/'-R' or ' L'/' R'
s = upper(string(stream_uid));
hemi = "";
if contains(s, "_L") || endsWith(s,"L")
    hemi = "L";
elseif contains(s, "_R") || endsWith(s,"R")
    hemi = "R";
end
end

function outRows = aggregate_rows(rows, unitMode, kernelNames)
unitMode = string(unitMode);

if unitMode=="stream"
    outRows = rows;
    return
end

% Build grouping keys
keys = strings(1, numel(rows));
for i = 1:numel(rows)
    if unitMode=="animal"
        keys(i) = rows(i).animal_id;
    elseif unitMode=="animal_hemi"
        keys(i) = rows(i).animal_id + "|" + rows(i).hemi;
    else
        error("Unknown unitMode");
    end
end

uKeys = unique(keys);

% ---- TEMPLATE: keep exact structure (including kernels fields) ----
template = rows(1);

% Preallocate maximum possible, then trim
outRows = repmat(template, numel(uKeys), 1);
nOut = 0;

for ui = 1:numel(uKeys)
    k = uKeys(ui);
    idx = find(keys==k);

    % Start from template (guarantees identical field layout)
    base = template;

    % Copy representative metadata from first element in group
    rep = rows(idx(1));
    base.stream_uid  = rep.stream_uid;
    base.session_uid = rep.session_uid;
    base.animal_id   = rep.animal_id;
    base.cell_type   = rep.cell_type;
    base.go_is_high  = rep.go_is_high;
    base.hemi        = rep.hemi;
    base.lambda_star = rep.lambda_star;

    % Average kernels across grouped rows
    for kn = 1:numel(kernelNames)
        nm = kernelNames(kn);

        % expected length from the first element in group
        v0 = rows(idx(1)).kernels.(nm);
        nT = numel(v0);

        % preallocate (time x nRowsInGroup)
        M = nan(nT, numel(idx));

        % fill columns
        for j = 1:numel(idx)
            v = rows(idx(j)).kernels.(nm);
            % (optional sanity check)
            if numel(v) ~= nT
                error("Kernel %s length mismatch within group %s.", nm, k);
            end
            M(:,j) = v(:);
        end

        base.kernels.(nm) = mean(M, 2, 'omitnan');
    end


    % counts: mean (or sum, but mean is fine for gating thresholds)
    base.n_fa = mean([rows(idx).n_fa], 'omitnan');

    nOut = nOut + 1;
    outRows(nOut) = base;
end

outRows = outRows(1:nOut);

end