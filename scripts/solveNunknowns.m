function [weights] = solveNunknowns(Ss,Gs,coefs)
% Solve system for n harmonics and N components in a single pixel.
% Ss and Gs are the nx1 arrays of phasor coordinates of the pixel in each harmonic. 
% coef are the coordinates of the N components, 1st column S, 2nd for G, first N lines for
% 1st harmonic, next N lines for 2nd and so on. 
% returns an Nx1 array of of weights, the estimated fractions of each component in the pixel.
%% %%

%prepare matrix of the system
n=[];M=[];comps=size(coefs,1)/size(Ss,1);
for jj=1:size(Ss,1)
    n=[n Ss(jj) Gs(jj)];
    M=[M;coefs([1:comps]+comps*(jj-1),1:2)'];
end

weights=zeros(comps,1);% initialise weights

% add last equation to system forcing sum of fractions to unity
    M=[M;ones(1,comps)];
    n=[n';1];
 
 % solve system Mx=n where x is the array of weights
 % matlab code for fast matrix operation
 I=M'*M;
 M=I\M';
 weights=M*n;

 

end