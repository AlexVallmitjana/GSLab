function [photons, cube] = ptu2flim(filename, verb)
% PTU2FLIM  Read a PicoHarp T3 format .ptu file (e.g. Leica SP8-SMD /
%           SymPhoTime) and return per-photon pixel coordinates and a
%           FLIM intensity cube.
%
%   [photons, cube] = ptu2flim(filename)
%   [photons, cube] = ptu2flim(filename, verb)   verb=0 suppresses output
%
%   Outputs
%     photons  : struct (one entry per valid photon)
%                  .x        - pixel column  (uint16, 0-based)
%                  .y        - pixel row     (uint16, 1-based)
%                  .frame    - frame index   (uint16, 1-based)
%                  .dtime    - TCSPC bin, folded into one sync period (uint16)
%                  .chan     - detector channel (uint8)
%                  .abs_time - absolute macro-time (uint64, nsync units)
%     cube     : [Ny x Nx x Nbins] uint32 array summed over all frames
%
%   Requires readPtuHeader() which returns:
%     H.Tags       - struct of tag name/value pairs
%     H.DataOffset - byte offset where TTTR records begin
%
%   ---------------------------------------------------------------
%   PicoHarp T3 record layout (RecType 0x00010303):
%     bits  0-15 : nsync  (16-bit macro-time counter, overflow = 65536)
%     bits 16-27 : dtime  (12-bit TCSPC bin)
%     bits 28-31 : chan   (4-bit; 15 = special record)
%
%     Special records (chan == 15):
%       dtime == 0          : overflow
%       dtime == LINE_START : line-start marker  (bitmask in dtime)
%       dtime == LINE_STOP  : line-stop  marker
%       dtime == FRAME_MARK : frame marker
%     nsync in a marker record = sync counter at time of marker (NOT the type).
%
%   Frame marker convention (auto-detected):
%     Start-of-frame : marker fires before its lines (Leica SP8-SMD).
%     End-of-frame   : marker fires after  its lines (some instruments).
%
%   Pixel dwell strategy:
%     Integer pixel dwell = round(median_period / Nx) avoids fractional
%     accumulation and the resulting periodic stripe artefact.
%     Line-stop markers refine the active window when reliable.
%   ---------------------------------------------------------------

if nargin < 2, verb = 1; end

% =========================================================
% Header
% =========================================================
H = readPtuHeader(filename);

% =========================================================
% Read raw TTTR records
% =========================================================
fid = fopen(filename, 'r', 'ieee-le');
assert(fid > 0, 'Cannot open file: %s', filename);
cleanup = onCleanup(@() fclose(fid));

N   = double(H.Tags.TTResult_NumberOfRecords);
fseek(fid, H.DataOffset, 'bof');
raw = fread(fid, N, 'uint32=>uint32');

% =========================================================
% Decode PicoHarp T3 records
%   bits  0-15 : nsync  (16-bit macro-time counter)
%   bits 16-27 : dtime  (12-bit TCSPC bin)
%   bits 28-31 : chan   (4-bit channel; 15 = special)
% =========================================================
nsync = uint16(bitand(raw,               uint32(65535)));  % bits  0-15: 16-bit sync counter  [FIX 1]
dtime = uint16(bitand(bitshift(raw,-16), uint32( 4095)));  % bits 16-27: 12-bit TCSPC bin     [FIX 1]
chan  =  uint8(bitand(bitshift(raw,-28), uint32(   15)));  % bits 28-31: channel (15=special)


% =========================================================
% Classify records
%   Overflow : chan==15 AND dtime==0
%   Marker   : chan==15 AND dtime!=0  (dtime holds the bitmask)
%   Photon   : chan != 15
% =========================================================
is_special  = (chan == uint8(15));
is_overflow = is_special & (dtime == uint16(0));  % discriminate on dtime  [FIX 2]
is_marker   = is_special & (dtime ~= uint16(0));  % discriminate on dtime  [FIX 2]
is_photon   = ~is_special;


