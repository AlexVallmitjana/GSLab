function [Im] = unjag(Im,gap)
% shift every other line by a gap to compensate for bidirectional scanning

if(gap~=0)
    if(gap>0)
        rang=1:2:size(Im,1);
    else
        gap=-gap;
        rang=2:2:size(Im,1);
    end
    chunk=zeros(1,gap,size(Im,3),size(Im,4),size(Im,5));
    for ii=rang
        Im(ii,:,:,:,:)=[Im(ii,gap+1:end,:,:,:) chunk];
    end


    Im(:,end-gap+1:end,:,:,:)=[];
end

end