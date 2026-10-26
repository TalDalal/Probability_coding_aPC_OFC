function sniff_samples = detect_sniff_onsets(resp, fs, min_sniff_length)
%DETECT_SNIFF_ONSETS Detect inhalation and exhalation onsets from respiration signal.
%
%   sniff_samples = detect_sniff_onsets(resp, fs, min_sniff_length)
%
%   Input:
%       resp              - respiration signal (not necessarily zero-centered)
%       fs                - sampling rate (Hz)
%       min_sniff_length  - minimum sniff length in samples (default = 50 ms * fs)
%
%   Output:
%       sniff_samples     - 2 x N matrix of sample indices
%                           Row 1: inhalation onset sample
%                           Row 2: exhalation onset sample

if nargin < 3
    min_sniff_length = round(0.05 * fs); % default: 50 ms in samples
end

resp = resp(:); % Ensure column
resp = resp - mean(resp); % Zero-center

% Find zero crossings
zc = find(resp(1:end-1) .* resp(2:end) < 0);
% Interpolated sub-sample positions
zc_interp = zc - resp(zc) ./ (resp(zc + 1) - resp(zc));
zc_sign = sign(resp(zc + 1) - resp(zc));

% Separate inhalation (neg-going) and exhalation (pos-going)
inh_idx = zc_interp(zc_sign < 0);
exh_idx = zc_interp(zc_sign > 0);

% Pair sniff cycles
sniff_samples = [];
i = 1; j = 1;
while i <= length(inh_idx) && j <= length(exh_idx)
    if inh_idx(i) < exh_idx(j)
        duration = exh_idx(j) - inh_idx(i);
        if duration >= min_sniff_length
            sniff_samples(:, end+1) = round([inh_idx(i); exh_idx(j)]); %#ok<AGROW>
        end
        i = i + 1;
        j = j + 1;
    else
        j = j + 1;
    end
end

end
