function [A] = NormArray2(A,q)
if(nargin>1)
    q=quantile(A(:),q);
    if(numel(q)==1)    
    A=A/q;    
    else
        A=(A-q(1))./(q(2)-q(1));
    end
else
    aux=min(A(:));
    aux1=max(A(:));
    if(aux1==aux),aux1=eps;end
A=(A-aux)./(aux1-aux);
end

A(A>1)=1;
A(A<0)=0;




end