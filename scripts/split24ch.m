function [I4] = split24ch(IT0,rg)

chCut=[4];% Juvs settings,4th out of 31
chCut2=[1];% new settings AI0
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
ch1=1:ceil(chCut2*NC/32);
ch2=ceil(chCut2*NC/32)+1:floor(NC/2);
if(dimm==3)
    B=sum(AI0(:,:,ch1),dimm);
    T=sum(AI0(:,:,ch2),dimm);
end
if(dimm==4)
    B=sum(AI0(:,:,:,ch1),dimm);
    T=sum(AI0(:,:,:,ch2),dimm);
end


I4=cat(dimm,R,G,B,T);
if(1)
   I4=balance3Chan(I4,rg);
else
    I4=NormArray(I4);
end
end
% function [I4] = split24ch(IT0)
% ch1=[1:4];% Juvs settings
% ch2=[4:32];% Juvs settings
% ch3=[1];% new settings AI0
% ch4=[2:32];% new settings AI0
% %
% if(size(IT0,4)>1)% assume 4th dim is time
%     dimm=4;
% else
%     dimm=3;
% end
% NC=size(IT0,dimm);
% if(dimm==3)
%     AI1=IT0(:,:,1:NC/2);
%     AI0=IT0(:,:,NC/2+1:NC);
% else
%     AI1=IT0(:,:,:,1:NC/2);
%     AI0=IT0(:,:,:,NC/2+1:NC);
% end
% ch1=unique(ceil(ch1*NC/2/32));
% ch2=unique(ceil(ch2*NC/2/32));
% if(dimm==3)
%     R=sum(AI1(:,:,ch1),dimm);
% end
% if(dimm==4)
%     R=sum(AI1(:,:,:,ch1),dimm);
% end
% if(NC~=32)
%     if(dimm==3)
%         G=sum(AI1(:,:,ch2),3);
%     end
%     if(dimm==4)
%         G=sum(AI1(:,:,:,ch2),4);
%     end
% else% if its a split32 we attempt to reproduce the overlapping 4th channel by giving only half the photons of the 2nd of 16 to G
%     if(dimm==3)
%         G=sum(AI1(:,:,3:16),3)+round(AI1(:,:,2)/2);
%     end
%     if(dimm==4)
%         G=sum(AI1(:,:,:,3:16),4)+round(AI1(:,:,:,2)/2);
%     end
% end
% 
% ch3=unique(ceil((ch3*NC/2/32)));
% ch4=unique(ceil((ch4*NC/2/32)));
% ch4=setdiff(ch4,ch3);
% 
%     B=sum(AI0(:,:,:,ch3),dimm);
% 
%     C=sum(AI0(:,:,:,ch4),dimm);
% 
% 
% I4=cat(dimm,R,G,B,C);
% if(0)
% 
% else
%     I4=NormArray(I4);
% end
% end