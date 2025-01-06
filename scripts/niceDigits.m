function [N] = niceDigits(N,n,ch)
%converts integer N into a string with preceding zeros (or specified character ch)
%to a total of n digits
if(nargin<3),ch='0';end
if(nargin<2),n=2;end
N=num2str(round(N));Nl=length(N);
for ii=1:n-Nl
   N=[ch(1) N];
end

end