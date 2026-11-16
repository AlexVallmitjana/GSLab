function [vol, info] = ptu2flim(file, varargin)
% PTU_DECODE  Native MATLAB decoder for PicoQuant T3 .ptu imaging files.
% Written by CLAUDE inspired by Martin Skorsetz 
%   [vol, info] = ptu_decode(file)
%   [vol, info] = ptu_decode(file, 'Mode','auto', 'TailPixels',1, ...
%                                  'PixelMarker',[], 'Verbose',true)
%
% Merges two earlier readers into one:
%   * ptu2flim.m        : PicoHarp-T3 / Leica SP8-SMD / SymPhoTime files where
%                         pixels are defined by line (and frame) markers and
%                         pixel columns are derived from timing. - Vallmitjana
%   * ptu_read_markers.m: HydraHarp/MultiHarp-style T3 files that carry one
%                         marker record per pixel (e.g. "MPTc_004"). -Skorsetz
%
% OUTPUT
%   vol  : single, 1 x Y x X x C x H  (same layout as GSLab's ptuf.py),
%          all frames summed, C = detector channels present, H = TCSPC bins.
%   info : struct (mode used, record format, marker statistics, photon counts,
%          strategies that failed before the one that worked, ...).
%
% OPTIONS
%   Mode        'auto' (default) | 'pixel' | 'line'
%               auto: use per-pixel markers if the file has them, otherwise
%               line markers. If the first strategy errors or yields <1000
%               photons, the other one is tried.
%   PixelMarker force the marker value (mask) used as pixel marker ([] = auto)
%   TailPixels  pixel mode only: photons in the last pixel of each line are
%               kept only within TailPixels*pixel time of that pixel's marker
%               (removes turnaround/flyback photons). Inf disables. Default 1.
%   Verbose     print progress (default true)
%   LineTiming  line mode only. 'integer' (default, ptu2flim behaviour): pixel
%               columns from whole sync counts. 'fine': adds the TCSPC bin as a
%               sub-sync time and uses the exact (non-integer) dwell, which
%               removes quantisation stripes when a pixel lasts only a few
%               sync counts.
%
% SUPPORTED RECORD TYPES (T3 only)
%   0x00010303 PicoHarp T3 | 0x00010304 HydraHarp V1 T3 | 0x01010304 HydraHarp V2 T3
%   0x00010305 TimeHarp260 N T3 | 0x00010306 TimeHarp260 P T3 | 0x00010307 MultiHarp T3
%
% NOT reproduced from ptu2flim.m: the per-photon "photons" struct output.
%
% Memory: records are streamed in chunks; the output array (Y*X*C*H singles)
% and the marker time list (all special records) are held in memory.

    p = inputParser;
    addParameter(p, 'Mode', 'auto', @(s) any(strcmpi(s, {'auto', 'pixel', 'line'})));
    addParameter(p, 'PixelMarker', []);
    addParameter(p, 'TailPixels', 1);
    addParameter(p, 'Verbose', true);
    addParameter(p, 'LineTiming', 'integer', @(s) any(strcmpi(s, {'integer', 'fine'})));
    parse(p, varargin{:});
    opt = p.Results;
    opt.Mode = lower(opt.Mode);
    if isempty(opt.TailPixels), opt.TailPixels = 1; end

    ctx = scanFile(file, opt.Verbose);
    ctx.lineTiming = lower(opt.LineTiming);

    cands    = pixelCandidates(ctx, opt, false);   % header line/frame markers excluded
    candsAny = pixelCandidates(ctx, opt, true);    % any marker may be the pixel marker
    hasLine = ~isnan(ctx.maskLineStart) && any(ctx.maskIds == ctx.maskLineStart);

    switch opt.Mode
        case 'pixel', plan = {'pixelAny'};
        case 'line',  plan = {'line'};
        otherwise
            plan = {};
            if ~isempty(cands), plan{end+1} = 'pixel'; end
            if hasLine,         plan{end+1} = 'line';  end
            % last resort: the header may label the pixel marker as a line/frame marker
            if ~isempty(candsAny) && ~isequal(cands, candsAny), plan{end+1} = 'pixelAny'; end
    end
    if isempty(plan)
        error('ptu_decode:nostrategy', ...
            ['No pixel-marker channel and no line markers found.\n' ...
             'Marker values present: %s'], mat2str(ctx.maskIds(:)'));
    end

    errs = {};
    for i = 1:numel(plan)
        try
            switch plan{i}
                case 'pixel',    [vol, info] = runPixel(ctx, cands, opt);
                case 'pixelAny', [vol, info] = runPixel(ctx, candsAny, opt);
                case 'line',     [vol, info] = runLine(ctx, opt);
            end
            info.mode = strrep(plan{i}, 'Any', '');
            info.pixelMarkerOverridesHeader = strcmp(plan{i}, 'pixelAny');
            info.failedModes = errs;
            info.recordFormat = ctx.fmt.name;
            info.markerValues = [ctx.maskIds(:) ctx.maskCnt(:)];
            return
        catch ME
            errs{end+1} = sprintf('%s: %s', plan{i}, ME.message); %#ok<AGROW>
            say(ctx, '   [%s mode failed] %s\n', plan{i}, ME.message);
        end
    end
    error('ptu_decode:failed', 'No decoding strategy worked:\n%s', strjoin(errs, newline));
end

%% ========================================================================
%  Pass 1: header + one sweep over the records
%% ========================================================================
function ctx = scanFile(file, verbose)
    CHUNK = 2^22;

    [tags, dataOffset] = readHeader(file);
    recType = getNum(tags, 'TTResultFormat_TTTRRecType', -1);
    fmt = recordFormat(recType);

    ctx.file = file; ctx.verbose = verbose; ctx.CHUNK = CHUNK;
    ctx.tags = tags; ctx.dataOffset = dataOffset; ctx.fmt = fmt;
    ctx.recType = recType;
    ctx.nRec = getNum(tags, 'TTResult_NumberOfRecords', 0);
    ctx.nx = getNum(tags, 'ImgHdr_PixX', 512);
    ctx.ny = getNum(tags, 'ImgHdr_PixY', 512);
    ctx.nbins = inferNbins(tags);
    ctx.bidirect = getNum(tags, 'ImgHdr_BiDirect', 0) ~= 0;
    ctx.maskLineStart = tagMask(tags, 'ImgHdr_LineStart');
    ctx.maskLineStop  = tagMask(tags, 'ImgHdr_LineStop');
    ctx.maskFrame     = tagMask(tags, 'ImgHdr_Frame');
    if ctx.nx <= 0 || ctx.ny <= 0 || ctx.nRec <= 0
        error('ptu_decode:header', 'Bad image size or record count in header');
    end

    say(ctx, 'ptu_decode: %s | %d x %d px | %d bins | %d records\n', ...
        fmt.name, ctx.nx, ctx.ny, ctx.nbins, ctx.nRec);

    fid = fopen(file, 'r', 'ieee-le');
    if fid < 0, error('ptu_decode:open', 'Cannot open %s', file); end
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fseek(fid, dataOffset, 'bof');

    phCount = zeros(64, 1);
    ovfTotal = 0; mkM = {}; mkT = {}; maxDt = 0;
    left = ctx.nRec;
    while left > 0
        rec = fread(fid, min(CHUNK, left), 'uint32=>uint32');
        if isempty(rec), break; end
        left = left - numel(rec);
        d = decodeChunk(rec, fmt);
        [t, ovfTotal] = syncTimes(d, ovfTotal, fmt);
        if any(d.isPh)
            phCount = phCount + accumarray(d.chan(d.isPh) + 1, 1, [64 1]);
            maxDt = max(maxDt, max(d.dt(d.isPh)));
        end
        mkM{end+1} = uint16(d.mask(d.isMk)); %#ok<AGROW>
        mkT{end+1} = t(d.isMk);              %#ok<AGROW>
    end
    if isempty(mkM), ctx.mkMask = zeros(0,1,'uint16'); ctx.mkT = zeros(0,1);
    else, ctx.mkMask = vertcat(mkM{:}); ctx.mkT = vertcat(mkT{:}); end

    [ctx.maskIds, ~, ic] = unique(double(ctx.mkMask));
    if isempty(ic), ctx.maskCnt = zeros(0,1); else, ctx.maskCnt = accumarray(ic, 1); end
    ctx.phCount = phCount;
    ctx.maxDt = maxDt;
    ctx.photCh = find(phCount > 0)' - 1;
    if isempty(ctx.photCh), error('ptu_decode:nophotons', 'No photon records found'); end
    ctx.nC = numel(ctx.photCh);
    ctx.chMap = zeros(64, 1); ctx.chMap(ctx.photCh + 1) = 1:ctx.nC;   % column on purpose

    say(ctx, '   marker values (value: count): %s\n', ...
        strjoin(arrayfun(@(a, b) sprintf('%d: %d', a, b), ctx.maskIds(:)', ctx.maskCnt(:)', ...
        'UniformOutput', false), ' | '));
end

function cands = pixelCandidates(ctx, opt, relaxed)
% markers whose count is (almost) a whole number of frames of pixels
    pixels = ctx.nx * ctx.ny;
    cands = zeros(0, 3);                       % [value count distance]
    if ~isempty(opt.PixelMarker)
        k = find(ctx.maskIds == opt.PixelMarker, 1);
        if isempty(k)
            error('ptu_decode:pixelmarker', 'Marker value %d not present in file', opt.PixelMarker);
        end
        cands = [ctx.maskIds(k) ctx.maskCnt(k) 0];
        return
    end
    excl = [ctx.maskLineStart ctx.maskLineStop ctx.maskFrame];   % header-defined
    if relaxed, excl = []; end
    for k = 1:numel(ctx.maskIds)
        m = ctx.maskIds(k); n = ctx.maskCnt(k);
        if any(m == excl) || n < pixels, continue; end
        r = mod(n, pixels);
        dist = min(r, (pixels - r) * (r > 0));
        if dist <= max(8, floor(1e-4 * pixels))
            cands(end+1, :) = [m n dist]; %#ok<AGROW>
        end
    end
    if ~isempty(cands), cands = sortrows(cands, [3 2]); end
end

%% ========================================================================
%  Strategy A: one marker per pixel (HydraHarp/MultiHarp style)
%% ========================================================================
function [vol, info] = runPixel(ctx, cands, opt)
    if isempty(cands)
        error('no marker with a whole number of frames of pixel markers');
    end
    best = cands(1, 1);
    nx = ctx.nx; ny = ctx.ny; nC = ctx.nC; nbins = ctx.nbins;
    pixels = nx * ny;
    nFrames = floor(cands(1, 2) / pixels);
    maxMarker = nFrames * pixels;
    tailPixels = opt.TailPixels;

    tm = ctx.mkT(double(ctx.mkMask) == best);
    dtPix = median(diff(tm));
    if isempty(dtPix) || ~isfinite(dtPix) || dtPix <= 0
        dtPix = NaN; tailPixels = Inf;
    end
    say(ctx, '   pixel mode: marker %d, %d frame(s), pixel time %.1f sync counts\n', ...
        best, nFrames, dtPix);

    fid = fopen(ctx.file, 'r', 'ieee-le');
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fseek(fid, ctx.dataOffset, 'bof');

    out = zeros(ny * nx * nC * nbins, 1, 'single');
    markerCount = 0; ovfTotal = 0; lastMarkT = NaN; trimmed = 0;
    left = ctx.nRec;
    while left > 0
        rec = fread(fid, min(ctx.CHUNK, left), 'uint32=>uint32');
        if isempty(rec), break; end
        left = left - numel(rec);
        d = decodeChunk(rec, ctx.fmt);

        isMark = d.isMk & (d.mask == best);
        cnt = markerCount + cumsum(double(isMark));      % markers seen so far
        markerCount = cnt(end);

        m = d.isPh & ctx.chMap(d.chan + 1) > 0 & d.dt < nbins ...
            & cnt >= 1 & cnt <= maxMarker;

        if isfinite(tailPixels)
            [t, ovfTotal] = syncTimes(d, ovfTotal, ctx.fmt);
            mt = nan(size(t)); mt(isMark) = t(isMark);
            if isnan(mt(1)), mt(1) = lastMarkT; end
            mt = fillmissing(mt, 'previous');            % time of latest marker
            lastMarkT = mt(end);
            inLast = mod(cnt - 1, nx) == nx - 1;         % last pixel of each line
            drop = m & inLast & ((t - mt) > tailPixels * dtPix);
            trimmed = trimmed + nnz(drop);
            m = m & ~drop;
        end
        if ~any(m), continue; end

        pix = mod(cnt(m) - 1, pixels);                   % frames summed
        y = floor(pix / nx); x = mod(pix, nx);
        c = ctx.chMap(d.chan(m) + 1) - 1;
        lin = 1 + y(:) + ny * x(:) + ny * nx * c(:) + ny * nx * nC * d.dt(m);
        out = addCounts(out, lin);
    end

    total = double(sum(out, 'all'));
    if total <= 1000
        error('only %d photons reconstructed', total);
    end
    vol = reshape(out, [1 ny nx nC nbins]);
    info = struct('photons', total, 'frames', nFrames, 'nx', nx, 'ny', ny, ...
        'nbins', nbins, 'detectorChannels', ctx.photCh, 'pixelMarker', best, ...
        'pixelTimeSync', dtPix, 'tailTrimmed', trimmed);
end

%% ========================================================================
%  Strategy B: line / frame markers, pixel columns from timing
%  (port of ptu2flim.m)
%% ========================================================================
function [vol, info] = runLine(ctx, opt) %#ok<INUSD>
    nx = ctx.nx; ny = ctx.ny; nC = ctx.nC; nbins = ctx.nbins;
    if isnan(ctx.maskLineStart)
        error('header has no ImgHdr_LineStart marker definition');
    end

    t_lstart = unique(ctx.mkT(double(ctx.mkMask) == ctx.maskLineStart));
    if numel(t_lstart) < 2, error('fewer than 2 line-start markers'); end
    t_lstop = zeros(0, 1);
    if ~isnan(ctx.maskLineStop)
        t_lstop = unique(ctx.mkT(double(ctx.mkMask) == ctx.maskLineStop));
    end
    t_frame = zeros(0, 1);
    if ~isnan(ctx.maskFrame)
        t_frame = unique(ctx.mkT(double(ctx.mkMask) == ctx.maskFrame));
    end
    if isempty(t_frame)
        t_frame = t_lstart(1);
        ensenya('Warning: no frame markers found,','a',2);
        ensenya('         treating the acquisition as one frame.','a',2);
    end
    nFrames = numel(t_frame);

    % --- pixel dwell (integer sync counts) and line window ---
    median_period = median(diff(t_lstart));
    pixel_dwell = round(median_period / nx);
    t_line = pixel_dwell * nx;
    t_line_exact = median_period;
    usedStop = false;
    if ~isempty(t_lstop)
        % pair every line start with the first line stop after it
        j = discretize(t_lstart, [t_lstop; Inf]); j(isnan(j)) = 0;
        nxt = j + 1;
        hasStop = nxt <= numel(t_lstop);
        dur = nan(size(t_lstart));
        dur(hasStop) = t_lstop(nxt(hasStop)) - t_lstart(hasStop);
        valid_dur = dur > 0 & dur < median_period;
        if sum(valid_dur) > numel(t_lstart) * 0.5
            t_line_exact = median(dur(valid_dur));
            t_line = round(t_line_exact);
            pixel_dwell = round(t_line / nx);
            usedStop = true;
        end
    end
    if pixel_dwell < 1, error('pixel dwell < 1 sync count'); end
    fine = strcmp(ctx.lineTiming, 'fine');
    dwellF = t_line_exact / nx;                          % exact (non-integer) dwell
    periodBins = max(1, round((ctx.maxDt + 1) / nbins)) * nbins;   % bins per sync period
    say(ctx, ['   line mode: %d lines, %d frame marker(s), line period %.1f, ' ...
        'active window %.1f (%.1f%%, line-stop used: %d), dwell %.2f sync counts, timing: %s\n'], ...
        numel(t_lstart), nFrames, median_period, t_line_exact, ...
        100 * t_line_exact / median_period, usedStop, dwellF, ctx.lineTiming);

    t_begin = t_lstart(:);
    t_end   = t_begin + t_line;

    % --- frame of each line (auto-detect start-/end-of-frame convention) ---
    tf = sort(t_frame(:));
    fol = countLE(tf, t_begin);                 % frame markers at or before the line
    if sum(fol == 0) / numel(fol) > 0.8
        fol = countLE(tf, t_begin - 1) + 1;     % end-of-frame convention
        fol = min(fol, nFrames);
        say(ctx, '   end-of-frame marker convention detected\n');
    end
    n = numel(fol);
    g = [true; diff(fol) ~= 0];
    startIdx = cummax(g .* (1:n)');
    lif = (1:n)' - startIdx + 1;                % line index inside its frame
    lif(fol == 0) = 0;                          % lines before first frame: dropped
    say(ctx, '   total lines %d (expected %d)\n', n, ny * nFrames);

    % --- pass 2: assign photons ---
    fid = fopen(ctx.file, 'r', 'ieee-le');
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fseek(fid, ctx.dataOffset, 'bof');

    out = zeros(ny * nx * nC * nbins, 1, 'single');
    ovfTotal = 0; kept = 0; seen = 0;
    left = ctx.nRec;
    while left > 0
        rec = fread(fid, min(ctx.CHUNK, left), 'uint32=>uint32');
        if isempty(rec), break; end
        left = left - numel(rec);
        d = decodeChunk(rec, ctx.fmt);
        [t, ovfTotal] = syncTimes(d, ovfTotal, ctx.fmt);

        ph = d.isPh & ctx.chMap(d.chan + 1) > 0;
        seen = seen + nnz(ph);
        tp = t(ph); chp = d.chan(ph); dtraw = d.dt(ph);
        dtp = mod(dtraw, nbins);                % fold sync divider

        k = discretize(tp, [t_begin; Inf]);     % line whose start precedes photon
        ok = ~isnan(k);
        k(~ok) = 1;
        ok = ok & (tp <= t_end(k));             % inside the line window
        y = lif(k);
        ok = ok & y >= 1 & y <= ny;
        if ~any(ok), continue; end

        k = k(ok); y = y(ok); tp = tp(ok); chp = chp(ok); dtp = dtp(ok); dtraw = dtraw(ok);
        if fine
            % sub-sync timing: macro time + TCSPC bin / bins per sync period
            tf = (tp - t_begin(k)) + dtraw / periodBins;
            x = min(floor(tf / dwellF), nx - 1);
        else
            x = min(floor((tp - t_begin(k)) / pixel_dwell), nx - 1);
        end
        if ctx.bidirect
            flip = mod(y, 2) == 1;              % same convention as ptu2flim.m
            x(flip) = nx - 1 - x(flip);
        end
        c = ctx.chMap(chp + 1) - 1;
        lin = 1 + (y(:) - 1) + ny * x(:) + ny * nx * c(:) + ny * nx * nC * dtp(:);
        out = addCounts(out, lin);
        kept = kept + numel(lin);
    end

    total = double(sum(out, 'all'));
    if total <= 1000
        error('only %d photons assigned to lines', total);
    end
    say(ctx, '   assigned %d / %d photons (%.1f%%)\n', kept, seen, 100 * kept / max(seen, 1));
    vol = reshape(out, [1 ny nx nC nbins]);
    info = struct('photons', total, 'frames', nFrames, 'nx', nx, 'ny', ny, ...
        'nbins', nbins, 'detectorChannels', ctx.photCh, 'lines', n, ...
        'linePeriodSync', median_period, 'pixelDwellSync', pixel_dwell, ...
        'bidirectional', ctx.bidirect, 'photonsSeen', seen, ...
        'usedLineStop', usedStop, 'dutyCycle', t_line_exact / median_period, ...
        'lineTiming', ctx.lineTiming);
end

%% ========================================================================
%  Shared helpers
%% ========================================================================
function out = addCounts(out, lin)
    [u, ~, j] = unique(lin);
    out(u) = out(u) + single(accumarray(j, 1));
end

function c = countLE(sortedEdges, x)
% number of sortedEdges elements <= x  (sortedEdges strictly increasing)
    b = discretize(x, [sortedEdges(:); Inf]);
    b(isnan(b)) = 0;
    c = b;
end

function say(ctx, varargin)
    if ctx.verbose, fprintf(varargin{:}); end
end

function f = recordFormat(rt)
    switch rt
        case hex2dec('00010303')
            f = struct('name', 'PicoHarp T3', 'kind', 'pico', 'wrap', 65536, 'v1', true);
        case hex2dec('00010304')
            f = struct('name', 'HydraHarp V1 T3', 'kind', 'hh', 'wrap', 1024, 'v1', true);
        case {hex2dec('01010304'), hex2dec('00010305'), hex2dec('00010306'), hex2dec('00010307')}
            f = struct('name', 'HydraHarp2/TimeHarp260/MultiHarp T3', 'kind', 'hh', ...
                       'wrap', 1024, 'v1', false);
        otherwise
            error('ptu_decode:rectype', ...
                'Record type 0x%08X is not a supported T3 format', rt);
    end
end

function d = decodeChunk(rec, fmt)
% Normalise a chunk of raw records: photon/marker/overflow flags, detector
% channel, TCSPC bin, marker value (bitmask) and 'nsync' field.
    if strcmp(fmt.kind, 'pico')
        d.ns   = double(bitand(rec, uint32(65535)));
        d.dt   = double(bitand(bitshift(rec, -16), uint32(4095)));
        d.chan = double(bitshift(rec, -28));
        sp = d.chan == 15;
        d.isOvf = sp & d.dt == 0;
        d.isMk  = sp & d.dt ~= 0;
        d.mask  = d.dt;                      % marker bitmask lives in dtime
    else
        d.ns   = double(bitand(rec, uint32(1023)));
        d.dt   = double(bitand(bitshift(rec, -10), uint32(32767)));
        d.chan = double(bitand(bitshift(rec, -25), uint32(63)));
        sp = bitshift(rec, -31) == 1;
        d.isOvf = sp & d.chan == 63;
        d.isMk  = sp & d.chan < 63;
        d.mask  = d.chan;                    % marker bitmask is the channel field
    end
    d.isPh = ~sp;
    inc = zeros(size(d.ns));
    if fmt.v1
        inc(d.isOvf) = 1;
    else
        k = d.ns(d.isOvf); k(k == 0) = 1;
        inc(d.isOvf) = k;
    end
    d.ovfInc = inc;
end

function [t, ovfTotal] = syncTimes(d, ovfTotal, fmt)
% overflow-corrected sync counter for every record
    cum = ovfTotal + cumsum(d.ovfInc);
    t = cum * fmt.wrap + d.ns;
    ovfTotal = cum(end);
end

function [tags, dataOffset] = readHeader(file)
    fid = fopen(file, 'r', 'ieee-le');
    if fid < 0, error('ptu_decode:open', 'Cannot open %s', file); end
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    magic = fread(fid, 8, 'uint8=>char')';
    if ~startsWith(magic, 'PQTTTR')
        error('ptu_decode:magic', 'Not a PicoQuant PTU file');
    end
    fseek(fid, 16, 'bof');
    tags = containers.Map('KeyType', 'char', 'ValueType', 'any');
    TY_FLOAT8 = [hex2dec('20000008') hex2dec('21000008')];     % float8, TDateTime
    TY_PAYLOAD = [hex2dec('4001FFFF') hex2dec('4002FFFF') ...  % ansi, wide string
                  hex2dec('FFFFFFFF') hex2dec('2001FFFF')];    % blob, float8 array
    while true
        ident = fread(fid, 32, 'uint8=>char')';
        if numel(ident) < 32
            error('ptu_decode:header', 'Unexpected end of header');
        end
        ident = ident(1:find([ident 0] == 0, 1) - 1);
        idx = fread(fid, 1, 'int32');
        typ = fread(fid, 1, 'uint32');
        raw = fread(fid, 1, 'int64=>int64');
        if any(typ == TY_FLOAT8)
            val = typecast(raw, 'double');
        elseif any(typ == TY_PAYLOAD)
            val = NaN;
            fseek(fid, double(raw), 'cof');    % skip length-prefixed payload
        else
            val = double(raw);
        end
        if idx < 0, key = ident; else, key = sprintf('%s[%d]', ident, idx); end
        tags(key) = val;
        if strcmp(ident, 'Header_End'), break; end
    end
    dataOffset = ftell(fid);
end

function v = getNum(tags, name, default)
    if isKey(tags, name), v = tags(name); else, v = default; end
    if isnan(v), v = default; end
end

function m = tagMask(tags, name)
% ImgHdr_* tags store the 1-based marker INPUT number; the record carries 2^(n-1)
    v = getNum(tags, name, NaN);
    if isnan(v) || v < 1 || v > 15, m = NaN; else, m = 2^(v - 1); end
end

function n = inferNbins(tags)
    n = [];
    sync = getNum(tags, 'TTResult_SyncRate', NaN);
    res  = getNum(tags, 'MeasDesc_Resolution', NaN);
    if ~isnan(sync) && ~isnan(res) && sync > 0 && res > 0
        k = round((1 / sync) / res);
        if k >= 2 && k <= 65536, n = k; end
    end
    if isempty(n)
        for key = {'TTResult_NumberOfBins', 'HistResDscr_HistogramBins', 'MeasDesc_Bins'}
            k = getNum(tags, key{1}, NaN);
            if ~isnan(k) && k >= 2 && k <= 65536, n = k; return; end
        end
        n = 805;
    end
end