function [panel,PP,I1,I2,IC] = phasorRainbowIm(S,G,I,sz,fov,centre,fla,crop,cmapcode,fast,type,fnum)
% [panel,PP,I1,I2] = phasorRainbowIm(S,G,I,sz,fov,centre,fla,crop,cmapcode,fast)
%
% sz is the phasor resolution [Spix Gpix]
% fov is the field of view in [Gmin Gmax;Smin Smax];
% centre specifies the center of the rainbow
% fla is 0 for no lines, 1 for lifetime, 2 for spectral
% crop is a two element array for start and end of colored portion, rest is assigned to white (defatult to [0 1])
% cmapcode is a colormap code for superjet (start and end with 'w' to smooth against background)
% test code at the end of file
% fast is to exclude the drawing of the phasor plot, panel will come out empty
% type is rainbow distribution (1 for angular, 2 for radial, 3 for linear)
% fnum is the figure number where to plot the phasor plot (only for fast=0)
% colorblind friendly colormap codes:
% cmapcode='vTy';% viridis
% cmapcode='bvay';% plasma
% cmapcode='kvayw';% inferno
% cmapcode='kvsC';% magma
% cmapcode='S7y';% cividis

if(nargin<12),fnum=444;end
if(nargin<11),type=1;end
if(nargin<10),fast=0;end
if(nargin<9)||(isempty(cmapcode)),cmapcode='wvbclyorpw';end
if(nargin<8)||(isempty(crop)),crop=[0,1];end
if(nargin<7)||(isempty(fla)),fla=0;end

if((size(S,1)~=size(I,1))||(size(S,2)~=size(I,2))),error('S,G and I should have same sizes!');end
% centre=[.5 .25];%g,s
Gm=G;Sm=S;
Gm(isnan(G))=[];Sm(isnan(S))=[];
if(nargin<6)||isempty(centre)
    centre=[mean(Gm(:)) mean(Sm(:))];
end
if(nargin<5)||(isempty(fov))
    fac=3;
    fov=[mean(Gm(:))-fac*std(Gm(:)),mean(Gm(:))+fac*std(Gm(:));mean(Sm(:))-fac*std(Sm(:)),mean(Sm(:))+fac*std(Sm(:))];
end
%  or=-1;fi=1;
if(nargin<4)||(isempty(sz)),sz=256;end
if(numel(sz)==1)
    aux=diff(fov,1,2);
    if(aux(1)>aux(2))
        sz=[sz round(sz*aux(1)/aux(2))];
    else
        sz=[round(sz*aux(2)/aux(1)) sz];
    end
end
sz=round(sz);
[x,y]=meshgrid(linspace(fov(1,1),fov(1,2),sz(2)),linspace(fov(2,2),fov(2,1),sz(1)));
x=centre(1)-x;
y=centre(2)-y;

% if(nargin<9)||(isempty(cmapcode))
% circ=superjet(3000,cmapcode);
% circ=circ(1000:2048,:);
% else
circ=superjet(1000,cmapcode);
% end

% aux=round(off*500)+380:round(off*500)+879;
% if(aux(1)<1),aux=aux+500;end
% if(aux(end)>1000),aux=aux-500;end
% circ=circ(aux,:);

% circ=[circ(381:end,:);circ(1:380,:)];%start yellow
% if(nargin<11),circ=[circ(121:end,:);circ(1:120,:)];end%start blue
if(type==1)
    if(crop(1)>=0)&&(crop(2)<=1)
        ttl=round(size(circ,1)/diff(crop));
        aux=ones(ttl,3);
        aux(round(ttl*crop(1))+1:round(ttl*crop(1))+size(circ,1),:)=circ;
        circ=aux;
    else
        if(crop(1)<0)
            ttl=round(size(circ,1)/diff(crop));
            aux=ones(ttl*2,3);
            aux(round(ttl*(1+crop(1))):round(ttl*(1+crop(1)))+size(circ,1)-1,:)=circ;
            circ=min(aux(1:end/2,:),aux(1+end/2:end,:));
        else
            ttl=round(size(circ,1)/diff(crop));
            aux=ones(ttl*2,3);
            aux(round(ttl*(crop(1))):round(ttl*(crop(1)))+size(circ,1)-1,:)=circ;
            circ=min(aux(1:end/2,:),aux(1+end/2:end,:));
        end
    end
    %
    % if(smo>0) % sha dimplementar encara
    %    aux=circ;
    % aux=[smooth(aux(:,1),round(size(aux,1)*smo)),smooth(aux(:,2),round(size(aux,1)*smo)),smooth(aux(:,3),round(size(aux,1)*smo))];
    % aux=NormArray(aux);
    % %             figure,seeColormap([aux]);
    % %   figure,plot(aux0(:,1));hold on;plot(aux(:,1));
    % end


    %             figure,seeColormap([circ]);
    IC=zeros(sz(1),sz(2),3);
    angs=atan2(y,x);
    angs=angs+3.141692;
    angs=angs/6.2834;

    angs=round((angs)*(size(circ,1)-1))+1;
    mod=sqrt(x.*x+y.*y);
    % mod=1-mod./sqrt(2);
    FRAC=max(max(mod));
    mod=1-mod/FRAC;
    mod=mod.*mod.*mod.*mod;
    mod(mod>1)=1;
    %                  mod=mod*.5
    %                  angs=angs(end:-1:1,:);
    for c1=1:sz(1)
        for c2=1:sz(2)
            for cc=1:3
                IC(c1,c2,cc)=max(circ(angs(c1,c2),cc),mod(c1,c2));
            end
        end
    end
    IC(IC>1)=1;
