function [I1,I2,IC] = phasorRainbowIm(S,G,I,sz,fov,centre,crop,cmapcode,type)
% [I1,I2,IC] = phasorRainbowIm(S,G,I,sz,fov,centre,fla,crop,cmapcode,fast,type,fnum)
%
% sz is the phasor resolution [Spix Gpix]
% fov is the field of view in [Gmin Gmax;Smin Smax];
% centre specifies the center of the rainbow
% crop is a two element array for start and end of colored portion,
% rest is assigned to white (default to [0 1])
% cmapcode is a colormap code for superjet
% fast and fnum are retained for compatibility (not used)
% type is rainbow distribution (1 for angular, 2 for radial, 3 for linear)
%
% colorblind friendly colormap codes:
% cmapcode='vTy';% viridis
% cmapcode='bvay';% plasma
% cmapcode='kvayw';% inferno
% cmapcode='kvsC';% magma
% cmapcode='S7y';% cividis

if(nargin<9),type=1;end
if(nargin<8)||(isempty(cmapcode)),cmapcode='wvbclyorpw';end
if(nargin<7)||(isempty(crop)),crop=[0,1];end


if((size(S,1)~=size(I,1))||(size(S,2)~=size(I,2))|| ...
   (size(G,1)~=size(I,1))||(size(G,2)~=size(I,2)))
    error('S, G and I should have same sizes!');
end

valid = ~isnan(G);Gm = G(valid);Sm = S(valid);

if(nargin<6)||isempty(centre)
    centre=[mean(Gm(:)) mean(Sm(:))];
end

if(nargin<5)||(isempty(fov))
    fac=3;
    fov=[mean(Gm(:))-fac*std(Gm(:)),mean(Gm(:))+fac*std(Gm(:)); ...
         mean(Sm(:))-fac*std(Sm(:)),mean(Sm(:))+fac*std(Sm(:))];
end

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

[x,y]=meshgrid(linspace(fov(1,1),fov(1,2),sz(2)), ...
               linspace(fov(2,2),fov(2,1),sz(1)));
x=centre(1)-x;
y=centre(2)-y;

circ=superjet(1000,cmapcode);

if(type==1)

    if(crop(1)>=0)&&(crop(2)<=1)
        ttl=round(size(circ,1)/diff(crop));
        aux=ones(ttl,3);
        aux(:,1)=circ(1,1);aux(:,2)=circ(1,2);aux(:,3)=circ(1,3);% assumes first and last are the same
        aux(round(ttl*crop(1))+1:round(ttl*crop(1))+size(circ,1),:)=circ;
        circ=aux;
    else
        if(crop(1)<=0)
            ttl=round(size(circ,1)/diff(crop));
            aux=ones(ttl*2,3);
            aux(round(ttl*(1+crop(1))):round(ttl*(1+crop(1)))+size(circ,1)-1,:)=circ;
            circ=min(aux(1:end/2,:),aux(1+end/2:end,:));
        else
            ttl=round(size(circ,1)/diff(crop));
            aux=ones(ttl*2,3);
            aux(round(ttl*(crop(1))):round(ttl*(crop(1)))+size(circ,1)-1,:)=circ;
            circ=min(aux(1:floor(size(aux,1)/2),:),aux(1+ceil(size(aux,1)/2):end,:));
        end
    end

    % Generate IC
    angs=atan2(y,x);
    angs=round(((angs+pi)/(2*pi))*(size(circ,1)-1))+1;

    modu=sqrt(x.*x+y.*y);
    FRAC=max(max(modu));
    modu=1-modu/FRAC;
    modu=modu.*modu.*modu.*modu;
    modu(modu>1)=1;

    IC=reshape(max(circ(angs(:),:),modu(:)),[sz(1),sz(2),3]);

    % Generate image color map
    SS=centre(2)-S;
    GG=centre(1)-G;

    angs=atan2(SS,GG);
    angs=round(((angs+pi)/(2*pi))*(size(circ,1)-1))+1;

    modu=sqrt(GG.*GG+SS.*SS);
    modu=1-modu/FRAC;
    modu(modu<0)=0;
    modu(modu>1)=1;
    modu=modu.*modu.*modu.*modu;

    % Preserve zero values for pixels containing NaNs
    aux=zeros(numel(I),3);
    valid=~isnan(angs)&~isnan(modu);
    aux(valid(:),:)=max(circ(angs(valid),:),modu(valid));
    imcol=reshape(aux,[size(I,1),size(I,2),3]);

end

if(type==2)

    mods=sqrt(x.*x+y.*y);
    mods=(mods-crop(1))/(diff(crop))*size(circ,1);
    mods=round(mods);
    mods(mods>size(circ,1))=size(circ,1);
    mods(mods<1)=1;

    IC=reshape(circ(mods(:),:),[sz(1),sz(2),3]);

    S=centre(2)-S;
    G=centre(1)-G;

    MOD=sqrt(S.*S+G.*G);
    MOD=(MOD-crop(1))/(diff(crop))*size(circ,1);
    MOD=round(MOD);
    MOD(MOD>size(circ,1))=size(circ,1);
    MOD(MOD<1)=1;

    % Preserve zero values for pixels containing NaNs
    aux=zeros(numel(I),3);
    valid=~isnan(MOD);
    aux(valid(:),:)=circ(MOD(valid),:);
    imcol=reshape(aux,[size(I,1),size(I,2),3]);

end

if(type==3)

end

I1=imcol;
I2=uint8(I.*imcol*256);

end
