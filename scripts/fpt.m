function [S,G,I] = fpt(his,n)
% fast phasor transform (fft based) of photon histogram his
% performs fft along last non-singleton dimension
% dim=4;
if(nargin<2),n=1;end
siz=size(his);
dim=find(siz>1,1,'last');


F=fft(his,[],dim);
% S=0;G=0;I=0;
switch dim
    case 1
        I=F(1);
        S=imag(F(end-n+1))./I;
        G=real(F(end-n+1))./I;
    case 2
        I=F(:,1);
        S=imag(F(:,end-n+1))./I;
        G=real(F(:,end-n+1))./I;
    case 3
        I=F(:,:,1);
        S=imag(F(:,:,end-n+1))./I;
        G=real(F(:,:,end-n+1))./I;
    case 4
        I=F(:,:,:,1);
        S=imag(F(:,:,:,end-n+1))./I;
        G=real(F(:,:,:,end-n+1))./I;
    otherwise
        disp('neads implementing');
end

end