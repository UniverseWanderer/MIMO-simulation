% function [Hr]= antenna_selection(H,Delta_S_Set,type,SNR)
% function [A, B]= antenna_selction(H,Delta_S_Set,type,SNR)
% Antenna Subset Selection, choose A and B by type = MBER,MMI,LAZY
% A,B Antenna selected
% H channel matrix estimation
% Delta_S_Set exhaustive searching set of Delta_S
% type different criteria MBER=Minimum BER, MMI=Maximum Mutual Info
% SNR Signal to Noise Ritio in dB
% by Jinfeng Du
% 05-04-22

%EsN0=EbN0+10*log10(k);
%EsN0=SNR+10*log10(Tsym/Tsamp); Tsym/Tsamp是过采样率

load('H');
n=1e5;
EbN0=[0:20];
H0=zeros(8,2,n);
H0(1:2,:,:)=H(1:2:3,:,1:n);
H0(3:4,:,:)=H(1:3:4,:,1:n);
H0(5:6,:,:)=H(2:3,:,1:n);
H0(7:8,:,:)=H(2:2:4,:,1:n);
Chan_MMI=zeros(2*length(EbN0),2,n);
EYE=ones(2,2,n);
EYE(1,2,:)=0;
EYE(2,1,:)=0;
for j=1:length(EbN0)
    h_ch=ones(8,2,n);
    count_max=ones(1,n);
    count_max_index=ones(1,n);
    %% receive
    % comupte I+signal_noise*(H'*H)
    for i=1:4
    h_es=H0((2*i-1):(2*i),:,:);
    h_ch(2*i-1,1,:)=sum(h_es(:,1,:).*conj(h_es(:,1,:)),1);
    h_ch(2*i-1,2,:)=sum(conj(h_es(:,1,:)).*h_es(:,2,:),1);
    h_ch(2*i,1,:)=sum(conj(h_es(:,2,:)).*h_es(:,1,:),1);
    h_ch(2*i,2,:)=sum(h_es(:,2,:).*conj(h_es(:,2,:)),1);
    h_ch((2*i-1):(2*i),:,:)=EYE+10^(EbN0(j)/10)*h_ch((2*i-1):(2*i),:,:);
    end
    
    % comupte det(I+signal_noise*(H'*H))
    deth_ch=ones(8,2,n);
    ss=ones(4,1,n);
    for i=1:4
    ss(i,1,:)=h_ch(2*i-1,1,:).*h_ch(2*i,2,:)-h_ch(2*i-1,2,:).*h_ch(2*i,1,:);
    end
    
    ss=reshape(ss,4,n);
    count_max=max(ss);
    
    
    
    for z=1:n
        index=find(ss(:,z)==count_max(z));
        Chan_MMI((2*j-1):(2*j),:,z)=H0((2*index-1):(2*index),:,z);
    end
end
    




