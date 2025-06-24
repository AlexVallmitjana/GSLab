function [coloret] = colorPicker2(opt,pos,sat)
% opt = 0 for free picking an RGB trio
% opt = 1 for free picking and get closest superjet code
% opt = 1.1 for free picking displayin closest superjet code
% opt = 2 for discretised colors and get a code (sat is ignored)
% pos is a 4 value array to set window position and size
% sat is a flag to pick only saturated colors (1 yes, 0 no default)
if(nargin==0),opt=0;end
if(nargin<3)||isempty(sat)
    sat=0;
end
if(opt==2),sat=0;end
mgf=[0 0];
figure(868);set(868,'MenuBar','none','Name','ColorGrid','NumberTitle','off','pointer','hand');
if(nargin<2)||isempty(pos)
    pos=get(868,'Position');
    pos(3:4)=[300 300];
    if(sat==1),pos(4)=100;end
end
set(868,'Position',pos);
if(opt<2)

    % N=256;
    if(exist('colpick.mat','file')==0)
        generate();
    end
    load('colpick.mat','Ipick','Icode','Icrop');
    if(sat==1)
        Ipick=Ipick(round(size(Ipick,1)/2),:,:);
        Icrop=Icrop(round(size(Icrop,1)/2),:,:);
        Icode=Icode(round(size(Icode,1)/2),:,:);
    end
    if(opt==1.1)
        h=imagesc(Icrop);set(h,'hittest','off');
    else
        h=imagesc(Ipick);set(h,'hittest','off');
    end
    set(gca,'position',[mgf(1) mgf(2) 1-mgf(1) 1-mgf(2)],'xtick',[],'ytick',[]);

    coloret=[];
    w = waitforbuttonpress;
    aux=get(gca,'currentpoint');
    aux=aux(1,[2,1]);
    if(aux(1)>size(Ipick,1)),aux(1)=size(Ipick,1);end
    if(opt==0)
        coloret=permute(Ipick(ceil(aux(1)),ceil(aux(2)),:),[1 3 2]);
    else
        coloret=Icode(ceil(aux(1)),ceil(aux(2)));
    end

else% discret

    sz=[15 30];
    sp=[3 3];
    bgcol=[.9 .9 .9];
    mg=[0 0];
    % codes={'k012JX3E4;','TtgljK_nMe','vAuibZ.SdN','rhVRz Y,W[','ayDUGo-OfB','ICxqL:pmFs','cQH56789Pw'};
    codes={'k012JX3E4;','56789PwICx','cQHqL:pmFs','vAuibZ.SdN','tgljK_nMTe','yDUGofB-Oa','rhVRz Y,W['};
    fil=numel(codes{1});
    col=numel(codes);
    I=zeros(sp(1)+(sz(1)+sp(1)+2*mg(1))*fil,sp(2)+(sz(2)+sp(2)+2*mg(2))*col,3);
    for cc=1:3
        I(:,:,cc)=bgcol(cc);
    end


    for ii=1:fil
        for jj=1:col
            aux=[0 0 0];
            rgy=(ii-1)*(sp(1)+2*mg(1)+sz(1))+sp(1):ii*(sp(1)+2*mg(1)+sz(1));
            rgx=(jj-1)*(sp(2)+2*mg(2)+sz(2))+sp(2):jj*(sp(2)+2*mg(2)+sz(2));
            for cc=1:3
                I(rgy,rgx,cc)=aux(cc);
            end
            aux=superjet(1,codes{jj}(ii));
            rgy=(ii-1)*(sp(1)+2*mg(1)+sz(1))+sp(1)+mg(1):ii*(sp(1)+2*mg(1)+sz(1))-mg(1);
            rgx=(jj-1)*(sp(2)+2*mg(2)+sz(2))+sp(2)+mg(2):jj*(sp(2)+2*mg(2)+sz(2))-mg(2);
            for cc=1:3
                I(rgy,rgx,cc)=aux(cc);
            end
        end
    end


    h=imagesc(I);
    set(gca,'position',[mgf(1) mgf(2) 1-mgf(1) 1-mgf(2)],'xtick',[],'ytick',[]);
    set(h,'hittest','off');
    coloret=[];
    w = waitforbuttonpress;
    aux=get(gca,'currentpoint');
    aux=aux(1,[2,1]);

    aux=ceil(aux./(sz+2*mg+sp));
    coloret=codes{aux(2)}(aux(1));
end

close(868);

end


function [] = generate()
N=256;
cm=superjet(N,'kvbcgyormw');
cm=permute(cm,[3 1 2]);

% cm=cm(end:-1:1,:,:);
I=repmat(cm,[N 1 1]);
facs=linspace(0,1,ceil(N/2));
% facs=sqrt(facs);
for ii=1:floor(N/2)
    I(ii,:,:)=I(ii,:,:).*sqrt(facs(ii));
end
facs=[facs,facs];
for ii=floor(N/2)+1:N
    I(ii,:,:)=I(ii,:,:)+(1-I(ii,:,:))*facs(ii);
end
I=I(N:-1:1,:,:);

% imwrite(I,'colpick.png');

I2=zeros(N,N);
I3=zeros(N,N,3);
I4='';
% figure(1),imagesc(I)
I=permute(I,[1 3 2]);

for ii=1:N
    for jj=1:N
        [cod,q]=color2code(I(ii,:,jj));
        I2(ii,jj)=q;
        I3(ii,jj,:)=permute(superjet(1,cod),[1 3 2]);
        I4(ii,jj)=cod;
    end
end
% figure,imagesc(I2)
% figure(2),imagesc(I3)

I=permute(I,[1 3 2]);
Ipick=I;
Icrop=I3;
Icode=I4;
save('colpick.mat','Ipick','Icrop','Icode');

vec=zeros(max(I2(:)),1);
for ii=1:max(I2(:))
    vec(ii)=numel(find(I2==ii));
end

% figure(3);plot(sort(vec))

if(0)% show abundance

    [vec,ord]=sort(vec,'descend');



    cc='kubcgyorpwmvsnltidfxeajhqz 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ,.-;:_[]';% index del diccionari
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
        9 4 8;5 6 4;4 2 1;8 3 0;...
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
        'orchid','sage','sepia','tawny',...
        };


    clc
    for ii=1:numel(vec)
        ensenya([cc(ord(ii)) ' - ' num2str(vec(ii))  ],cc(ord(ii)));
    end
end
end