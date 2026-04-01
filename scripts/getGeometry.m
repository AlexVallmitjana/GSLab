function [geom,geomid] = getGeometry(path)
% given path return flame imaging geometry from last folder
geom='';
geomid=0;
if(path(end)==filesep),path=path(1:end-1);end
geos={'ima','mos','sta','zmo'};
for ii=1:numel(geos)

if(isType(path,geos{ii}))
    geom=geos{ii};
    geomid=ii;
end
end

end

