function [ITT,SST,GGT] = readFALCONsng(folder)


files=dir([folder filesep '*_ch*.tif']);

aux3=mod(numel(files),3);% when multiple of 3 int,s,g
aux4=mod(numel(files),4);% when multiple of 4 int,X,s,g
step=3;
if(aux4==0)&&(aux3~=0),step=4;end
%  for ii=1:numel(files)
%     aux = double(imread([folder filesep files(ii).name]));
%     q=max(aux(:));%quantile(aux(:),[0 .001 .1 .25 .5 .75 .9 .999 1]);
% disp([niceDigits(ii) ' quantiles: ' num2str(q)]);
%  end
if(aux4==0)&&(aux3==0)% ambiguity, gotta decide based on content
    maxs=zeros(4,1);
    for ii=1:4% open first 4
        aux = double(imread([folder filesep files(ii).name]));
        maxs(ii)=max(aux(:));
        % ensenya(num2str(maxs(ii)));
    end
    % G and S should be in the 16bit range
    aux=round(NormArray2(maxs));
    % [0 1 1 0] is 3, [0 0 1 1] is 4
    if(aux(end)==0),step=3;else step=4;end

end
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