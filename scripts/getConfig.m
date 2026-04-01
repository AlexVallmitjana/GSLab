function [conf] = getConfig(folder)
% given path to flame image folder return config tag
try
conf=folder(find(folder=='_',1,'last')+1:end);
catch
conf='UNK';
end

end