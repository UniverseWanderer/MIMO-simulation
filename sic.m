function [x_end]=sic(H,HH,Y,x_es,n,hDemod,hMod)
%H=h;HH=h_ch;Y=y;x=x_es;n=n;hDemod=hDemod

%% compute the inices of power1<power2 and power1>=power2
p1=squeeze(HH(1,1,:))';
p2=squeeze(HH(2,2,:))';
count1=find(p1<p2);
count2=find(p1>=p2);

%% reduce the influence of more powerful signal
x_de = demodulate(hDemod,x_es);
x=modulate(hMod,x_de);
x=reshape(kron(x,ones(2,1)),2,2,n/2);
H_ch=H;
H_ch(:,1,count1)=0;
H_ch(:,2,count2)=0;
y_ch=sum(H_ch.*x,2); 
y_ch=reshape(Y,2,1,n/2)-y_ch; 

%% get the corresponding channel to y_ch
H_co_ch=H;
H_co_ch(:,1,count2)=0;
H_co_ch(:,2,count1)=0;
H_co_ch=sum(H_co_ch,2);

%% MRC
x_1or2=zeros(1,1,n/2);
r=H_co_ch(1,1,:).*conj(H_co_ch(1,1,:))+H_co_ch(2,1,:).*conj(H_co_ch(2,1,:));
x_1or2(1,1,:)=conj(H_co_ch(1,1,:)).*y_ch(1,1,:)+conj(H_co_ch(2,1,:)).*y_ch(2,1,:);
x_1or2=x_1or2./r;

%% replace the x_1or2 with the new x_1or2
x_1or2=reshape(kron(reshape(squeeze(x_1or2),1,n/2),ones(1,2)),1,2,n/2);
x_1or2(1,2,count1)=0;
x_1or2(1,1,count2)=0;
x_1or2=reshape(x_1or2,1,n);
x_end=x_es;
count3=find(x_1or2);
x_end(count3)=0;
x_end=x_end+x_1or2;


 

