function [cm] = superjet(varargin)
% Superjet is a general function for colormap building. The original aim
% was to extend the jet colormap to include black and white back in the 
% days when jet was the default colormap.
% If called without output argument it will show the colormap on a figure.
%
% superjet(); returns a 256-by-3 matrix containing an extension of jet colormap
% going through black-purple-blue-cyan-green-yellow-orange-red-pink-white.
%
% superjet(N); returns an N-by-3 matrix containing superjet colormap.
%
% superjet(N,option); returns the N-by-3 colormap with the following options:
%
%        'pale': Superjet is provided with pale colours.
%        'dark': Superjet is provided with dark colours.
%      'cyclic': Superjet starts and ends with the same colour (designed
%                for representation of angles).
%        'many': Designed to obtain many distinctive colours instead of a
%                progressive colour scale. A combination of normal,dark and
%                pale is returned.
%       'lines': The same as 'many' but in this case the colormap is
%                shuffled.
%         'all': All preset colors are shown with their associated character
%  'dictionary': Same as 'all' but they are sorted alphabetically.
%
% superjet(N,colors); returns an N–by–3 colormap where colors is a string 
%                    specifying the colors. The string can have however 
%                    many characters from the following table: 
%
% k – black     y – yellow   c – cyan   	m – magenta     w – white
% g – green   	r – red      b – blue      	v – violet    	p – pink     
% j – jade	    o – orange   u – purple   	i – indigo      x – xenon   
% e – emerald	a – amber	 s – salmon     F – fuchsia    	q – quartz
% l – lime      z – crimson  d – denim   	n – brown   	f – flesh     
% t – turquoise 0 – gray0	 1 – gray1	    2 – gray2	    3 – gray3
% 5 – gray5     6 – gray6  	 7 – gray7		8 – gray8       9 – gray9
% 
% Run superjet(‘all’); to see the complete list.
%
%   Example calls:
%
%   cm=superjet('kg');          % will produce a black to green colormap
%   cm=superjet('k123456789w'); % will produce a colormap similar to gray()
%   cm=superjet(200,'kroyw');   % will produce a colormap similar to hot(200)
%
%                                                          - AlexVL

%%%
% if(exist('colorDict.mat','file')==2)
%     load('colorDict.mat');
% else
  [cc,cdiccio,dnams]=inicialitza();
% end

% roig 7 2 2
%%%%
codi='kvbclyorpw';
%cdefault=[0 0 0;4 0 6;0 0 10;0 10 10;5 10 5;10 10 0;10 6 0;10 0 0;10 5 9;10 10 10];
fet=0;
N=256;
p=0;
if(nargin==0),var=N;end
for ii=1:nargin
    var=varargin{ii};
    if(ischar(var))
        switch var
            case 'pale'
                p=1;
            case 'dark'
                p=2;
            case 'many'
                p=4;
            case 'lines'
                p=5;
            case 'dictionary'
                codi=sort(cc);N=length(codi);p=3;
                inds=[find(codi=='a'):find(codi=='a')+25,find(codi=='A'):find(codi=='A')+25,find(codi=='0'):find(codi=='0')+9];
                inds=[inds setdiff([1:length(codi)],inds)];
                codi=codi(inds);
            case 'all'
                codi='k012JX;3E456789PwICxcQHqL:psFmvAiuZb.SdNTtgljeK_nM-OfByDUGoahrVR zY,W[';N=length(codi);p=3.5;
