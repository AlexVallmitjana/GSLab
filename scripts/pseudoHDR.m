function [imh] = pseudoHDR(im)


[a,b]=size(im);
k=ceil([a,b]/20);
k=min(k,30);



if(1)% new fast approach in blocks instead of sliding window
    fun = @(block_struct) max(block_struct.data(:)) * ones(size(block_struct.data));
    MM = blockproc(im,k*2, fun);
    fun = @(block_struct) min(block_struct.data(:)) * ones(size(block_struct.data));
    mm = blockproc(im,k*2, fun);
    MM=imgaussfilt(MM,k);
    mm=imgaussfilt(mm,k);
else
    mm=zeros(size(im));
    MM=mm;
    ensenya('PseudoHDR 000%');
    for ii=1:a
        rngy=ii-k(1):ii+k(1);
        rngy(rngy<1)=[];
        rngy(rngy>a)=[];
        for jj=1:b
            rngx=jj-k(2):jj+k(2);
            rngx(rngx<1)=[];
            rngx(rngx>b)=[];
            win=im(rngy,rngx);
            % q=quantile(win(:),[.01 .99]);
            win=win(:);q=[min(win) max(win)];
            mm(ii,jj)=q(1);
            MM(ii,jj)=q(2);
        end
        percentatge(ii,a);
    end
    f=max([a,b]/100);
    MM=imgaussfilt(MM,f);
    mm=imgaussfilt(mm,f);
end




imh=(im-mm)./(MM-mm);
imh(isinf(imh))=1;
q=quantile(imh(:),[.001 .999]);
imh=(imh-q(1))./(diff(q));
imh(isnan(imh))=0;
imh(imh<0)=0;
imh(imh>1)=1;



end