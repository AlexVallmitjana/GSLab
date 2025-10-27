function [nI] = gray2rgb(I,map)

%turn grayscale to rgb based on values in colormap map

nI=zeros(size(I,1),size(I,2),3);
%sc0=zeros(size(I,1),size(I,2));
I=double(I);
df=size(I,1)*size(I,2);
df2=2*df;
if(numel(unique(I))==1)
    nI(:,:,1)= map(1,1);
    nI(:,:,2)= map(1,2);
    nI(:,:,3)= map(1,3);
else
    I=NormArray(I);
    I=round(I*(size(map,1)-1));
    I=I+1;
    %vv=unique(I);
    %rg=linspace(min(vv),max(vv),size(map,1));
    
    for ii=1:size(map,1)
        
        qui=find(I==ii);
        nI(qui)=map(ii,1);
		nI(qui+df)=map(ii,2);
		nI(qui+df2)=map(ii,3);
		
        %sc=sc0;
        
       % sc(qui)=map(ii,1);
       % nI(:,:,1)=nI(:,:,1)+sc;
        
       % sc(qui)=map(ii,2);
       % nI(:,:,2)=nI(:,:,2)+sc;
        
       % sc(qui)=map(ii,3);
       % nI(:,:,3)=nI(:,:,3)+sc;
        
    end
    
end

end