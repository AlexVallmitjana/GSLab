function [Data, varargout] = lsmread(fileName, varargin)
%LSMREAD returns information and image data of a ZEISS lsm file.
% [Data] = lsmread(filename) will return image data in its original
% dimensions, organized as [T(ime), C(hannel), Z, X, Y]
% [Data] = lsmread(filename,'Range',[T0 T1 C0 C1 Z0 Z1]) will return image data with specified dimension. 
% [Data LSMinfo] = lsmread(filename) will return image data as well as LSMinfo
% [LSMinfo] = lsmread(filename,'InfoOnly') will only return LSM infos. 
%---------------------------------------------------------------------------------
% Notes for the Zeiss LSM format. 
% The first 8 bytes are TIFF file header. 
% Each 12-byte IFD entry has the following format: Bytes 0-1: The Tag that
% identifies the field. Byte 2-3: The field type. Bytes 4-7: Count. 
% Bytes 8-11: Value or offset.Byte count of the indicated types. 
% Types 1 = BYTE, 2 =ASCII (8-bit),3= SHORT (16-bit), 4= LONG(32-bit).  
% If the count is 1, then byes 8-11 stores the value, otherwise it's offset
% pointing to the position in file where value is stored. 
% Each optical section at every time point (no matter how many channels) 
% will have two image file directories(IFDs). The first one contains 
% information for the real image data. The second IFD contains 
% information for thumbnail images. The LSM file is structured as such : 
% header -> IFDs -> (real image/thumbnail)s. 
% The very first IFD has an entry numbered 34412 and points to LSM-specific data. 
%----------------------------------------------------------------------------------
% Version 1.7
% Copyright Chao-Yuan Yeh, 2016. 
% The script is inspired by LSM File Toolbox by Peter Li and tiffrd by Francois Nedelec.

fID = fopen(fileName);
byteOrder = fread(fID,2,'*char')';
if (strcmp(byteOrder,'II'))
    byteOrder = 'ieee-le';
elseif (strcmp(byteOrder,'MM'))
    byteOrder = 'ieee-be';
else
    error('This is not a correct TIFF file');
end

tiffID = fread(fID, 1, 'uint16', byteOrder);
if (tiffID ~= 42)
    error('This is not a correct TIFF file');
end

fseek(fID, 4, 'bof');
ifdPos = fread(fID, 1, 'uint32', byteOrder);
fseek(fID, ifdPos, 'bof');

IFDIdx = 0;
while ifdPos ~= 0 
      IFDIdx = IFDIdx+1;
      fseek(fID,ifdPos, 'bof');
      % The first two bytes of each IFD specify number of IFD entries.
      numEntries = fread(fID,1,'uint16',byteOrder);
      entryPos = ifdPos+2;  
      % Each IFD entry is 12-byte long.
      fseek(fID, ifdPos+12*numEntries+2, 'bof');  
      % The last four bytes of an IFD specifies offset to next IFD. 
      % If this is zero, it means there's no other IFDs. 
      ifdPos = fread(fID, 1, 'uint32', byteOrder); 
      % IFD is structured like this: bytes 1-2 : tag, bytes 3-4: type,
      % bytes 5-8: count, bytes 9-12: value/offset 
      for ii = 1:numEntries
          fseek(fID, entryPos+12*(ii-1), 'bof');
          IFD{IFDIdx}(1,ii) = fread(fID, 1, 'uint16', byteOrder);
          IFD{IFDIdx}(2,ii) = fread(fID, 1, 'uint16', byteOrder);
          IFD{IFDIdx}(3,ii) = fread(fID, 1, 'uint32', byteOrder);
          IFD{IFDIdx}(4,ii) = fread(fID, 1, 'uint32', byteOrder);
      end
end

%Reading LSMinfo
if IFD{1}(3, IFD{1}(1, :) == 258) == 1
        LSMinfo.bitDepth = IFD{1}(4, IFD{1}(1, :) == 258);
else
    fseek(fID, IFD{1}(4,IFD{1}(1, :) == 258),'bof');
    LSMinfo.bitDepth = fread(fID, 1, 'uint16', byteOrder);
end

