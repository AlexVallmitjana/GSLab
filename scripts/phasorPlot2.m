function [I,tk1,tk2,remapping,extra] = phasorPlot2(S,G,sz,ex,fov,nor,txt,sty,cma)
%
% [I,tk1,tk2] = phasorPlot2(S,G,sz,ex,fov,nor,txt,sty,cma)
% Plots phasor given S and G arrays.
%   phasorPlot(G,S); will plot the phasor plot.
%   I=phasorPlot(G,S); will output an image with the phasor counts.
%       sz is a 1x2 vector specifying output image size (and therefore binning in phasor space).
%       ex determines wether output should include axis and circle lines:
%          0 for nothing, 1 for flim phasor lines, 2 for spectral phasor lines, 3 for orthogonal grid
%          11 for flim phasor lines and edges, 22 for spectral phasor lines and edges.
%          20 for only edges
%       fov is a 2x2 matrix of field of view: [minG maxG;minS maxS].
%       nor can be used if the phasor plot is composition of several images:
%           default is 0, no normalisation
%           set to 1 if there are NaNs in the data it will give more weight to images that
%           have less points so that the contribution of each pair of S and G is equal
%           set to 2 to normalise to the peak in the phasor plot instead of the counts (defaulted to 0).
%           if nor is an image the size of S and G, it is assumed the intensity image by which phasor histogram is normalised
%       txt flag indicates if text should be shown in axis (defaulted to 1).
%       sty flag for phasor style (0 for histogram, >0 for contour with the value determining the smoothing)
%       cma is the colormap for when sty>=1 and there is no output
%     
G0=G;S0=S;
out=isnan(S);S(out)=[];G(out)=[];
out=isnan(G);S(out)=[];G(out)=[];
if(nargin<8),sty=0;end
if((nargin<7)||(isempty(nor))),txt=1;end
if((nargin<6)||(isempty(nor))),nor=0;end
if((nargin<4)||(isempty(ex))),ex=20;end
if((nargin<3)||(isempty(sz))),adapt=1;if(mod(ex,11)==0),sz=[256,512];else,sz=[512,512];end,else,adapt=0;if(size(sz,1)>size(sz,2)),sz=sz';end;end
if(numel(sz)==1),sz(2)=sz(1);adapt=1;end
if(nargin<5)||(isempty(fov))
    centre=[mean(S(:)) mean(G(:))];sd=3*[std(S(:)),std(G(:))];%sd=2*max([std(S(:)),std(G(:))]);sd(2)=sd;
    if(adapt==1)
    if(sd(1)<sd(2)),sz(1)=round(sz(2)*sd(1)/sd(2));else,sz(2)=round(sz(1)*sd(2)/sd(1));end  % modify size to match fov      
    else
    if(sz(1)>sz(2)),sd(1)=sd(2)*sz(1)/sz(2);else,sd(2)=sd(1)*sz(2)/sz(1);end% modify fov to match size
    end
    fov=[centre(2)-sd(2) centre(2)+sd(2);centre(1)-sd(1) centre(1)+sd(1)];
end
% disp(sz)
if(size(nor,1)>1)
    INOR=nor;nor=3;
    if((size(INOR,1)~=size(S0,1))||(size(INOR,2)~=size(S0,2))),error('Intensity image should be the same size as phasor coordinate image.');end   
end
if(nor==1)
    if((size(S0,3)>1)&&(numel(find(isnan(S0)==1))>0))
        weight=zeros(size(S0,3),1);
        for ii=1:size(S0,3)
            weight(ii)=numel(find(isnan(S0(:,:,ii))==1));
        end
        ori=find(weight==min(weight));ori=ori(1);
    else
        nor=0;
    end
end

sz0=sz;

circrange=[.2:.2:1];
axesrange=linspace(0,360,17);axesrange=axesrange(1:end-1);
remapping=[];
if(nor==0)
    Sx=S0;Gx=G0;
    if(1)
out=find(Sx==0);Sx(out)=[];Gx(out)=[];
out=find(Gx==0);Sx(out)=[];Gx(out)=[];
    end
    [I,tk1,tk2,remapping] = hist2D(Gx(:),Sx(:),sz0(2:-1:1),fov);%  figure,bar([0:.01:1],histc(G(:),[0:.01:1]));figure,bar([0:.01:.5],histc(S(:),[0:.01:.5]))