end
if(type==2)
    mods=sqrt(x.*x+y.*y);
    mods=(mods-crop(1))/(diff(crop))*size(circ,1);
    mods=round(mods);
    mods(mods>size(circ,1))=size(circ,1);
    mods(mods<1)=1;

    IC=ones(sz(1),sz(2),3);
    for c1=1:sz(1)
        for c2=1:sz(2)
            for cc=1:3
                IC(c1,c2,cc)=circ(mods(c1,c2),cc);
            end
        end
    end
end
if(type==3)


end
if(fast==0)
    figure(fnum);clf;imagesc(IC)
    [PP,~,~,~]=phasorPlot2(S(:),G(:),sz,0,fov);
    phasorImage(IC,fov,[],[],[],fla);%(PT,FOV,cm,sty,levs,flag)
    [xc,yc]=meshgrid(linspace(fov(1,1),fov(1,2),sz(2)),linspace(fov(2,2),fov(2,1),sz(1)));
    PP=NormArray(imgaussfilt(PP,4));
    aux=NormArray(PP);
    if(numel(find(isnan(aux)))<numel(aux))
        if(max(aux(:))>0)
            [~,h]=contour(xc,yc,aux,[.01 .05 .1 .3 .5 .9]);
        end
    end
    colormap(zeros(10,3));
    [gg,~]=getframe(gcf);

else

    gg=zeros(size(I,1),size(I,2),3);

end
PP=gg;

if(type==1)
    SS=centre(2)-S;
    GG=centre(1)-G;
    angs=atan2(SS,GG);
    angs=angs+3.141692;
    angs=round((angs/6.2834)*(size(circ,1)-1))+1;
    mod=sqrt(GG.*GG+SS.*SS);
    % mod=1-mod./sqrt(2);
    mod=1-mod/FRAC;
    mod(mod<0)=0;mod(mod>1)=1;
    mod=mod.*mod.*mod.*mod;
    imcol=zeros(size(I,1),size(I,2),3);
    for c1=1:size(imcol,1)
        for c2=1:size(imcol,2)
            if(~isnan(angs(c1,c2)))
                if(~isnan(mod(c1,c2)))
                    for cc=1:3
                        imcol(c1,c2,cc)=max(circ(angs(c1,c2),cc),mod(c1,c2));
                        %                     imcol(c1,c2,cc)=circ(angs(c1,c2),cc);
                    end
                end
            end
        end
    end
end
if(type==2)
    S=centre(2)-S;
    G=centre(1)-G;
    MOD=sqrt(S.*S+G.*G);
    MOD=(MOD-crop(1))/(diff(crop))*size(circ,1);
    MOD=round(MOD);
    MOD(MOD>size(circ,1))=size(circ,1);
    MOD(MOD<1)=1;
    imcol=zeros(size(I,1),size(I,2),3);
    for c1=1:size(imcol,1)
        for c2=1:size(imcol,2)
            if(~isnan(MOD(c1,c2)))
                for cc=1:3
                    imcol(c1,c2,cc)=circ(MOD(c1,c2),cc);
                end
            end
        end
    end
end


I1=imcol;
aux=I(:,:,1);I=I/quantile(aux(:),.999);I(I>1)=1;
gg2=uint8(I.*imcol*256);I2=gg2;
gg2=imresize(gg2,[size(gg,1) round(size(imcol,2)*size(gg,1)/size(imcol,1))]);
%gg2=uint8(gg2*256);

gg1=imresize(imcol,[size(gg,1) round(size(imcol,2)*size(gg,1)/size(imcol,1))]);
gg1=uint8(gg1*256);
aux=mean(sum(gg,3),1);
aux=find(aux<764);aux=[aux(1) aux(end)];aux(1)=round(aux(1)/2);aux(2)=aux(2)+round((size(gg,2)-aux(2))/2);
panel=cat(2,gg(:,aux(1):aux(2),:),gg1,gg2);

end




% F=refread('C:\Users\austi\Documents\1_Belen\Manuscript\OrganelleStaining\sincos\60xW940fov48p30_Cell2_NucB_mitoGr_ActinOr_40f000_SP.ref');
%
% ima=F{1}(:,:,1);
% Mo=F{1}(:,:,3);
% Ph=F{1}(:,:,2);
%
% S0=Mo.*sin(Ph*3.1416/180);
% G0=Mo.*cos(Ph*3.1416/180);
% [Sf,Gf] = phasorSmooth(S0,G0,3,2);
%
%
% [panel,PP,I1,I2,IC] = phasorRainbowIm(Sf,Gf,ima,512,[-1 1;-1 1],[.5 .5],2,[.5 .75],'wrgbw');
%
% figure(3);imagesc(panel);
%
