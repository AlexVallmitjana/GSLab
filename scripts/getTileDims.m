function [m,n,success] = getTileDims(filename,verb)
success=1;
if(nargin<2),verb=1;end
nums='1234567890';
out=-2*ones(length(filename),1);
for ii=1:length(filename)

    for jj=1:length(nums)

        if(filename(ii)==nums(jj))
            out(ii)=mod(jj,10);
        end
    end
    if(filename(ii)=='x')
        out(ii)=10;
    end
end
aux=find(out==10);
trob=0;
for ii=1:length(aux)
    if(aux(ii)>1)
        if(aux(ii)<length(out))
            a=find(out(1:aux(ii))==-2,1,'last');
            if(isempty(a)),a=1;end
            b=find(out(aux(ii):end)==-2,1,'first');
            if(isempty(b)),b=numel(out)-aux(ii)+2;end
            un=out(a+1:aux(ii)-1);
            dos=out(aux(ii)+1:aux(ii)+b-2);
            if((~isempty(un))&&(~isempty(dos)))
                trob=trob+1;
                m=un;
                n=dos;
            end
        end
    end
end
gap=' Warning: ';
if(trob==0)   
    if(verb==1)
    cprintf([1 .5 0],[gap 'No grid dimensions, assuming single tile.\n']);
    end
    m=1;n=1;success=0;
end
if(trob>1)   
     if(verb==1)
    cprintf([1 .5 0],[gap 'More than one encoding for tile dimensions.\n']);
     end
end
if(numel(m)>1)
    aux=0;
    for ii=1:numel(m)
aux=aux+m(end+1-ii)*10^(ii-1);
    end
    m=aux;
end
if(numel(n)>1)
    aux=0;
    for ii=1:numel(n)
aux=aux+n(end+1-ii)*10^(ii-1);
    end
    n=aux;
end



end