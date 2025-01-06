function [cb] = cbar(varargin)
% Custom colorbar. Parameters:
% sz image size
% mg margin either 1 value, 2 (vert,hori) or 4 (top,bot,left,right)
% cm the colormap
% cv values associated to the colormap
% fs font size (default 16)
% bg background color
% bc border color
% tc text color
% fa fraction of the space occupied by the bar not the text (excluding mg)
% nt number of ticks to show
% de number of decimals to show
% ha horizontal aligmnent of the text {'left','center,'right'}
%
% Example call:
% I=cbar('sz',[1000,90],'mg',[.05,.1]);
sz=[1000 100 3];
mg=[.05,.05,0,.01];
cm=superjet(255);
cv=[0:255];
fs=16;
fa=0.6;
n=10;
dec=0;fixdec=0;
ha='left';
for ii=1:2:nargin
    gg=lower(varargin{ii});
    if(ischar(gg)==0),error('Parameters must come in couples ''parameterName'',''parameterValue''.');end
    switch gg
        case {'sz','size'}
            sz=varargin{ii+1};
        case {'mg','margin'}
            mg=varargin{ii+1};
        case {'cm','cmap'}
            cm=varargin{ii+1};
            if(ischar(cm)),cm=superjet(cm);end            
            cv=cm;
        case {'cv','cvalues'}
            cv=varargin{ii+1};
        case {'fs','fontsize'}
            fs=varargin{ii+1};
        case {'fa','factor'}
            fa=varargin{ii+1};
        case {'nt','nticks'}
            n=varargin{ii+1};
        case {'de','decimals'}
            dec=varargin{ii+1};fixdec=1;
        case {'bg'}
            bg=varargin{ii+1};
        case {'bc'}
            bc=varargin{ii+1};            
        case {'tc'}
            tc=varargin{ii+1};   
        case {'ha'}
            ha=varargin{ii+1};               
        otherwise
            error(['There is no parameter named ''' gg ''' in cbar().'])
    end
end
if(size(cm,2)~=numel(sz)),sz(3)=size(cm,2);end
if(nargin<4),fs=16;end

try,cv=unique(cv);end

if(size(sz,2)==2)
    bl='off';if(~exist('bg','var')),bg=1;end;if(~exist('tc','var')),tc=0;end;if(~exist('bc','var')),bc=0;end
    cb=ones(sz(1),sz(2))*bg;
else
    bl='on';if(~exist('bg','var')),bg=[1 1 1];end;if(~exist('tc','var')),tc=[0 0 0];end;if(~exist('bc','var')),bc=[0 0 0];end
    cb0=ones(sz(1),sz(2));
    cb=cat(3,cb0.*bg(1),cb0.*bg(2));cb=cat(3,cb,cb0.*bg(3));
end
if(size(mg,2)==1),mg=[mg mg];end
if(size(cm,2)>size(cm,1)),cm=cm';end
if(size(mg,2)==2)
    if(max(mg)>=1),mg=(mg./sz);end
    rg=round([sz(1)*mg(1),sz(2)*mg(2),sz(1)*(1-mg(1)),sz(2)*(1-mg(2))]);
else
    if(max(mg)>=1),mg=[mg(1)/sz(1) mg(2)/sz(1) mg(3)/sz(2) mg(4)/sz(2)];end
    rg=round([sz(1)*mg(1),sz(2)*mg(3),sz(1)*(1-mg(2)),sz(2)*(1-mg(4))]);
end
fin=rg(4);
rg(rg==0)=1;
rg(4)=round(rg(2)+(fin-rg(2))*fa);
cols=size(cm,1);
for ii=1:length(bc)
cb(rg(1):rg(3)+1,rg(2):rg(4),ii)=bc(ii);
end
cb=cb(1:sz(1),:,:);
st=(rg(3)-rg(1)-1)/cols;
or=rg(1)+1;
rx=[rg(2)+1:rg(4)-1];
for ii=1:cols
    nx=or+st;
    tr=[floor(or):floor(nx)];
    for ch=1:size(cb,3)
        cb(tr,rx,ch)=cm(cols+1-ii,ch);
    end
    or=nx;
end

if n==0
    tkl=niceTicks([min(min(cv)),max(max(cv))]);
else
    if(n==length(cv))
        tkl=cv;
    else
        if(numel(cv)==2)
        tkl=linspace(min(min(cv)),max(max(cv)),n);
        else
            tkl=cv;
        end
    end
end
if(fixdec==0)&&(strcmp(class(cv),'double'))
    repe=1;dec=-1;
    while repe==1
         dec=dec+1;
    tst=niceNums(tkl(1),dec);
    if(dec==5),break;end
   for ii=2:length(tkl)
      if(strcmp(tst,niceNums(tkl(ii),dec)))
         repe=1;break;
      else
          repe=0;
      end
      tst=niceNums(tkl(ii),dec);
   end 
   
    end
end
if(strcmp(class(cv),'double'))
df=-(rg(1)-rg(3))/(length(tkl)-1);
tk=round(rg(1)+df*[0:length(tkl)-1]);
else
df=-(rg(1)-rg(3))/length(tkl)/2;
tk=round(rg(1)+df*[1:2:2*length(tkl)]);
end
tk=tk(end:-1:1);
for ii=1:length(tkl)
    for jj=1:length(bc)
    cb(tk(ii),rg(4):rg(4)+1,jj)=bc(jj);
    end
    if(strcmp(class(cv),'double')),lab=niceNums(tkl(ii),dec);else,lab=tkl{ii};end
    if(~ischar(lab)),lab=num2str(lab);end
    if(ha(1)=='l'),x=rg(4)+1;end
    if(ha(1)=='r'),x=size(cb,2)-1;end
    if(ha(1)=='c'),x=round((rg(4)+size(cb,2))/2);end
    cb=textIm(x,tk(ii),[lab],cb,'fontsize',fs,'textcolor',tc,'horizontalalignment',ha,'verticalalignment','mid','blending',bl);%,'background','box','bgcolor',1,'bdcolor',0);
end


end