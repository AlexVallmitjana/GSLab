function [ret] = isType(folder,tag)
% check if last folder in path starts with tag or if it is a care folder
% or a care within a temporary folder of a tagged folder
ret=0;
aux=find(folder==filesep,1,'last');
if(isempty(aux))
    aux=folder;
else
aux=folder(aux(1)+1:end);
end
if(strcmpi(aux(1:length(tag)),tag))
    ret=1;
else
    if(strcmpi(aux(1:3),'car'))% if its a care folder it may still be a mosaic
        aux=find(folder==filesep,2,'last');
        aux=folder(aux(1)+1:end);
        if(strcmpi(aux(1:length(tag)),tag))
            ret=1;
        else
            if(strcmpi(aux(1:3),'tem'))% if its a tempcare folder it may still be a mosaic
                aux=find(folder==filesep,3,'last');
                aux=folder(aux(1)+1:end);
                if(strcmpi(aux(1:length(tag)),tag))
                    ret=1;
                end
            end
        end
    end
end

end