function [Im] = textIm(varargin)
%
% outputImage = textIm(x,y,text,image,options)
%
% options can be any of the following couples
%  'fontsize',number (default is 15)
%  'fontname',name (default is 'verdana')
%  'textcolor',[three value vector] (default is [1 1 1])
%  'horizontalalignment', either 'left', 'center' or 'right' (default is 'left')
%  'verticalalignment', either 'top', 'mid' or 'bot' (default is 'mid')
%  'blending', either 'on' or 'off' (default is 'on')
%  'background', either 'none','box','circle' (default is 'none')
%  'bgcolor', [three value vector] (default is inverse) background color
%  'bdcolor', [three value vector] (default is inverse) background border color
%
% example call:
%     Im2=textIm(100,50,'helloWorld!',originalImage,...
%      'fontsize',8,'fontname','verdana','textcolor',[1 1 0],...
%      'horizontalalignment','center','verticalalignment','bot');

x=round(varargin{1});
y=round(varargin{2});
txt=varargin{3};
Im=varargin{4};

if(strcmp(class(Im),'uint16')==1),end
if(~isempty(txt))
    colt=[1 1 1];
    c=[0.5,0];%centre del text
    fs=15;
    fn='verdana';
    blend=1;
    bg=0;
    forma=1;
    bgcolor=-99;
    bdcolor=-99;
    for ii=5:2:nargin
        gaga=lower(varargin{ii});
        gaga=gaga(1:6);
        switch gaga
            case 'fontsi'
                fs=varargin{ii+1};
            case 'bgcolo'
                bgcolor=varargin{ii+1};
            case 'textco'
                colt=varargin{ii+1};
            case 'bdcolo'
                bdcolor=varargin{ii+1};
            case 'fontna'
                fn=varargin{ii+1};
            case 'horizo'
                gaga2=lower(varargin{ii+1}(1:3));
                switch gaga2
                    case 'lef'
                        c(2)=0;
                    case {'cen','mid'}
                        c(2)=0.5;
                    case 'rig'
                        c(2)=1;
                end
            case 'vertic'
                gaga2=lower(varargin{ii+1}(1:3));
                switch gaga2
                    case 'top'
                        c(1)=0;
                    case {'cen','mid'}
                        c(1)=0.5;
                    case 'bot'
                        c(1)=1;
                end
            case 'blendi'
                gaga2=lower(varargin{ii+1}(1:2));
                switch gaga2
                    case 'on'
                        blend=1;
                    case 'of'
                        blend=0;
                end
            case 'backgr'
                gaga2=lower(varargin{ii+1}(1:2));
                switch gaga2
                    case 'no'
                        bg=0;
                    case 'bo'
                        bg=1;forma=1;
                    case 'ci'
                        bg=1;forma=2;
                end
        end
    end
    if(bgcolor==-99),bgcolor=IC(colt);end
    if(bdcolor==-99),bgcolor=colt;end
    T=1;
    if(max(max(max(Im)))<=1),T=1;end
    if(max(max(max(Im)))>256),T=max(max(max(Im)));end
    if(strcmp(class(Im),'double')&&(T==255)),T=1;end
    T=1;% afegit apanyu cutre
    tenimchars=exist('charset.mat');
    if((strcmp(fn,'verdana'))&&(tenimchars==2))
        load('charset.mat','chars','index');
        
        
        F=[];
        for ii=1:length(txt)
            ind=strfind(index,txt(ii));
            if(~isempty(ind))
                F=[F chars{ind(1)}];
            end
        end
        
        
    else
        
        figure(424);axes('position',[0,0,1,1]);
        plot(0,0,'w+');hold on;plot(1000,1000,'w+');xlim([10 990]);ylim([10 990]);
        
        text(500,500,txt,'fontname',fn,'fontsize',fs);
        
        set(gca,'xtick',[0 1000],'ytick',[0 1000]);
        F=getframe(424);F=double(F.cdata);
        close(424);
        
        F=F(:,:,1)+F(:,:,2)+F(:,:,3);F=F/3;
        F=255-F;F=F/255;
        F=F(3:end-3,3:end-3,:);
        
        
        [a,b]=find(F>0);
        F=F(min(a):max(a),min(b):max(b),:);
        
        
    end
   
    F=imresize(F,fs/size(F,1));
    F=(F-min(min(F)))/(max(max(F))-min(min(F)));
    if(F(1,1)>0)
        F=(F-F(1,1))/(max(max(F))-F(1,1));
        F(F<0)=0;
    end
    
    
    
    [a,b]=find(F>0);[sv,sh]=size(F);if(min(a)==1),F=[zeros(1,size(F,2));F];end
    [a,b]=find(F>0);[sv,sh]=size(F);if(max(a)==sv),F=[F;zeros(1,size(F,2))];end
    [a,b]=find(F>0);[sv,sh]=size(F);if(min(b)==1),F=[zeros(size(F,1),1),F];end
    [a,b]=find(F>0);[sv,sh]=size(F);if(max(b)==sh),F=[F,zeros(size(F,1),1)];end
    [a,b]=find(F>0);
