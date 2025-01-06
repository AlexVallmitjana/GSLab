function [f,c] = squareDistrib2(Q,R,r)
% Given Q a number of instances returns best 2d f (rows) by c (columns) 
% distribution of at least Q squares(r=1) in rectangle of ratio R (height/width).
% ratio r (h/w) is for the individual rectangles
if(nargin<2),R=1;end
if(nargin<3),r=1;end
c=ceil(sqrt(Q/(R/r)));
f=ceil(Q./c);

% if number empty spaces equals number of rows, reduce by one column
if(mod(Q,c)-1==f-1) % minus one is absurd but autoexplicative   
   c=c-1; 
end
if(f*c<Q),if(c<f),c=c+1;else f=f+1;end;end

end