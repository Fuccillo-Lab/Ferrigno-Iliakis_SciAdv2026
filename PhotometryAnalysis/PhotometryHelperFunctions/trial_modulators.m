function [F,I,FI] = trial_modulators(sessTrials, cfg)
% Returns effect-coded modulators per trial:
% F: frequency high/low  (+0.5/-0.5)
% I: instruction nogo/go (+0.5/-0.5)
% FI: interaction

go_is_high = sessTrials.go_is_high(1);   % session-level flag (should be constant)

% Instruction from tone_type
isGo   = strcmpi(sessTrials.tone_type, "go");
isNoGo = strcmpi(sessTrials.tone_type, "nogo");

I = nan(height(sessTrials),1);
I(isGo)   = cfg.code.go;     % -0.5
I(isNoGo) = cfg.code.nogo;   % +0.5

% Frequency: depends on counterbalancing
isHigh = false(height(sessTrials),1);
if go_is_high == 1
    % Go=High, NoGo=Low
    isHigh(isGo)   = true;
    isHigh(isNoGo) = false;
else
    % Go=Low, NoGo=High
    isHigh(isGo)   = false;
    isHigh(isNoGo) = true;
end

F = nan(height(sessTrials),1);
F(isHigh)  = cfg.code.high;  % +0.5
F(~isHigh) = cfg.code.low;   % -0.5

FI = F .* I;
end