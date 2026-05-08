function KD = KD_fromFitsStreams(fits, streams, KD_template, varargin)
% KD_fromFitsStreams
% Build a KD struct compatible with kernel_plot, where each KD.rows(i) is a stream.
%
% Assumes fits(i) corresponds 1:1 to streams(i).

p = inputParser;
p.addParameter('IncludeOnly', true, @islogical); % if true, use streams.include==1
p.addParameter('CellType', "any", @(x) isstring(x) || ischar(x));
p.parse(varargin{:});
opt = p.Results;

KD = struct();

% Copy time axes + unit if provided
if nargin >= 3 && ~isempty(KD_template)
    if isfield(KD_template,'t');    KD.t = KD_template.t; end
    if isfield(KD_template,'unit'); KD.unit = KD_template.unit; else, KD.unit = "stream"; end
else
    % Fallback: infer tone axis from kernel length and 40 Hz
    KD.t.tone = (0:size(fits(1).kernels.tone_main,1)-1)' * 0.025;
    KD.unit = "stream";
end

% Select rows
keep = true(height(streams),1);
if opt.IncludeOnly && ismember('include', streams.Properties.VariableNames)
    keep = keep & (streams.include == 1);
end
if opt.CellType ~= "any" && ismember('cell_type', streams.Properties.VariableNames)
    keep = keep & (string(streams.cell_type) == string(opt.CellType));
end

idx = find(keep);

rows = repmat(struct(), numel(idx), 1);
for k = 1:numel(idx)
    i = idx(k);

    rows(k).kernels = fits(i).kernels;

    % fields kernel_plot expects / uses
    rows(k).go_is_high = streams.go_is_high(i);

    % optional extras (useful later)
    rows(k).animal_id  = string(streams.animal_id(i));
    rows(k).session_uid = string(streams.session_uid(i));
    rows(k).stream_uid  = string(streams.stream_uid(i));

    % FA gating support if you ever use it in kernel_plot
    if isfield(fits(i),'n_fa')
        rows(k).n_fa = fits(i).n_fa;
    elseif ismember('nrxn', streams.Properties.VariableNames)
        % only if you want: placeholder; better to attach real n_fa if needed
        rows(k).n_fa = NaN;
    end
end

KD.rows = rows;
end