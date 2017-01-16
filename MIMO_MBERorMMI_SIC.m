%% parameter setting
clear;clc
load Hr
load Chan_MMI_e5
Chan_MMI=Chan_MMI_e5;
EbN0=[0:20];
n=200000;
M=2;
k=log2(M);
m=100; omega=10; 
BER=[];
Count_radio=zeros(4,length(EbN0));

%% information source
x=randi([0 M-1],1,n);

%% compute the BER under different EbN0
for j=1:2
c=[];
c_sic=[];
Radio=[];
Radio_sic=[];

for i=1:length(EbN0)
    %% channel
    if j==1
        h=Hr(:,:,1:(n/2));
    else
        h=Chan_MMI((2*i-1):(2*i),:,:);
    end
    %% modulation
    hMod=modem.qammod(M);
    x_mod=modulate(hMod,x);
    x_mod=reshape(kron(x_mod,ones(2,1)),2,2,n/2);
    
    

    %% add noise
    noise=1/sqrt(2)*[randn(2,n/2)+j*randn(2,n/2)];
    y=squeeze(sum(x_mod.*h,2));
    y=y+10^(-EbN0(i)/20)*noise;
    %y=squeeze(sum(x_mod.*h,2));
    %SNR=EbN0(i)+10*log10(k); 
    %y(1,:)=awgn(y(1,:),SNR,'measured');
    %y(2,:)=awgn(y(2,:),SNR,'measured');

    
    %% receive
    h_es=h;
    % compute H'*H
    h_ch=ones(2,2,n/2);
    h_ch(1,1,:)=sum(h_es(:,1,:).*conj(h_es(:,1,:)),1);
    h_ch(1,2,:)=sum(conj(h_es(:,1,:)).*h_es(:,2,:),1);
    h_ch(2,1,:)=sum(conj(h_es(:,2,:)).*h_es(:,1,:),1);
    h_ch(2,2,:)=sum(h_es(:,2,:).*conj(h_es(:,2,:)),1);
    
    % comupte inv(H'*H)
    invh_ch=ones(2,2,n/2);
    ss=[];
    invh_ch(1,1,:)=h_ch(2,2,:);
    invh_ch(1,2,:)=-h_ch(2,1,:);
    invh_ch(2,1,:)=-h_ch(1,2,:);
    invh_ch(2,2,:)=h_ch(1,1,:);
    ss=h_ch(1,1,:).*h_ch(2,2,:)-h_ch(1,2,:).*h_ch(2,1,:);
    ss=kron(kron(squeeze(ss),ones(2,1)),ones(1,2))';
    ss=reshape(ss,2,2,n/2);
    invh_ch=invh_ch./ss;
    
 
    h1 =  reshape(conj(h),2,n); % H^H operation
    
    yy = kron(y,ones(1,2)); 
    yy = sum(h1.*yy,1);
    yy =  kron(reshape(yy,2,n/2),ones(1,2)); 
    x_es = sum(reshape(invh_ch,2,n).*yy,1); 
    
    hDemod=modem.qamdemod(hMod);
    x_end=sic(h,h_ch,y,x_es,n,hDemod,hMod);
    
    %demodulate
    x_des = demodulate(hDemod,x_es);
    x_des_sic=demodulate(hDemod,x_end);
    
    %% compute BER
     [number,radio] = biterr(x,x_des);
     [number_sic,radio_sic] = biterr(x,x_des_sic);
     c=[c number];
     c_ev=mean(c);
     c_sic=[c_sic number_sic];
     c_sic_ev=mean(c_sic);
     Radio=[Radio radio];
     Radio_sic=[Radio_sic radio_sic];
end
    Count_radio((2*j-1):(2*j),:)=[Radio;Radio_sic];
end




close all
figure
semilogy(EbN0,Count_radio(1,:),'mp-','LineWidth',2);
hold on
semilogy(EbN0,Count_radio(2,:),'bp-','LineWidth',2);
semilogy(EbN0,Count_radio(3,:),'rp-','LineWidth',2);
semilogy(EbN0,Count_radio(4,:),'kp-','LineWidth',2);

axis([0 25 10^-5 0.05])
grid on
legend('sim (nTx=2,nRx=2, MBER)','sim (nTx=2,nRx=2, MBER-SIC)',  'sim (nTx=2, nRx=2, MMI)','sim (nTx=2, nRx=2, MMI-SIC)');
xlabel('Average Eb/No,dB');
ylabel('Bit Error Rate');
title('BER for QAM modulation with 2x2 MIMO-MBER/MMI(SIC)');


     