if(c(2)==.5)% aligment center
     F=F(min(a)-1:max(a)+1,min(b)-1:max(b)+1);% remove margins
end
if(c(2)==0)% aligment left
     F=F(min(a)-1:max(a)+1,1:max(b)+1);% allow preceding spaces
end
if(c(2)==1)% aligment right
     F=F(min(a)-1:max(a)+1,min(b)-1:end);% allow spaces after
end
    [sv,sh]=size(F);
    
    if(forma==2),
        
        radi=2+floor(max([max(a)-min(a),max(b)-min(b)])/2);
        extr=[floor(((2*radi)+1-sv)/2) floor(((2*radi)+1-sh)/2)];
        Fa=[zeros(extr(1),sh);F;zeros(extr(1),sh)];
        F=[zeros(sv+2*extr(1),extr(2)),Fa,zeros(sv+2*extr(1),extr(2))];
        [sv,sh]=size(F);
        
        radi=floor(size(F,1)/2);
        plac=zeros(size(F));
        for ii=1:size(plac,1)
            for jj=1:size(plac,2)
                vec=[ii,jj]-[radi,radi];
                if(norm(vec)<radi),
                    plac(ii,jj)=1;
                end
            end
        end
        %  cent=ceil(size(ret)/2);
        %  cent2=floor([sv,sh]/2);
        %  ret(cent(1)-cent2(1):cent(1)+cent2(1),cent(2)-cent2(2):cent(2)+cent2(2))=F;
        
        [a,b]=find(plac>0);[szv,szh]=size(F);if(max(b)==szh),plac=[plac,zeros(size(plac,1),1)];end
        [a,b]=find(plac>0);[szv,szh]=size(F);if(max(a)==szv),plac=[plac;zeros(1,size(plac,2))];end
        [a,b]=find(plac>0);[szv,szh]=size(F);if(min(b)==1),plac=[zeros(size(plac,1),1),plac];end
        [a,b]=find(plac>0);[szv,szh]=size(F);if(min(a)==1),plac=[zeros(1,size(plac,2));plac];end
        bord=plac;
        bord=bord-imerode(bord,[1,1,1;1,1,1;1,1,1]);
        
    end
    
    c=round([sv,sh].*c);
    rgy=y-c(1)+1:y+sv-c(1);
    rgx=x-c(2)+1:x+sh-c(2);
    iny=find((rgy>0)&(rgy<=size(Im,1)));
    inx=find((rgx>0)&(rgx<=size(Im,2)));
    F=F(iny,inx);
    
    
    
    ret=double(Im(rgy(iny),rgx(inx),:));
    
    %
    
    
    % figure;imagesc(ret/T)
    r2=zeros(size(ret));
    if(forma==1),
        placa=ones(size(F));
    else
        bord=bord(iny,inx);
        plac=plac(iny,inx);
        placa=plac;
    end
    if(blend==0),F=double(F>.55);end
    for ii=1:size(ret,3)
        curr=ret(:,:,ii);
        if(bg==1),
            curr(placa==1)=bgcolor(ii);
            if(forma==1),
                curr(1,:)=bdcolor(ii);curr(:,1)=bdcolor(ii);curr(:,end)=bdcolor(ii);curr(end,:)=bdcolor(ii);
            else
                curr(bord==1)=bdcolor(ii);
            end
            dest=placa*colt(ii)*T;
            r2(:,:,ii)=curr+(dest-curr).*F;
        else
            dest=placa*colt(ii)*T;
            r2(:,:,ii)=curr+(dest-curr).*F;
        end
    end
    
    % figure;imagesc(F)
    % figure;imagesc(r2/T)
    
    if(strcmp(class(Im),'uint8')==1)
        r2=uint8(r2);
    end
    if(strcmp(class(Im),'uint16')==1)
        r2=uint16(r2);
    end
    Im(rgy(iny),rgx(inx),:)=r2;
    
    
    
    
    
    
    
end

    function [col3] = IC(col)
        gg=0;
        if(max(col)>1),col=col/255;gg=1;end
        if(length(col)==1),
            col3=1-col;
        else
            col1=1-col;
            col2=abs([0.5,0.5,0.5]-col1);
            if(norm(col1-col)>norm(col2-col))
                col3=col1;
            else
                col3=col2;
            end
        end
        if(gg==1),col3=col3*255;end
    end
end