% Absolute macro-time (uint64)
ov_count  = uint64(cumsum(double(is_overflow)));
abs_nsync = ov_count * uint64(65536) + uint64(nsync);

% =========================================================
% Imaging parameters
% SymPhoTime ImgHdr tags store INPUT NUMBER (1-based).
% Actual dtime bitmask in record = 2^(input-1).
% =========================================================
Nx         = double(H.Tags.ImgHdr_PixX);
Ny         = double(H.Tags.ImgHdr_PixY);
LINE_START = uint16(2^(H.Tags.ImgHdr_LineStart - 1));
LINE_STOP  = uint16(2^(H.Tags.ImgHdr_LineStop  - 1));
FRAME_MARK = uint16(2^(H.Tags.ImgHdr_Frame     - 1));
bi_direct  = isfield(H.Tags,'ImgHdr_BiDirect') && H.Tags.ImgHdr_BiDirect;

if verb
    fprintf('         Marker nsync values: LINE_START=%d  LINE_STOP=%d  FRAME_MARK=%d\n', ...
        LINE_START, LINE_STOP, FRAME_MARK);
end

% =========================================================
% TCSPC parameters
%   TTResult_SyncRate   = actual sync rate at hardware input (Hz)
%   MeasDesc_Resolution = TCSPC bin width (s)
%   Nbins               = bins per sync period
%   Sync divider detected when dtime spans multiple laser periods.
%   Dtimes folded mod Nbins collapses all periods into one.
% =========================================================
tcspc_bin_s   = H.Tags.MeasDesc_Resolution;
sync_rate_Hz  = H.Tags.TTResult_SyncRate;
sync_period_s = 1 / sync_rate_Hz;
Nbins         = round(sync_period_s / tcspc_bin_s);

if verb
    fprintf('         Sync rate: %.4f MHz  |  Sync period: %.2f ns  |  TCSPC bin: %.1f ps  |  Nbins: %d\n', ...
        sync_rate_Hz/1e6, sync_period_s*1e9, tcspc_bin_s*1e12, Nbins);
end

% Detect sync divider from raw dtime range
raw_dtime_periods = round((double(max(dtime(is_photon)))+1) / Nbins);
if raw_dtime_periods > 1
    if verb
        fprintf('         Sync divider detected: ~%dx  (dtime spans ~%d laser periods)\n', ...
            raw_dtime_periods, raw_dtime_periods);
        fprintf('         Dtimes will be folded modulo %d bins\n', Nbins);
    end
end

% Extract marker timestamps
% Marker type bitmask is in the dtime field.  nsync holds the sync
% counter at the time of the marker and is NOT the type identifier.
marker_type  = dtime(is_marker);        % bitmask: 1=LINE_START, 2=LINE_STOP, 4=FRAME  [FIX 2]
marker_times = abs_nsync(is_marker);


t_frame  = marker_times(marker_type == FRAME_MARK);
t_lstart = marker_times(marker_type == LINE_START);
t_lstop  = marker_times(marker_type == LINE_STOP);

nFrames = numel(t_frame);
if verb
    fprintf('         Frames: %d  |  Line starts: %d\n', nFrames, numel(t_lstart));
end

if nFrames == 0                                 % [FIX 3] guard before indexing t_lstart
    if isempty(t_lstart)
        error('ptu2flim: no line-start markers found — check file and bit extraction.');
    end
    t_frame = t_lstart(1);
    nFrames = 1;
    ensenya('Warning: no frame markers found, treating entire acquisition as one frame.','a');
end


% =========================================================
% Pixel dwell and line window duration
%
% pixel_dwell_int MUST be computed here, before t_line_end is built.
%
% Default: derive integer pixel dwell from the full line period.
%   pixel_dwell_int = round(median_period / Nx)
%   t_line_nsync    = pixel_dwell_int * Nx   (integer-aligned full window)
%
% This eliminates the fractional-dwell stripe artefact caused by the
% old 75% fallback (e.g. 83200*0.75/256 = 243.75, a 4:3 compression).
%
% If line-stop markers are reliable they narrow the active window and
% pixel_dwell_int is recomputed from the shorter duration.
% =========================================================
t_lstart_sorted = sort(t_lstart);
median_period   = median(double(diff(t_lstart_sorted)));  % nsync units

