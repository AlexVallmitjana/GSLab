function [] = niceplot(aux)
%call with argument to not rotate y axis
set(gcf,'color','w');
ax=gca;
set(ax,'fontname','calibri','fontsize',14,'XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off','box','off');
set(ax.YLabel,'FontWeight','normal');
if(nargin==0)
    set(ax.YLabel,'rotation',0);
end
set(gca,'linewidth',2);
set(ax.XLabel,'FontWeight','normal');
grid off;



end