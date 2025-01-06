function [name,folder] = uisaveFile(titol,type)
% get folder path for saving and remember last path
% returns strings
%
if(nargin<2),type='*.mat';end
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Save as';end
folder='';
try 
    load(['lastfolder.mat']);
    eval(['folder=' fname ';']);
end

    [name,folder]=uiputfile(type,titol,folder);
        
        eval([fname '=''' folder ''';']);
        try
       eval(['save(''lastfolder.mat'',''' fname ''',''-append'');']);
        catch
            eval(['save(''lastfolder.mat'',''' fname ''');']);
        end
   

end