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
