function [h]=subNM(n,m,q,marg,FF)
% subplot fix margin, creates axes in current figure such that it is the
% q-th out of a n-by-m grid with margins specified by marg as a normalised
% value. 
%marg can have two components, first for vertical second for horizontal.
% or four for left, bot, right, top
if(nargin<4),marg=0.05;end

fila=ceil(q/m);
columna=q-((fila-1)*m);

if(length(marg)==1),marg(2)=marg(1);end
if(length(marg)==2),marg(3)=marg(1);marg(4)=marg(2);end

panel=[(1-(m*(marg(1)+marg(3))))/m (1-(n*(marg(2)+marg(4))))/n];%tamany del panell

pos(1)=columna*marg(1)+(columna-1)*(panel(1)+marg(3));

pos(2)=1-panel(2)-((fila-1)*(marg(2)+marg(4)))-((fila-1)*panel(2))-marg(4);

pos(3)=panel(1);

pos(4)=panel(2);

if(nargin<5)
h=axes('units','normalized','position',pos);
else
    h=axes(FF,'units','normalized','position',pos);
end




end