function [ITT,SST,GGT,nms] = readFALCONsng(folder)


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
nms=cell(0);;
contagrups=0;
for ii=1:step:numel(files)

    [IT] = imread([folder filesep files(ii).name]);% intensity image
    [GG] = imread([folder filesep files(ii+step-2).name]);% G image
    [SS] = imread([folder filesep files(ii+step-1).name]);% S image



    if(size(IT,3)>1)||((size(SS,3)>1)||(size(GG,3)>1))
        ensenya('Images are not raw, likely data was exported wrong:','r');
        disp('     01. In the LAS X FLIM/FCS window, select the Intensity tab above the images.');
        disp('     02. Then in the FLIM tab on the left menu, at the bottom you have the Save Image button.');
        disp('     03. You click that and the Save Image window opens:');
        disp('     04. Select Tiff tab (if available).');
        disp('     05. Select checkbox Save Phasor GS.');
        disp('     06. Select the radio button Fixed Range.');
        disp('     07. Set the Factor or Range to per Grey Level and input 1 in the edit field box.');
        disp('     08. This will add an entry to your project file that has the G and S coordinate images.');
        disp('     09. Right click those image entries, select Export as... , select Tiff.');
        disp('     10. Set the destination folder and check the Save raw data option.');
        disp('     11. This will generate the coordinate images and intensity values.');

    end


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

    try
        nms{contagrups}=files(ii).name(1:findstr(files(ii).name,'_ch')-1);

    catch
        try
            n1={files(ii).name,files(ii+step-2).name,files(ii+step-1).name,files(ii).name};%repeat first to have all combinations when doing diff 1-2,2-3,3-1
            nms{contagrups}=files(ii).name(1:find(sum(abs(diff(char(n1),1)),1)~=0,1,'first'));
        end
    end
end

end