end
if(nor==1)
    rg=1:size(S0,3);
    rg(rg==ori)=[];
    [I,tk1,tk2] = hist2D(reshape(G0(:,:,ori),[size(G0,1)*size(G0,2),1]),reshape(S0(:,:,ori),[size(S0,1)*size(S0,2),1]),sz0(2:-1:1),fov);
    ref=sum(sum(I));
    for ii=rg
        [Iaux,tk1,tk2] = hist2D(reshape(G0(:,:,ii),[size(G0,1)*size(G0,2),1]),reshape(S0(:,:,ii),[size(S0,1)*size(S0,2),1]),sz0(2:-1:1),fov);
        fac=ref/sum(sum(Iaux));
        I=I+Iaux*fac;
    end
end
if(nor==2)
    rg=1:size(S0,3);
    Iaux=zeros(sz0(1),sz0(2),size(S0,3));
    for ii=rg
        [I,tk1,tk2] = hist2D(reshape(G0(:,:,ii),[size(G0,1)*size(G0,2),1]),reshape(S0(:,:,ii),[size(S0,1)*size(S0,2),1]),sz0(2:-1:1),fov);
        Iaux(:,:,ii)=I/max(max(I));
        %          figure(333),imagesc(I);pause();
    end
    I=sum(Iaux,3);I=I/max(max(I));
    %I=NormArray(I);
    %weights=max(max(Iaux))
    %max(Iaux,[],[1,2]);
end
if(nor==3)
    res=100;
     if(max(INOR(:))<10),INOR=INOR*res;end
           INOR=round(res*INOR/max(INOR(:)));
gg=INOR(:);ggS=S0(:);ggG=G0(:);
Sx=zeros(sum(gg),1);Gx=zeros(sum(gg),1);
cc=1;
for ii=1:length(gg)
Sx(cc:cc+gg(ii)-1)=ggS(ii)*ones(gg(ii),1);
Gx(cc:cc+gg(ii)-1)=ggG(ii)*ones(gg(ii),1);
cc=cc+gg(ii);
end

    
e2=linspace(fov(1,1),fov(1,2),sz0(2));
e1=linspace(fov(2,1),fov(2,2),sz0(1));
I = hist3([Sx,Gx],'Ctrs',{e1,e2});
I=I(end:-1:1,:);
    remapping=0;clear Sx;clear Gx;

end
if(sty>0)
    [x,y]=meshgrid(linspace(fov(1,1),fov(1,2),sz(2)),linspace(fov(2,2),fov(2,1),sz(1)));
    try
      aux=remapping(find((G0==0)&(S0==0)),1:2);
      I(aux(1,1),aux(1,2))=0;
    end
    aux=NormArray(imgaussfilt(I,5));
    figure(999);
    clf;axes('position',[0 0 1 1]);
     [~,h]=contour(x,y,aux,linspace(0,1,10));
     mapeta=superjet(10,'elyor');
     colormap(mapeta);
     set(gca,'xtick',[],'ytick',[]);
     [I,~]=getframe(gcf);
     close(999);     
     [I]=rgb2ind(I,[1 1 1;mapeta]);
     I=imresize(I,sz);
     if(nargout==0)
         if(nargin<9),cma=mapeta;end
[~,h]=contour(x,y,aux,linspace(0,1,10));niceplot();colormap(cma);
axis equal;phasorPlotPoints([-1000,-1000]);xlim(fov(1,:));ylim(fov(2,:));
     end
end
% disp(max(max(max(I))));
peakcounts=max(max(max(I)));% normalising to this  value
if(peakcounts==min(I(:))),peakcounts=peakcounts+1;end
 %peakcounts=168;
