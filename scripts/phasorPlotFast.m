function [I] = phasorPlotFast(S,G,sz,fov)

% [I,tk1,tk2] = phasorPlotFast(S,G,sz,fov)
% Plots phasor given S and G arrays.
%   I=phasorPlot(G,S,sz,fov); will output an image with the phasor counts.
%       sz is a 1x2 vector specifying output image size (and therefore binning in phasor space).
%       fov is a 2x2 matrix of field of view: [minG maxG;minS maxS].

e2=linspace(fov(1,1),fov(1,2),sz(2));
e1=linspace(fov(2,1),fov(2,2),sz(1));

S=S(:);G=G(:);

valid=S<=e1(end)&G<=e2(end);

e1(end+1)=e1(end)+eps(e1(end));
e2(end+1)=e2(end)+eps(e2(end));

I=histcounts2(S(valid),G(valid),e1,e2);
I=I(end:-1:1,:);
% 
% 
% end
end