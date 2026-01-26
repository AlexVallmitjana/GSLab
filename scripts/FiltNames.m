function [justnams,justsups,ddwv] = FiltNames()
cc=0;ddwv=cell(0);
cc=cc+1;ddwv{cc}={'Beylkin','beyl' ,{'beyl'}};
cc=cc+1;ddwv{cc}={'Coiflets','coif',{'coif1','coif2','coif3','coif4','coif5'}} ;
cc=cc+1;ddwv{cc}={'Daubechies','db',1};
cc=cc+1;ddwv{cc}={'Daub bes-loc','bl',{'bl7','bl9','bl10'}};
cc=cc+1;ddwv{cc}={'Fejer-Korovkin','fk',{'fk4','fk6','fk8','fk14','fk18','fk22'}};
cc=cc+1;ddwv{cc}={'Haar','haar',{'haar'}};
cc=cc+1;ddwv{cc}={'Han lin-phase mom','han',{'han2.3','han3.3','han4.5','han5.5',''}};
cc=cc+1;ddwv{cc}={'Morris min-bandw','mb',{'mb4.2','mb8.2','mb8.3','mb8.4','mb10.3','mb12.3','mb14.3','mb16.3','mb18.3','mb24.3','mb32.3'}}    ;
cc=cc+1;ddwv{cc}={'Symlets','sym',1};
cc=cc+1;ddwv{cc}={'Vaidyanathan','vaid',{'vaid'}};
cc=cc+1;ddwv{cc}={'BiorSplines','bior',{'bior1.1','bior1.3','bior1.5','bior2.2','bior2.4','bior2.6','bior2.8','bior3.1','bior3.3','bior3.5','bior3.7','bior3.9','bior4.4','bior5.5','bior6.8'}};
cc=cc+1;ddwv{cc}={'ReverseBior','rbio',{'rbio1.1','rbio1.3','rbio1.5','rbio2.2','rbio2.4','rbio2.6','rbio2.8','rbio3.1','rbio3.3','rbio3.5','rbio3.7','rbio3.9','rbio4.4','rbio5.5','rbio6.8'}};

    justnams=cell(0);
justsups=cell(0);
for ii=1:cc
  justnams{ii}=ddwv{ii}{1,1};
  justsups{ii}=ddwv{ii}{1,3};
end
end