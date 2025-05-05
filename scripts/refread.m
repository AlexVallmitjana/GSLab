function [FLIMdata,FileNames,PathName]=refread(pathorstruc)
% Can be called without an argument to manually select the file(s).
% If called with a string it is interpreted as the absolute path to the
% folder where all ref/r64 need to be read.
% Can also be called with a struct of files obtained from dir([path /*.ref'])
%
% Outputs cell FLIMdata with each component being a stack of 5 images NxNx5
% where each of them are
%   1 - Intensity
%   2 - Harmonic 1 Phase (degrees)
%   3 - Harmonic 1 Modulation
%   4 - Harmonic 2 Phase (degrees)
%   5 - Harmonic 2 Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LFD crew %%%%%%%%%%%

if(nargin==0)
[FileNames,PathName] = uigetfile({'*.R64;*.ref;*.re1;*.re3;*.re4'},'MultiSelect','On');
else
    if(ischar(pathorstruc))
    PathName=pathorstruc;
    ext=PathName(end-2:end);
    if(strcmpi(ext,'r64'))||(strcmpi(ext(1:2),'re'))
    %if((strcmpi(PathName(end-2:end),'re4'))||(((strcmpi(PathName(end-2:end),'ref'))||(strcmpi(PathName(end-2:end),'r64')))||((strcmpi(PathName(end-2:end),'re1'))||(strcmpi(PathName(end-2:end),'re3')))))%its path to a file
       files=dir(PathName); 
       PathName=[files(1).folder filesep];
    else%path to a folder
    if((PathName(end)~='/')&&(PathName(end)~='\')),PathName(end+1)=filesep;end
    files=[dir([PathName '*.ref']);dir([PathName '*.R64']);dir([PathName '*.re1']);dir([PathName '*.re3']);dir([PathName '*.re4']);dir([PathName '*.re5']);dir([PathName '*.re6']);dir([PathName '*.re7']);dir([PathName '*.re8'])];
    end
    else
        if(isstruct(pathorstruc))
        PathName=pathorstruc(1).folder;
        if((PathName(end)~='/')&&(PathName(end)~='\')),PathName(end+1)=filesep;end
        files=pathorstruc;
        else
           error('****************** Cant interpret input argument'); 
        end
    end
    cc=0;
    for ii=1:length(files)
        if(files(ii).isdir==0)
            cc=cc+1;
       FileNames{cc}=files(ii).name;
        end
    end
end
if((exist('FileNames','var')==0)||(isempty(FileNames))),error('****************** No .ref or .R64 files.');end
% read binary file
if ischar(FileNames)
    tmp=FileNames;
    FileNames=cell(1);
    FileNames{1}=tmp;
end
L=length(FileNames);
FLIMdata=cell(1,L);

for ii=1:L
    type=0;
    fileID = fopen([PathName FileNames{ii}]);
    if(strcmpi(FileNames{ii}(end-2:end),'ref')),input = fread(fileID,inf,'single');type=1;end
    if(strcmpi(FileNames{ii}(end-2:end),'re1')),input = fread(fileID,inf,'single');type=1.1;end
    if(strcmpi(FileNames{ii}(end-2:end),'re3')),input = fread(fileID,inf,'single');type=1.3;end
    if(strcmpi(FileNames{ii}(end-2:end),'re4')),input = fread(fileID,inf,'single');type=1.4;end	
    if(strcmpi(FileNames{ii}(end-2:end),'re5')),input = fread(fileID,inf,'single');type=1.5;end	
    if(strcmpi(FileNames{ii}(end-2:end),'re6')),input = fread(fileID,inf,'single');type=1.6;end	
    if(strcmpi(FileNames{ii}(end-2:end),'re7')),input = fread(fileID,inf,'single');type=1.7;end	
    if(strcmpi(FileNames{ii}(end-2:end),'re8')),input = fread(fileID,inf,'single');type=1.8;end	
    if(strcmpi(FileNames{ii}(end-2:end),'r64')),input = fread(fileID);type=2;end
    fclose(fileID);
    if(type==1)% Enrico refs
        sizes=sqrt(length(input)/5);
        images = reshape(input,sizes,sizes,5);
        FLIMdata{ii}=double(images);
    end
    if(type==1.1)% new cut refs
        sizes=sqrt(length(input)/3);
        images = reshape(input,sizes,sizes,3);
        images=cat(3,images,zeros(size(images,1),size(images,1),2));% case of single harmonic we add zeros 
        FLIMdata{ii}=double(images);
    end 
    if(type==1.3)% 3harmonic refs
        sizes=sqrt(length(input)/7);
        images = reshape(input,sizes,sizes,7);
        FLIMdata{ii}=double(images);
    end
    if(type==1.4)% 4harmonic refs
        sizes=sqrt(length(input)/9);
        images = reshape(input,sizes,sizes,9);
        FLIMdata{ii}=double(images);
    end	
    if(type==1.5)% 5harmonic refs
        sizes=sqrt(length(input)/11);
        images = reshape(input,sizes,sizes,11);
        FLIMdata{ii}=double(images);
    end	
    if(type==1.6)% 6harmonic refs
        sizes=sqrt(length(input)/13);
        images = reshape(input,sizes,sizes,13);
        FLIMdata{ii}=double(images);
    end	
    if(type==1.7)% 7harmonic refs
        sizes=sqrt(length(input)/15);
        images = reshape(input,sizes,sizes,15);
        FLIMdata{ii}=double(images);
    end	
    if(type==1.8)% 8harmonic refs
        sizes=sqrt(length(input)/17);
        images = reshape(input,sizes,sizes,17);
        FLIMdata{ii}=double(images);
    end	    
    if(type==2) % R64 
        % decompress file content
        buffer = java.io.ByteArrayOutputStream();
        zlib = java.util.zip.InflaterOutputStream(buffer);
        zlib.write(input, 0, numel(input));
        zlib.close();
        buffer = buffer.toByteArray();
        % read image dimension, number of images, and image data from
        % decompressed buffer
        nimages = 5;
        img=typecast(buffer(5:end), 'single');
        sizes=sqrt(length(img)/nimages);
        images = reshape(img, sizes, sizes, nimages);
        FLIMdata{ii}=double(images);
    end
end

end
