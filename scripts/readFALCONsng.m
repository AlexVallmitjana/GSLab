function [ITT,SST,GGT] = readFALCONsng(folder)


files=dir([folder filesep '*_ch*.tif']);

aux3=mod(numel(files),3);% when 3 int,s,g
aux4=mod(numel(files),4);% when 4 int,X,s,g
step=3;
if(aux4==0)&&(aux3~=0),step=4;end
ITT=[];SST=[];GGT=[];% incase no files
contagrups=0;
for ii=1:step:numel(files)

    [IT] = imread([folder filesep files(ii).name]);% intensity image
    [GG] = imread([folder filesep files(ii+step-2).name]);% G image
    [SS] = imread([folder filesep files(ii+step-1).name]);% S image
GG=double(GG);SS=double(SS);
    SS=SS-2^15;SS=SS/2^15;
    GG=GG-2^15;GG=GG/2^15;

% unsure how leica deals with zeros
SS(IT==0)=NaN;
GG(IT==0)=NaN;

    if(ii==1)
        ITT=zeros(size(IT,1),size(IT,2),numel(files)/step);
        SST=zeros(size(IT,1),size(IT,2),numel(files)/step);
        GGT=zeros(size(IT,1),size(IT,2),numel(files)/step);
    end

    contagrups=contagrups+1;
    ITT(:,:,contagrups)=IT;
    SST(:,:,contagrups)=SS;
    GGT(:,:,contagrups)=GG;
end

end