function [I3] = split23ch(IT0,rg)

chCut=[4];% Juvs settings,4th out of 31
%
if(size(IT0,4)>1)% assume 4th dim is time
    dimm=4;
else
    dimm=3;
end
NC=size(IT0,dimm);
if(dimm==3)
    AI1=IT0(:,:,1:floor(NC/2));
    AI0=IT0(:,:,floor(NC/2)+1:NC);
else
    AI1=IT0(:,:,:,1:floor(NC/2));
    AI0=IT0(:,:,:,floor(NC/2)+1:NC);
end
ch1=1:ceil(chCut*NC/32);
ch2=ceil(chCut*NC/32)-floor(NC/32):floor(NC/2);
if(dimm==3)
    R=sum(AI1(:,:,ch1),dimm);
    G=sum(AI1(:,:,ch2),dimm);
end
if(dimm==4)
    R=sum(AI1(:,:,:,ch1),dimm);
    G=sum(AI1(:,:,:,ch2),dimm);
end
B=sum(AI0,dimm);

I3=cat(dimm,R,G,B);
if(1)
    if(dimm==4),I3=permute(I3,[1 2 4 3]);end
    if(nargin<2)
    I3=balance3Chan(I3);
    else
   I3=balance3Chan(I3,rg);
    end
   if(dimm==4),I3=permute(I3,[1 2 4 3]);end
else
    I3=NormArray(I3);
end
end