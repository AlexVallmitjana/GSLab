function [c,q] = color2code(rgb)
% find closest superjet color code
[~,aux]=superjet();
cc=aux{1};
cdiccio=aux{2};
cdiccio=cdiccio/10;
dist=999;q=0;
for ii=1:numel(cc)

    gg=abs(cdiccio(ii,:)-rgb);
    gg=sum(gg.*gg);

    if(gg<dist),dist=gg;q=ii;end
end

c=cc(q);
end