% --- Default: integer pixel dwell from full line period ---    [FIX 4]
pixel_dwell_int = round(median_period / Nx);    % e.g. 83200/256 = 325 exactly
t_line_nsync    = pixel_dwell_int * Nx;          % integer-aligned window width


% --- Try to refine with line-stop markers ---
if numel(t_lstop) == numel(t_lstart)
    t_lstop_sorted = sort(t_lstop);
    n_pairs        = min(numel(t_lstart_sorted), numel(t_lstop_sorted));
    raw_durations  = double(t_lstop_sorted(1:n_pairs)) - ...
                     double(t_lstart_sorted(1:n_pairs));
    valid_dur      = raw_durations > 0 & raw_durations < median_period;
    if sum(valid_dur) > n_pairs * 0.5
        t_line_nsync    = round(median(raw_durations(valid_dur)));
        
pixel_dwell_int = round(t_line_nsync / Nx);  % recompute from refined window [FIX 4]

        duty_cycle      = t_line_nsync / median_period;
        if verb
            fprintf('         Pixel dwell from line-stop markers: duty cycle=%.1f%%\n', ...
                100*duty_cycle);
        end
    else
        if verb
            fprintf('         Line-stop markers unreliable, using integer pixel dwell from line period\n');
        end
    end
else
    if verb
        fprintf('         No matching line-stop markers, using integer pixel dwell from line period\n');
    end
end

if verb
    fprintf('         Line period  : %.1f nsync units  (%.2f us)\n', ...
        median_period, median_period * sync_period_s * 1e6);
    fprintf('         Line duration: %d nsync units  (%.2f us)\n', ...
        t_line_nsync, t_line_nsync * sync_period_s * 1e6);
    fprintf('         Duty cycle   : %.1f%%\n', 100 * t_line_nsync / median_period);
end

% =========================================================
% Build line windows
%   start = t_lstart_sorted
%   end   = start + t_line_nsync   (uses integer-aligned value above)
% =========================================================
t_line_begin = t_lstart_sorted;
t_line_end   = t_lstart_sorted + uint64(t_line_nsync);

% Clip windows that would overlap the next line-start
if numel(t_line_begin) > 1
    overlap = t_line_end(1:end-1) >= t_line_begin(2:end);
    if any(overlap)
        ensenya(['Warning: ' num2str(sum(overlap)) ' line windows clipped to prevent overlap.'],'a');
        t_line_end(1:end-1) = min(t_line_end(1:end-1), ...
                                  t_line_begin(2:end) - uint64(1));
    end
end

