function [s,g] = expectedPhasorPosition(tau,freq,harm)
% Return S and G expected coordinates 
% tau is lifetime in ns
% freq is laser frequency in Hz
% harm os the harmonic (defaulted to 1)
if(nargin<3),harm=1;end
if(nargin<2),freq=8e7;end
w=2*3.1416*freq;
if(size(tau,2)>size(tau,1)),tau=tau';end

        omegatau=w*harm*1e-9.*tau;
        g=1./(1+(omegatau.^2));
        s=omegatau./(1+(omegatau.^2));
       

end