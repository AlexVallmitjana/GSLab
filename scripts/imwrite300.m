function [] = imwrite300(im,route)


inchpermeter=39.3701;
switch route(end-2:end)
    case 'png'
imwrite(im,route,'XResolution',300*inchpermeter,'YResolution',300*inchpermeter,'ResolutionUnit','meter','Software','GSLab');
    case 'tif'
imwrite(im,route,'Resolution',[300 300]);
    otherwise
imwrite(im,route);        
end

end