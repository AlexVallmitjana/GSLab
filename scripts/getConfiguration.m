function [conf,confid] = getConfiguration(path)
if(path(end)==filesep),path=path(1:end-1);end
conf=[];
try
aux=find(path=='_',1,'last');
conf=path(aux+1:end);
end


tags={'2Ch','3Ch','4Ch','32A1','32A0','31nB','32Sp'};
confid=0;
for ii=1:numel(tags)
if(strcmp(conf,tags{ii})==1),confid=ii;end
end
end