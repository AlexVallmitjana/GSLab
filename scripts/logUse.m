function [] = logUse(prog)

ara=char(datetime('now','format','yyyyMMddHHmmss'));
[qui]=whosPC();
try
load('FLAMElogs.mat','dad');

cc=size(dad,1);
cc=cc+1;
dad{cc,1}=ara;
dad{cc,2}=qui;
dad{cc,3}=prog;


save('FLAMElogs.mat','dad','-append');
end
end