offsetLSMinfo = IFD{1}(4,IFD{1}(1, :) == 34412)+8;
fseek(fID, offsetLSMinfo, 'bof');
LSMinfo.dimX = fread(fID, 1, 'uint32', byteOrder);
LSMinfo.dimY = fread(fID, 1, 'uint32', byteOrder);
LSMinfo.dimZ = fread(fID, 1, 'uint32', byteOrder);
LSMinfo.dimC = fread(fID, 1, 'uint32', byteOrder);
LSMinfo.dimT = fread(fID, 1, 'uint32', byteOrder);
fseek(fID, 12, 'cof');
LSMinfo.voxSizeX = fread(fID, 1, 'float64', byteOrder);
LSMinfo.voxSizeY = fread(fID, 1, 'float64', byteOrder);
LSMinfo.voxSizeZ = fread(fID, 1, 'float64', byteOrder);
fseek(fID, 26, 'cof');
LSMinfo.specScan = fread(fID, 1, 'uint16', byteOrder);

if any(strcmpi(varargin, 'InfoOnly'))
    Data = LSMinfo;
    fclose(fID);
else
    % Creating offset list for every IFD 
    offset = zeros(1, IFDIdx/2);
    for ii= 1 : IFDIdx/2
        if IFD{2*ii - 1}(3,7) == 1 && IFD{2 * ii - 1}(4, 7) < 4294967296
            offset(ii) = IFD{2 * ii - 1}(4, 7);
        else
            fseek(fID, IFD{2 * ii - 1}(4, 7), 'bof');
            offset(ii) = fread(fID, 1, 'uint32', byteOrder);
        end
    end

    if any(strcmpi(varargin, 'Range'))
        Range = varargin{find(strcmpi(varargin, 'Range')) + 1};
        if any([Range(1) < 1, Range(2) > LSMinfo.dimT, Range(3) < 1, ...
                Range(4) > LSMinfo.dimC, Range(5) < 1, ...
                Range(6)>LSMinfo.dimZ])
            error('Input range exceeds data range');
        else
            dimT0 = Range(1); 
            dimT1 = Range(2);
            dimC0 = Range(3); 
            dimC1 = Range(4);
            dimZ0 = Range(5); 
            dimZ1 = Range(6);
        end
    else
        dimT0 = 1; dimT1 = LSMinfo.dimT;
        dimZ0 = 1; dimZ1 = LSMinfo.dimZ;
        dimC0 = 1; dimC1 = LSMinfo.dimC;
    end
    
    bitDepth = strcat('uint',num2str(LSMinfo.bitDepth));
    Data = zeros(dimT1-dimT0+1, dimC1-dimC0+1, dimZ1-dimZ0+1, ...
        LSMinfo.dimY, LSMinfo.dimX, bitDepth);
    
    for indT = dimT0 : dimT1
        for indZ = dimZ0 : dimZ1
            fseek(fID, offset((indT-1) * LSMinfo.dimZ + indZ),'bof');
            switch bitDepth
                case 'uint16'
                    fseek(fID, (dimC0-1)*LSMinfo.dimX*LSMinfo.dimY*2, 'cof');
                    for indC = dimC0 : dimC1
                    Data(indT-dimT0+1, indC-dimC0+1, indZ-dimZ0+1, :, :) ...
                        = reshape(uint16(...
                        fread(fID, LSMinfo.dimX * LSMinfo.dimY, ...
                        bitDepth, byteOrder)), LSMinfo.dimX, LSMinfo.dimY)';
                    end
                case 'uint8'
                    fseek(fID, (dimC0-1)*LSMinfo.dimX*LSMinfo.dimY, 'cof');
                    for indC = dimC0 : dimC1
                    Data(indT-dimT0+1,indC-dimC0+1,indZ-dimZ0+1,:,:) ...
                        = reshape(uint8(...
                        fread(fID,LSMinfo.dimX*LSMinfo.dimY, ...
                        bitDepth, byteOrder)), LSMinfo.dimX, LSMinfo.dimY)';
                    end
            end
        end
    end

    fclose(fID);
    if nargout==2
        varargout{1} = LSMinfo;
    end
end
end

