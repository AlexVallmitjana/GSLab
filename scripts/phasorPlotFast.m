function [I] = phasorPlotFast(S,G,sz,fov)
%
% [I,tk1,tk2] = phasorPlotFast(S,G,sz,ex,fov,nor,txt,sty,cma)
% Plots phasor given S and G arrays.
%   phasorPlot(G,S); will plot the phasor plot.
%   I=phasorPlot(G,S); will output an image with the phasor counts.
%       sz is a 1x2 vector specifying output image size (and therefore binning in phasor space).
%       fov is a 2x2 matrix of field of view: [minG maxG;minS maxS].

out=isnan(S);S(out)=[];G(out)=[];
out=isnan(G);S(out)=[];G(out)=[];


% if(0)

    % [I,tk1,tk2,remapping] = hist2D(G(:),S(:),sz(2:-1:1),fov);%  figure,bar([0:.01:1],histc(G(:),[0:.01:1]));figure,bar([0:.01:.5],histc(S(:),[0:.01:.5]))
% end
% 
% if(1)
% 
% 
e2=linspace(fov(1,1),fov(1,2),sz(2));
e1=linspace(fov(2,1),fov(2,2),sz(1));
I = hist3([S(:),G(:)],'edges',{e1,e2});
I=I(end:-1:1,:);
% 
% 
% end
end