extra=zeros(size(I));
if(ex~=0)% if lines are to be plotted
    valor=-0.025;% fraccio del colormap per a linies i text
    col=peakcounts*valor;
    umb=peakcounts*.03;
    if(mod(ex,10)==1)% flim phasor
        pixsiz=(diff(fov,1,2)./sz(2:-1:1)');%g and s
        centre=round((([.5 0]'-fov(:,1))./diff(fov,1,2)).*sz(2:-1:1)');
        rad=.5./pixsiz;
        angs=linspace(0,3.1416,100);
        for ii=2:length(angs)
            coords=puntsMig(centre+rad.*[cos(angs(ii-1)) sin(angs(ii-1))]',centre+rad.*[cos(angs(ii)) sin(angs(ii))]');
            coords=coords(:,2:-1:1);
            coords(:,1)=size(I,1)-coords(:,1)+1;
            out=coords(:,1)<1;coords(out,:)=[];out=coords(:,2)<1;coords(out,:)=[];
            out=coords(:,1)>size(I,1);coords(out,:)=[];out=coords(:,2)>size(I,2);coords(out,:)=[];
            for kk=1:size(coords,1)
                if(I(coords(kk,1),coords(kk,2))<umb)
                    I(coords(kk,1),coords(kk,2))=col;
                end
            end
        end
    end
    if(mod(ex,10)==3)% orthogonal
       for jj=1:size(tk2,2)
           coords=[tk2(1,jj)*ones(size(I,2),1),[1:size(I,2)]'];
           for kk=1:size(coords,1)
                    if(I(coords(kk,1),coords(kk,2))<umb)
                        I(coords(kk,1),coords(kk,2))=col;
                    end
           end
       end
       for jj=1:size(tk1,2)
           coords=[[1:size(I,1)]',tk1(1,jj)*ones(size(I,1),1)];
           for kk=1:size(coords,1)
                    if(I(coords(kk,1),coords(kk,2))<umb)
                        I(coords(kk,1),coords(kk,2))=col;
                    end
           end
       end       
    end
    if(mod(ex,10)==2)% spectral phasor
        gg=0;
        llocs=unique(abs([tk1(2,:),tk2(2,:)]));
        llocs=[min(llocs):max(diff(llocs)):max(llocs)];
        llocs=[llocs llocs(end)+llocs(2)-llocs(1)];llocs=[llocs llocs(end)+llocs(2)-llocs(1)];llocs=[llocs llocs(end)+llocs(2)-llocs(1)];
        llocs=[.1:.1:1];% remove for more lines
        pixsiz=(diff(fov,1,2)./sz(2:-1:1)');%g and s
        centre=round((([0 0]'-fov(:,1))./diff(fov,1,2)).*sz(2:-1:1)');
        centre=centre+[1,1];
        angs=linspace(0,2*3.1416,100);
        % pintem cercles
        for jj=1:length(llocs)% per cada radi
            rad=llocs(jj)./pixsiz;
            for ii=2:length(angs)% recorrem el cercle
                coords=puntsMig(centre+rad.*[cos(angs(ii-1)) sin(angs(ii-1))]',centre+rad.*[cos(angs(ii)) sin(angs(ii))]');
                coords=coords(:,2:-1:1);
                coords(:,1)=size(I,1)-coords(:,1)+1;
                out=coords(:,1)<1;coords(out,:)=[];out=coords(:,2)<1;coords(out,:)=[];
                out=coords(:,1)>size(I,1);coords(out,:)=[];out=coords(:,2)>size(I,2);coords(out,:)=[];
                for kk=1:size(coords,1)
                    if(I(coords(kk,1),coords(kk,2))<umb)
                        I(coords(kk,1),coords(kk,2))=col;
                    end
                end
            end
        end
        % pintem radis
        axesrange=linspace(0,2*3.1416,17);axesrange=axesrange(1:end-1);
        for ii=1:length(axesrange)
            coords=puntsMig(centre,centre+rad.*[cos(axesrange(ii)) sin(axesrange(ii))]');
            coords=coords(:,2:-1:1);
            coords(:,1)=size(I,1)-coords(:,1)+1;
            out=coords(:,1)<1;coords(out,:)=[];out=coords(:,2)<1;coords(out,:)=[];
            out=coords(:,1)>size(I,1);coords(out,:)=[];out=coords(:,2)>size(I,2);coords(out,:)=[];
            for kk=1:size(coords,1)
                if(I(coords(kk,1),coords(kk,2))<umb)
                    I(coords(kk,1),coords(kk,2))=col;
                end
            end
        end
    end
    if(ex>10)
        bord=round(min(sz0)*.01);bord(2)=bord(1);% gruix borde
        I(:,1:2*bord(2))=0;I(:,end-2*bord(2)+1:end)=0;
        I(1:2*bord(1),:)=0;I(end-2*bord(1)+1:end,:)=0;
        
        tk22=tk2;tk22=[2*tk2(:,1)-tk2(:,2),tk2,2*tk2(:,end)-tk2(:,end-1)];
        for mm=2:size(tk22,2)% loop vertical ticks
            if(txt==1)
                I=textIm(2*bord(2),tk22(1,mm),niceNums(tk22(2,mm)),I,'fontsize',ceil(sz0(1)/32),'fontname','verdana','textcolor',col,'horizontal','left','vertic','mid');
            end
            aux=col*mod(mm,2);
            % only draw below umbral
            try
                aux2=I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),1:bord(2));aux2(aux2<umb)=aux;I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),1:bord(2))=aux2;
                aux2=I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),bord(2)+1:2*bord(2));aux2(aux2<umb)=col-aux;I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),bord(2)+1:2*bord(2))=aux2;
                aux2=I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),end-bord(2)+1:end);aux2(aux2<umb)=aux;I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),end-bord(2)+1:end)=aux2;
                aux2=I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),end-2*bord(2)+1:end-bord(2));aux2(aux2<umb)=col-aux;I(max(1,tk22(1,mm-1)):min(sz(1),tk22(1,mm)),end-2*bord(2)+1:end-bord(2))=aux2;
            end
        end
        tk11=tk1;tk11=[2*tk1(:,1)-tk1(:,2),tk1,2*tk1(:,end)-tk1(:,end-1)];
        for mm=2:size(tk11,2)% loop vertical ticks
            if(txt==1)
                I=textIm(tk11(1,mm),size(I,1)-2*bord(1),niceNums(tk11(2,mm)),I,'fontsize',ceil(sz0(1)/32),'fontname','verdana','textcolor',col,'horizontal','center','vertic','bot');
            end
            aux=col*mod(mm,2);
            % only draw below umbral
            try
                aux2=I(1:bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)));aux2(aux2<umb)=aux;I(1:bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)))=aux2;
                aux2=I(end-bord(1)+1:end,max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)));aux2(aux2<umb)=aux;I(end-bord(1)+1:end,max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)))=aux2;
                aux2=I(bord(1)+1:2*bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)));aux2(aux2<umb)=col-aux;I(bord(1)+1:2*bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)))=aux2;
                aux2=I(end-2*bord(1)+1:end-bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)));aux2(aux2<umb)=col-aux;I(end-2*bord(1)+1:end-bord(1),max(1,tk11(1,mm-1)):min(sz(2),tk11(1,mm)))=aux2;
            end
        end
        % marge interior del borde
        aux2=I(2*bord(1),2*bord(2):end-2*bord(2)+1);aux2(aux2<umb)=col;I(2*bord(1),2*bord(2):end-2*bord(2)+1)=aux2;
        aux2=I(end-2*bord(1)+1,2*bord(2):end-2*bord(2)+1);aux2(aux2<umb)=col;I(end-2*bord(1)+1,2*bord(2):end-2*bord(2)+1)=aux2;
        aux2=I(2*bord(1):end-2*bord(1)+1,2*bord(2));aux2(aux2<umb)=col;I(2*bord(1):end-2*bord(1)+1,2*bord(2))=aux2;
        aux2=I(2*bord(1):end-2*bord(1)+1,end-2*bord(2)+1);aux2(aux2<umb)=col;I(2*bord(1):end-2*bord(1)+1,end-2*bord(2)+1)=aux2;
        % marge exterior
        I(1,:)=col;I(:,1)=col;I(end,:)=col;I(:,end)=col;
    end
    extra=-I;extra(extra<0)=0;extra=NormArray(extra);
    I(I<0)=-I(I<0);
