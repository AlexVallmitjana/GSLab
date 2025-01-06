function [s,g] = tau2coords(tau,freq,harm)
% Return S,G given tau value in ns
% freq is repetition frequency in Hz
% harm is harmonic number
if(nargin<3),harm=1;end
if(nargin<2),freq=8e7;end
w=2*3.1416*freq*harm;

g=1/(1+(w*tau*1e-9)^2);

s=sqrt(g-g.*g);

end