function [S1] = phasorFillNaN2(S1,ti)
% fill NaNs in image with mean of surrounding closer values
% done iteratively ti times in windows of 3x3 until no gaps are left (requires at least 1 pix to be non NaN!)
% if ti is a 2 element array ([eb,ti]), it computes the number of times the ebxeb window needs to be applied to compensate for a smoothing of size ti(1) applied ti(2) times

%% Optimized: replaces inner pixel loop with vectorized conv2 operations
if nargin < 2, ti = size(S1, 1); end
if numel(ti) > 1, ti = ((ti(1)-1)/2) * ti(2); end

[~, ~, c] = size(S1);
kernel = ones(3, 3);

for tt = 1:ti
    cc = 0;
    for zz = 1:c
        slice = S1(:,:,zz);
        nanMask = isnan(slice);
        
        if ~any(nanMask(:)), continue; end

        % Replace NaNs with 0 for convolution
        filled = slice;
        filled(nanMask) = 0;

        % Sum of valid neighbors, and count of valid neighbors
        neighborSum   = conv2(filled,   kernel, 'same');
        neighborCount = conv2(~nanMask, kernel, 'same');

        % Only fill border NaNs (NaN pixels that have at least 1 valid neighbor)
        borderMask = nanMask & (neighborCount > 0);
        cc = cc + nnz(borderMask);

        slice(borderMask) = neighborSum(borderMask) ./ neighborCount(borderMask);
        S1(:,:,zz) = slice;
    end
    if cc == 0, break; end
end
end
%% old version
% if(nargin<2),ti=size(S1,1);end
% if(numel(ti)>1),ti=((ti(1)-1)/2)*ti(2);end
% [a,b,c]=size(S1);
% temp=ones(3,3);
% for tt=1:ti
%     cc=0;% count number of fixes, if 0 we can break
%     for zz=1:c
%         slice=S1(:,:,zz);
%         I=~isnan(slice);
%         bord=imdilate(I,temp)-I;
%         fill=find(bord==1);
%         % while ~isempty(fill)
%         N=length(fill);cc=cc+N;
%         new=ones(a,b)*999;
%         for ii=N:-1:1
%             % [y,x]=ind2sub([a,b],fill(ii));
%             % manual ind2sub is 30x faster!
%             x=ceil(fill(ii)/a);
%             y=fill(ii)-(x-1)*a;
%             rgy=[max(y-1,1):min(y+1,a)];
%             rgx=[max(x-1,1):min(x+1,b)];
%             ret=S1(rgy,rgx,zz);
%             ret(isnan(ret))=[];
%             % new(fill(ii))=mean(ret);
%             new(fill(ii))=sum(ret)/numel(ret);
%         end
%         slice(new~=999)=new(new~=999);
%         S1(:,:,zz)=slice;
%     end
%     if(cc==0),break;end
% end