% =========================================================
% Frame and within-frame line index
%
% Auto-detect frame marker convention:
%   Start-of-frame: marker before lines -> sum(>= t_frame) > 0 for most lines
%   End-of-frame  : marker after  lines -> >80% of lines get frame_of_line==0
% =========================================================
frame_of_line = uint32(sum(t_line_begin(:) >= t_frame(:)', 2));

frac_unassigned = sum(frame_of_line == 0) / max(numel(frame_of_line), 1);  % [FIX 3]
if frac_unassigned > 0.8 && nFrames >= 1
    if verb
        fprintf('         End-of-frame marker convention detected — remapping line indices\n');
    end
    frame_of_line = uint32(sum(t_line_begin(:) > t_frame(:)', 2)) + uint32(1);
    frame_of_line = min(frame_of_line, uint32(nFrames));
end


line_in_frame_matched = zeros(numel(t_line_begin), 1, 'uint32');
for f = 1:nFrames
    idx = (frame_of_line == f);
    line_in_frame_matched(idx) = uint32(1:sum(idx));
end

n_lines = numel(t_line_begin);
if verb
    fprintf('         Total lines  : %d  (expected %d)\n', n_lines, Ny * nFrames);
end

% =========================================================
% Extract photon arrays
% =========================================================
ph_times = abs_nsync(is_photon);
ph_dtime = dtime(is_photon);
ph_chan  = chan(is_photon);

% Fold dtime into one laser period
ph_dtime_folded = uint16(mod(double(ph_dtime), Nbins));

% =========================================================
% Assign photons to line windows via paired-edge discretize.
% Edges alternate begin(k) / end(k)+1 so only ODD bin indices
% are valid line windows; even bins = flyback / inter-line gaps.
% =========================================================
edges_paired          = zeros(2*n_lines, 1, 'double');
edges_paired(1:2:end) = double(t_line_begin);
edges_paired(2:2:end) = double(t_line_end) + 1;

bin_idx  = discretize(double(ph_times), edges_paired);
valid    = ~isnan(bin_idx) & (mod(bin_idx,2) == 1);
ls_idx_v = (bin_idx(valid) + 1) / 2;   % line index 1..n_lines

% =========================================================
% Pixel coordinates
%
% x_coord uses pixel_dwell_int (integer nsync per pixel) rather than
% dividing by continuous t_len.  This guarantees all 256 column
% boundaries land on exact integer nsync values, eliminating the
% periodic stripe artefact from fractional dwell accumulation.
% =========================================================
t_in    = double(ph_times(valid)) - double(t_line_begin(ls_idx_v));
x_coord = uint16(min(floor(t_in / pixel_dwell_int), Nx-1));  % 0-based  [FIX 4]

y_coord = uint16(line_in_frame_matched(ls_idx_v));              % 1-based
f_coord = uint16(frame_of_line(ls_idx_v));                      % 1-based

% Bidirectional: flip x on odd 1-based rows (reverse scan passes)
if bi_direct
    flip_mask          = mod(double(y_coord), 2) == 1;
    x_coord(flip_mask) = uint16(Nx-1) - x_coord(flip_mask);
end

% =========================================================
% Pack photon output struct
% =========================================================
valid_idx        = find(valid);
photons.x        = x_coord;
photons.y        = y_coord;
photons.frame    = f_coord;
photons.dtime    = ph_dtime_folded(valid_idx);
photons.chan     = ph_chan(valid_idx);
photons.abs_time = ph_times(valid_idx);

if verb
    fprintf('         Valid photons: %d / %d  (%.1f%%)\n', ...
        numel(valid_idx), numel(ph_times), 100*numel(valid_idx)/numel(ph_times));
end

% =========================================================
% FLIM cube  [Ny x Nx x Nbins]  summed over all frames
% All dtimes are in [0, Nbins-1] after folding.
% =========================================================
xi = double(photons.x) + 1;       % 1-based column
yi = double(photons.y);            % 1-based row
ti = double(photons.dtime) + 1;   % 1-based bin

% Clamp (no-op after folding, but guards against edge cases)
keep = xi >= 1 & xi <= Nx  & ...
       yi >= 1 & yi <= Ny  & ...
       ti >= 1 & ti <= Nbins;
if any(~keep)
    ensenya(['Warning: ' num2str(sum(~keep)) ' photons out of cube range after folding.'],'a');
end
xi = xi(keep);
yi = yi(keep);
ti = ti(keep);

% Column-major linear index into [Ny x Nx x Nbins]
lin_idx = (ti-1)*(Ny*Nx) + (xi-1)*Ny + yi;
cube    = accumarray(lin_idx, 1, [Ny*Nx*Nbins, 1], @sum, 0, false);
cube    = uint32(reshape(cube, Ny, Nx, Nbins));

if verb
    fprintf('         Cube size: [%d x %d x %d]  |  Total counts: %d\n', ...
        Ny, Nx, Nbins, sum(cube(:)));
end

end