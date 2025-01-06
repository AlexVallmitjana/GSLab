function [R] = magnitude(SS,GG,magn,freq,harm)
if(nargin<5),harm=1;end
if(nargin<4),freq=8e7;end
w=2*3.1416*freq*harm;
switch magn
    case 0 % G
        R=GG;
    case 1 % S
        R=SS;
    case 2 % phase
        R=atan2(SS,GG);
    case 3 % mod
        R=sqrt(SS.*SS+GG.*GG);        
    case 4 % pseudophase
        R=atan2(SS,GG-.5);
    case 5 % tau phase 
        %G=1./(1+(SS.*SS./GG./GG));
        %R=1e9*sqrt((1./G)-1)/w;
		R=1e9*(SS./GG)/w;
    case 6 % tau mod 
        %G=(SS.*SS)+(GG.*GG);
        %R=1e9*sqrt((1./G)-1)/w;
		M2=(SS.*SS)+(GG.*GG);
		R=(1e9/w)*sqrt((1./M2)-1);
    case 7 % tau pseudophase 
        G=.5*(1+cos(atan2(SS,GG-.5)));
        R=1e9*sqrt((1./G)-1)/w;
end