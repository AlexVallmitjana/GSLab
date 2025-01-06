function [A] = NormArray(A)

aux=min(A(:));
A=(A-aux)./(max(A(:))-aux);

end