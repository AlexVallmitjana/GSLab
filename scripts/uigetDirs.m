function [folders] = uigetDirs(titol,N)
% get N folder paths and remember last path
% returns cell of N paths (or a string if N==1).
% if N is not specified it keeps asking until cancelled
%
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Select mother folder(s)';end
folder='';
ruta='lastfolder.mat';
try% attempt to save user settings file in matlab folder
    rut=[userpath];
    if(exist(rut,'dir')~=7)
        mkdir(rut);
    end
    ruta=[rut filesep 'lastfolder.mat'];
end
if(strcmp(fname,'FE78'))% flame raw folder
    try% when user selects FLAME raw and ref it should open the same folder
        aux=findstr(ruta,'lastfolder.mat');
        ruta=[ruta(1:aux-1) 'lastfile.mat'];
        load(ruta);
        fname='F641';
        eval(['folder=' fname ';']);% assign last ref
        folder=folder(1:find(folder==filesep,1,'last'));
    end
else
    try
        load(ruta);
        eval(['folder=' fname ';']);
    end
end
Nn=0;folders=cell(0);
aux=1;
while(aux==1)
    folder=uigetdir(folder,titol);
    if(strcmp(class(folder),'double')==0)
        Nn=Nn+1;
        folders{Nn}=folder;
        if(~strcmp(fname,'F7CD'))% titol not 'Select output folder' (if output we want to remember folder path not parent)
            try% save parent folder to open for next time (makes sense when selecting input data)
                folder=folder(1:find(folder==filesep,1,'last'));
            end
        end
        eval([fname '=''' folder ''';']);
        try
            eval(['save(''' ruta ''',''' fname ''',''-append'');']);
        catch
            eval(['save(''' ruta ''',''' fname ''');']);
        end
    else
        break;
    end
    if(Nn==N),break;end
end
if(Nn==1),folders=folders{1};end
end