%                 ]
% '','','','','','','','tawny',...
            case 'cyclic'
                codi='ubcgyorpu';
            otherwise
                rec=1;
                colors=zeros(length(var),3);
                for jj=1:length(var)
                    tst=strfind(cc,var(jj));
                    if(isempty(tst)),rec=0;break;end
                    %colors(jj,1:3)=cdiccio(tst,1:3);
                end
                if(rec==0)
                    error(['argument ''' var(jj) ''' was not recognized.']);
                else
                    codi=var;
                end
        end
    else
        N=var;
    end
    
    
    
end

noms=cell(length(var),1);
var=codi;
for jj=1:length(var)
    tst=strfind(cc,var(jj));
    if(isempty(tst)),rec=0;break;end
    colors(jj,1:3)=cdiccio(tst,1:3);
    noms{jj}=dnams{tst};
end






%sum(abs(diff(colors)),2);
if(size(colors,1)>1),
    lap=(N-size(colors,1))/(size(colors,1)-1);
    
    cm=[];
    ind=1;
    for ii=1:size(colors,1)-1
        
        n=[round(ind):round(ind+lap)+1];
        or=colors(ii,:);
        fi=colors(ii+1,:);
        nn=length(n);
        cm(n,1:3)=[linspace(or(1),fi(1),nn)',linspace(or(2),fi(2),nn)',linspace(or(3),fi(3),nn)'];
        ind=ind+lap+1;
    end
    
    if((p<3)||(p>3.5))
        r=cm(:,1);g=cm(:,2);b=cm(:,3);
        % smoothing
        warning('off','all');
        filtre=ones(1,min(ceil(size(cm,1)*.1),floor(lap)));
        val=round(length(filtre)/2);
        if(~isempty(filtre))
            % using conv instead of filtfilt inorder to avoid toolbox 
            r2=conv(r,filtre'/length(filtre),'same');r2(1:val)=r(1:val);r2(end-val+1:end)=r(end-val+1:end);r=r2;
            r2=conv(g,filtre'/length(filtre),'same');r2(1:val)=g(1:val);r2(end-val+1:end)=g(end-val+1:end);g=r2;
            r2=conv(b,filtre'/length(filtre),'same');r2(1:val)=b(1:val);r2(end-val+1:end)=b(end-val+1:end);b=r2;
%             r=filtfilt(filtre/length(filtre),1,r);                       
%             g=filtfilt(filtre/length(filtre),1,g); 
%             b=filtfilt(filtre/length(filtre),1,b);
            cm=[r,g,b];
        end
        warning('on','all');
    end
    
else
    cm=ones(N,1)*colors;
end
cm=cm/10;
cm(cm>1)=1;cm(cm<0)=0;


if(p==1)
    cm=.5+cm*.5;
end
if(p==2)
    cm=cm*.5;
end
if(p>=4)
    if(fet==0)
        C1=superjet(N,'dark');
        C2=superjet(N,'pale');
        C3=superjet(N);C3=C3(end:-1:1,1:3);
        cm=[C1;C2;C3];              
    end
    if(p==4),cm=cm(3:3:end,1:3);end
    if((length(codi)==N)),for ii=1:N,codi(ii)=' ';end;end
    if(p==5)
%         ord=shuffle([1:3*N]);ord=ord(1:N);
        cm=cm(3:3:end,1:3);ord=shuffle([1:N]);
        cm=cm(ord',1:3);
        %codi=codi(ord);
    end
    
end

gg=0;

if((nargout<1)),if((length(codi)==N)),mostra(cm,codi);else,mostra(cm);end;end
if((p>=3)&&(p<=3.5)),graella(cm,codi,noms);end
end

function [cc,cdiccio,dnams] = inicialitza()

 cc='kubcgyorpwmvsnltidfxeajhqz 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ,.-;:_[]{}';% index del diccionari
cdiccio=[0 0 0;5 0 10;0 0 10;0 10 10;0 10 0;...
    10 10 0;10 7 0;10 0 0;10 5 9;10 10 10;...
    10 0 10;6 0 8;10 5 5;5 3 1;5 10 0;...
    0 10 5;3 0 7;0 2 4;9 7 4;9 10 10;...
    0 4 0;10 5 0;6 8 0;9 3 1;10 9 9;...
    8 0 2;7 2 2;...
    .5 .5 .5;1 1 1;...
    2 2 2;3 3 3;4 4 4;5 5 5;...
    6 6 6;7 7 7;8 8 8;9 9 9;...
    5 0 6;9 8 5;10 10 8;9 9 2;...
    3.3 3.5 3;10 0 5;10 8 0;8 10 8;...
    10 10 9;2 2 3;7 8 5;8 6 8;...
    5 0 0;1 1 4;8 5 1;9.5 9.5 10;...
    5 10 9;9 1 4;1 3 7;0 5 5;...
    10 9 4;9 2 2;4 2 2;3 2 2;...
    6 0 2;0 5 10;...
    6 0 1;0 3 8;7 5 2;2 3 2;...
    9 4 8;5 6 4;4 2 1;...
    8 3 0;5 10 5;5 5 10;...% these are not displayed in 'all'
    ];
dnams={'black','purple','blue','cyan','green',...
    'yellow','orange','red','pink','white',...
    'magenta','violet','salmon','brown','lime',...
    'turquoise','indigo','denim','flesh','xenon',...
    'emerald','amber','jade','heat','quartz',...    
    'crimson','lava',...
    'charcoal','iron',...
    'lead','tin','zinc','gray',...
    'nickel','silver','titanium','aluminium',...
    'amethyst','beige','cream','dandelion',...
    'ebony','fuchsia','gold','honeydew',...
    'ivory','jet','khaki','lilac',...
    'maroon','navy','ochre','pearl',...
    'aquamarine','ruby','sapphire','teal',...
    'mustard','vermilion','wine','onyx',...
    'burgundy','azure',...
    'carmine','cobalt','copper','opal',...
    'orchid','sage','sepia',...
    'tawny','pond','slate'...% these are not displayed in 'all'
    };
end

function [] = mostra(A,noms)

if(max(max(A))>1),A=A/255;end

[a,b]=size(A);
alt=2;%ceil(a/4)+1;
I=zeros(a,alt,b);

for ii=1:b
    
    
    I(:,:,ii)=A(:,ii)*ones(1,alt);
    
end

R=I(:,:,1);
G=I(:,:,2);
B=I(:,:,3);
clear I;

I=zeros(alt,a,3);
I(:,:,1)=R';
I(:,:,2)=G';
I(:,:,3)=B';


mg=.05;
figure(6886);clf;set(gcf,'menubar','none','name','Show Colormap','numbertitle','off');
axes('position',[mg .5+mg 1-2*mg .5-2*mg]);
imagesc((I));%axis equal;
set(gca,'box','on');
%title('low');
%xlabel('high');
set(gca,'xtick',[],'ytick',[],'box','off');
if(nargin==2)
    Noms=cell(length(noms),1);
    for ii=1:length(noms)
        Noms{ii}=noms(ii);
    end
    set(gca,'xtick',[1:length(noms)],'xticklabel',Noms);
end

axes('position',[mg 0+mg 1-2*mg .5-2*mg]);
hold on;
cc='rgbk';
for ii=1:b
    h=plot(A(:,ii)+(ii-2)*.00,cc(ii)); axis tight;
    set(h,'linewidth',2);
end
xlim([0.5,size(A,1)+.5]);ylim([-0.02,1.02])    ;grid on;
end


function [] = graella(A,noms,NOMS)
coo=1;% mostrar rgb
co=7;% columnes
if(max(max(A))>1),A=A/255;end

[a,b]=size(A);
alt=2;


B=ones(1,alt);


if(coo==1),extr=33;else;extr=0;end

fi=ceil(a/co);
ap=.6;if(coo==1),ap=.4;end
mg=.11;fac=4/co;
figure(6886);clf;
set(gcf,'menubar','none','name','Show Colormap','numbertitle','off');
aux=get(gcf,'position');
aux=set(gcf,'position',[aux(1)-(((150+extr)*co-aux(3))*.5) aux(2)+aux(4)-22*fi (150+extr)*co 22*fi]);



for kk=1:co
    I=0.94*ones(fi,alt,3);
    for ii=1:fi
        for jj=1:3
            try
                %I(fi+1-ii,1:alt,jj)=A(ii+((kk-1)*fi),jj)*B;%dalt a baix
                I(ii,1:alt,jj)=A(ii+((kk-1)*fi),jj)*B;%baix a dalt
            end
        end
    end
    
    
    mar=(mg)/co;
    %axes('position',[(kk-1+mg)/co mg/fac (ap-2*mg)/co 1-2*mg/fac]);
    axes('position',[(kk-1+mg)/co mar/fac (ap-2*mg)/co 1-2*mar/fac]);
    imagesc((I));%axis equal;
    set(gca,'box','on');
    %title('low');
    %xlabel('high');
    set(gca,'xtick',[],'ytick',[],'box','off');
    if(nargin>=2)
        Noms=cell(length(noms),1);
        Noms2=Noms;
        for ii=1:fi
            try
                %Noms{fi+1-ii}=noms(ii+((kk-1)*fi));%baix a dalt
                Noms{ii}=noms(ii+((kk-1)*fi));%dalt a baix
                if(coo==1)
                    %Noms2{ii}=['[' num2str(10*A(ii+((kk-1)*fi),1)) ',' num2str(10*A(ii+((kk-1)*fi),2)) ',' num2str(10*A(ii+((kk-1)*fi),3)) '] ' NOMS{ii+((kk-1)*fi)}];
                    Noms2{fi+1-ii}=['[' num2str(10*A(ii+((kk-1)*fi),1)) ',' num2str(10*A(ii+((kk-1)*fi),2)) ',' num2str(10*A(ii+((kk-1)*fi),3)) '] ' NOMS{ii+((kk-1)*fi)}];
                else
                    %Noms2{ii}=NOMS{ii+((kk-1)*fi)};
                    Noms2{fi+1-ii}=NOMS{ii+((kk-1)*fi)};
                end
            end
        end
        set(gca,'ytick',[1:fi]+0,'yticklabel',Noms,'TickLength',[0 0],'fontname','verdana','fontsize',8,'fontweight','bold');
        box off;
        axes('position',get(gca,'position'),'ylim',[.5,fi+.5],'color', 'none','XTick',[],'XAxisLocation', 'top','YAxisLocation', 'right','ytick',[1:fi],'yticklabel',Noms2','TickLength',[0 0],'fontname','verdana','fontsize',8,'fontweight','bold');
        for ii=1:fi-1
            h=line([0,1],.5+[ii,ii]);set(h,'color','k','linewidth',.1);
        end
    end
end
end

function [shu] = shuffle(vec)
%shuffle vector

indexos=1:length(vec);

shu=vec-vec;

for ii=1:length(vec)
    
    ind=ceil(rand*length(indexos));
    shu(ii)=vec(indexos(ind));
    indexos(ind)=[];
    
end






end


