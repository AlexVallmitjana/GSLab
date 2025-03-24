function [I]=ansc(I,~)
% Anscombe transform
%    I=ansc(I);
% For inverse transform call with a second argument
%    I=ansc(I,1);
if(nargin==1)
    I=2*sqrt(I+.375);
else
    I=I*.5;
    I=I.*I;
    I=I-.375;
end
end

