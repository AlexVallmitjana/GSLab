function [coords] = puntsMig(ori,fin)
%troba els punts discrets entre la parella de punts donada
% [coords] = puntsMig(ori,fin);
if(size(ori,1)>size(ori,2)),ori=ori';fin=fin';end
dim=length(ori);% 

if(length(unique(ori-fin))==1)&&(unique(ori-fin)==0)
coords=[ori;fin];
else
vec=fin-ori;
N=ceil(norm(vec))+1;

coords=zeros(N,dim);
for ii=1:dim
coords(:,ii)=linspace(ori(ii),fin(ii),N)';
end

coords=round(coords);

for ii=size(coords,1):-1:2
    d=0;
    for jj=1:dim
    if(coords(ii,jj)==coords(ii-1,jj))
        d=d+1;
    else
        break
    end
    end
    if(d==dim)       
       coords(ii,:)=[]; 
    end
end

        
end  

    
    
end