end

if(nargout==0)&&(sty==0)
    if(nargin<9)
    %
    if(max(I(:))<15)
        cma=superjet(max(max(I(:),15)),'wSbZctglyGarFmp');% seeColormap(cma)
    else
    cma=superjet(max(I(:)),'wSbZctglyGarFmp');cma(1,:)=[1 1 1];
    end
    end
%     cma=superjet(255,'weglyyoar');
    PP=gray2rgb(I,cma);
    extra=cat(3,extra,extra);extra=cat(3,extra,extra);extra=extra(:,:,1:3);
    PP=(1-extra).*PP;
    % top-left top-right ; bot-left bot right
    xI=[fov(1,1:2);fov(1,1:2)];
    yI=[fov(2,2) fov(2,2);fov(2,1) fov(2,1)];
    zI=[0 0; 0 0];
    surf(xI,yI,zI,'CData',PP,'FaceColor','texturemap','EdgeColor','none');
    if(sum(fov(1,1:2)==[0,.5])==2),fov(1,1:2)=[0,.6];end
    niceplot;view(0,90);xlim(fov(1,1:2));ylim(fov(2,1:2));
    axis image;grid off;set(gca,'color','w');
    colormap(superjet(255,'wSbZctglyGorrmp'));
    %set(gca,'xtick',[],'ytick',[]);
    
    if(ex<=10)
       % set(gca,'xtick',tk1(2,:),'xticklabel',tk1(2,:),'ytick',tk2(2,end:-1:1),'yticklabel',tk2(2,end:-1:1));
    else
        set(gca,'xtick',[],'ytick',[]);
    end
    colormap(superjet(255,'wSbZctglyGorrmp'));%colorbar()
    h=line(fov(1,:),[fov(2,1) fov(2,1)]);set(h,'color','k');
    h=line(fov(1,:),[fov(2,2) fov(2,2)]);set(h,'color','k');
    h=line([fov(1,1) fov(1,1)],fov(2,:));set(h,'color','k');
    h=line([fov(1,2) fov(1,2)],fov(2,:));set(h,'color','k');
    drawnow;
end

end