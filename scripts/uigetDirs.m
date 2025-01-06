function [folders] = uigetDirs(titol,N)
% get N folder paths and remember last path
% returns cell of N paths (or a string if N==1). 
% if N is not specified it keeps asking until cancelled
%
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Select mother folder(s)';end
aux=1;folder='';
try 
    load(['lastfolder.mat']);
    eval(['folder=' fname ';']);
end
Nn=0;folders=cell(0);
while(aux==1)
    folder=uigetdir(folder,titol);
    if(strcmp(class(folder),'double')==0)
        Nn=Nn+1;
        folders{Nn}=folder;
        try
        folder=folder(1:find(folder==filesep,1,'last'));
        end
        eval([fname '=''' folder ''';']);
        try
       eval(['save(''lastfolder.mat'',''' fname ''',''-append'');']);
        catch
            eval(['save(''lastfolder.mat'',''' fname ''');']);
        end
    else
        break;
    end
    if(Nn==N),break;end
end
if(Nn==1),folders=folders{1};end
end