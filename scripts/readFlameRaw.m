function [IT,dad] = readFlameRaw(path,verb,unj)
% returns array IT with dimensions being y,x,c,t,z
% set verb to 0 to prevent verbosity
% set unj to 0 to prevent applyting unjag
% path='C:\Users\austi\Synology Drive 2\01_Patient\0420_250130_HS6307_General_AV\Normal_ExVivo_LFA\ZMosaic01_4x4_FOV600_z65_zstep10_3Ch';
if(nargin<2),verb=1;end
if(nargin<3),unj=1;end
%% sanity checks
% tif files
aux=dir([path filesep '*.tif']);
if(isempty(aux)),error('No tif files!');end
% tif sizes
for ii=1:numel(aux)
    aux1=imfinfo([path filesep aux(ii).name]);
    if(ii>1)
        if(aux1(1).Height~=aux2(1))||(aux1(1).Width~=aux2(2))||(numel(aux1)~=aux2(3))
            error('Images have different sizes!')
        end
    end
    aux2=[aux1(1).Height aux1(1).Width numel(aux1)];
end
%%
txt=dir([path filesep '*Data.txt']);
if~isempty(txt)
    [dad] = readScanImageMeta([path filesep txt(1).name]);
else
    error('No metadata file!');
end
TT=numel(txt);
ZZ=numel(dad.tileZs);
CC=numel(dad.channelsSaved);
IT=[];
try,[IT] = fishTiffs(path,verb);catch me,ensenya(['Error in fishTiffs: ' me.message],'r');end

aux0=strfind(path,'_');
aux00=find(path==filesep);if(aux00(end)==numel(path)),aux00(end)=[];end
dad.configuration=path(aux0(end)+1:end);
dad.geometry=lower(path(aux00(end)+1:aux00(end)+3));
switch dad.geometry
    case 'ima',id=1;
    case 'mos',id=2;
    case 'sta',id=3;
    case 'zmo',id=4;
end
dad.geometryId=id;
ori=strfind(path,'_FOV');
aux3=strfind(path,'_z');
aux3=aux3(find(aux3>ori,1,'first'));
aux4=aux0(find(aux0>aux3,1,'first'));
dad.zZeroUm=str2num(path(aux3+2:aux4-1));
% size(IT)
if((id==2)||(id==4))
    [m,n,success] = getTileDims(path);
    if(success==1)
        dad.tileRows=m;
        dad.tileCols=n;
    else
        ensenya('Warning: Mosaic dimensions error','a');
    end
    try,dad=rmfield(dad,'tileCornerPtsUm');end% that field belongs only to the first tile
    if(TT~=size(IT,4))
        TT=size(IT,4);
        ensenya('Warning: Tile number inconsistency','a');
    end
end
if((id==3)||(id==4))
    if(ZZ~=size(IT,3)/CC)
        ZZ=size(IT,3)/CC;
        ensenya('Warning: Z/C number inconsistency','a');
    end
    IT2=zeros(size(IT,1),size(IT,2),CC,TT,ZZ);
    for zz=1:ZZ
        IT2(:,:,:,:,zz)=IT(:,:,(zz-1)*CC+1:(zz)*CC,:);
    end
    IT=IT2;clear IT2;
    aux1=strfind(path,'_zstep');
    aux2=aux0(find(aux0>aux1,1,'first'));

    dad.zStepUm=str2num(path(aux1+6:aux2-1));

else

end

%   size(IT)
%% ATENTION forcing to 32 bins when 30 or 31 by adding last
if(size(IT,3)==30)
    IT=cat(3,IT,IT(:,:,30,:,:));
end
if(size(IT,3)==31)
    IT=cat(3,IT,IT(:,:,31,:,:));
end
%% if 31nB we have just extended the B, we gotta add a tail for the 30 to become 31
if(strcmp(dad.configuration,'31nB'))
    IT(:,:,31,:,:)=IT(:,:,30,:,:);
end
%% if 32Sp match 16th to 15th
if(strcmp(dad.configuration,'32Sp'))
IT(:,:,16,:,:)=IT(:,:,15,:,:);
end
% disp(size(IT,3));
%%
fin=strfind(path,'_');
fin(fin<=ori)=[];
DX=str2num(path(ori+4:fin(1)-1))/dad.tileResolution(1);
dad.pixelSizeUm=DX;
dad.folderPath=path(1:aux00(end)-1);
dad.fileName=path(aux00(end)+1:end);
if(unj~=0)&&(isfield(dad, 'bidirectionalCorrection'))
    IT=unjag(IT,dad.bidirectionalCorrection);
end