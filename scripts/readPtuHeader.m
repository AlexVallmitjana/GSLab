function hdr = readPtuHeader(filename)

fid = fopen(filename,'r','ieee-le');

if fid==-1
    error('Cannot find file.');
end

cleanup = onCleanup(@() fclose(fid));

% Magic
magic = fread(fid,8,'*char')';
hdr.Magic = strtrim(magic);

% Version
version = fread(fid,8,'*char')';
hdr.Version = strtrim(version);

hdr.Tags = struct();

while true

    % Tag identifier (32 bytes)
    tagIdent = fread(fid,32,'*char')';
    tagIdent = deblank(tagIdent(tagIdent~=0));

    % Tag index
    tagIdx = fread(fid,1,'int32');

    % Tag type
    tagType = fread(fid,1,'uint32');

    % End marker
    if strcmp(tagIdent,'Header_End')
        fread(fid,1,'int64'); % consume value
        break
    end

    % Construct field name
    if tagIdx >= 0
        fieldName = sprintf('%s_%d',tagIdent,tagIdx);
    else
        fieldName = tagIdent;
    end

    fieldName = matlab.lang.makeValidName(fieldName);

    switch tagType

        % Empty8
        case hex2dec('FFFF0008')
            fread(fid,1,'int64');
            value = [];

        % Bool8
        case hex2dec('00000008')
            value = logical(fread(fid,1,'int64'));

        % Int8
        case hex2dec('10000008')
            value = fread(fid,1,'int64');

        % BitSet64
        case hex2dec('11000008')
            value = fread(fid,1,'uint64');

        % Color8
        case hex2dec('12000008')
            value = fread(fid,1,'uint64');

        % Float8
        case hex2dec('20000008')
            value = fread(fid,1,'double');

        % TDateTime
        case hex2dec('21000008')
            value = fread(fid,1,'double');

        % Float8Array
        case hex2dec('2001FFFF')

            nBytes = fread(fid,1,'int64');

            pos = ftell(fid);

            value = struct( ...
                'Offset', pos, ...
                'Bytes', nBytes );

            fseek(fid,nBytes,'cof');

        % ANSI String
        case hex2dec('4001FFFF')

            nBytes = fread(fid,1,'int64');

            if nBytes>0
                value = fread(fid,nBytes,'*char')';
                value = value(value~=0);
            else
                value = '';
            end

        % Wide String
        case hex2dec('4002FFFF')

            nBytes = fread(fid,1,'int64');

            raw = fread(fid,nBytes/2,'uint16');

            value = native2unicode(raw','UTF-16LE');

        % Binary blob
        case hex2dec('FFFFFFFF')

            nBytes = fread(fid,1,'int64');

            pos = ftell(fid);

            value = struct( ...
                'Offset', pos, ...
                'Bytes', nBytes );

            fseek(fid,nBytes,'cof');

        otherwise

            raw = fread(fid,1,'int64');

            value = struct( ...
                'UnknownType', tagType, ...
                'RawValue', raw );

    end

    hdr.Tags.(fieldName) = value;

end

hdr.DataOffset = ftell(fid);

end