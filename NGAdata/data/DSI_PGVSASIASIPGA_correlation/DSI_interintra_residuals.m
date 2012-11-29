function DSI_interintra_residuals
clc
%Brendon Bradley 10 Aug 2010

%Purpose: To look at the empirical distribution of the intra and inter-
%event residuals 
nboot=100;

%get the observational data
data=observedIMintensities;
EQID=data(:,2);
%spectral periods to consider
T=[0.01 0.02 0.03 0.04 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1.0 1.5 2 3 4 5 7.5 10];

h_wait=waitbar(0,'Running..');
for i=1:length(data)
    waitbar(i/length(data));
    
    %get Metadata
    rec_num(i)=data(i,1);   EQ_num(i)=data(i,2);
    M=data(i,3);    faultprop.dip=data(i,4);  faultprop.AS=0;
    faultprop.rake=data(i,5);    mech=data(i,6);
    faultprop.Ztor=data(i,11); 
    %use Wells and Coppersmith 'All' to get rup width given Mw
    faultprop.W=10^(-1.01+0.32*M);
    if mech==0
        faultprop.faultstyle='strikeslip';
    elseif mech==1
        faultprop.faultstyle='normal';
    elseif mech==2
        faultprop.faultstyle='reverse';
    else
        faultprop.faultstyle='other';
    end
    
    Rjb=data(i,14); 
    Rrup=data(i,15);     siteprop.Rjb=Rjb; siteprop.Rx=Rjb;
    siteprop.V30=data(i,16); siteprop.V30measured=0; siteprop.Z1pt0=-1; siteprop.Zvs=-1;
    siteprop.orientation='average'; siteprop.g=981;
    
    %Intensity measures
    
    %     ------------DSI----------------
    %get the predicted value of DSI using BA08
    IMR=@BooreAtkinson_2007_nga;
    [DSI_BA08(i),sigma_DSI_BA08(i,1:3)]=Bradleyetal_2011_DSI(M,Rjb,siteprop,faultprop,IMR);
    %get the predicted value using CY08
    IMR=@ChiouYoungs_2008_nga;
    [DSI_CY08(i),sigma_DSI_CY08(i,1:3)]=Bradleyetal_2011_DSI(M,Rrup,siteprop,faultprop,IMR);
    %get the predicted value using CB08
    IMR=@CampbellBozorgina_2007_nga;
    [DSI_CB08(i),sigma_DSI_CB08(i,1:3)]=Bradleyetal_2011_DSI(M,Rrup,siteprop,faultprop,IMR);
    %get the predicted value using AS08
    IMR=@AbrahamsonSilva_2008_nga;
    [DSI_AS08(i),sigma_DSI_AS08(i,1:3)]=Bradleyetal_2011_DSI(M,Rrup,siteprop,faultprop,IMR);
    %compute DSI for the GM record
    Sa_forDSI=data(i,36:39); T_forDSI=[2 3 4 5];
    Sd_forDSI=(T_forDSI/(2*pi)).^2.*Sa_forDSI*siteprop.g;
    DSI_observed(i)=trapz(T_forDSI,Sd_forDSI);    
    
    freq_min=data(i,17);
    T_max=1/freq_min;
        if T_max>=5
            %compute zlnDSI
            z_lnDSI_BA08(i)=(log(DSI_observed(i))-log(DSI_BA08(i)))/sigma_DSI_BA08(i,1);
            z_lnDSI_CY08(i)=(log(DSI_observed(i))-log(DSI_CY08(i)))/sigma_DSI_CY08(i,1);
            z_lnDSI_CB08(i)=(log(DSI_observed(i))-log(DSI_CB08(i)))/sigma_DSI_CB08(i,1);
            z_lnDSI_AS08(i)=(log(DSI_observed(i))-log(DSI_AS08(i)))/sigma_DSI_AS08(i,1);
        else
            z_lnDSI_BA08(i)=-100;
            z_lnDSI_CY08(i)=-100;
            z_lnDSI_CB08(i)=-100;
            z_lnDSI_AS08(i)=-100;
        end
    

 
end

%%%%%%%%%%%%%%%%%%%%%%end of computations %%%%%%%%%%%%%%%%%%%%


%4) DSI inter intra residuals 
%need to check if each residual is not -100 indicating above fmin
k=0;
for j=1:length(z_lnDSI_BA08)  %will be same for both BA08 and CY08 so dont need to check twice
    if z_lnDSI_BA08(j)~=-100
        k=k+1;

        EQID_ok(k)=EQID(j);
        z_lnDSI_BA08_ok(k)=z_lnDSI_BA08(j);
        sigma_DSI_BA08_ok(k,1:3)=sigma_DSI_BA08(j,1:3);
        z_lnDSI_CY08_ok(k)=z_lnDSI_CY08(j);
        sigma_DSI_CY08_ok(k,1:3)=sigma_DSI_CY08(j,1:3);
        z_lnDSI_CB08_ok(k)=z_lnDSI_CB08(j);
        sigma_DSI_CB08_ok(k,1:3)=sigma_DSI_CB08(j,1:3);
        z_lnDSI_AS08_ok(k)=z_lnDSI_AS08(j);
        sigma_DSI_AS08_ok(k,1:3)=sigma_DSI_AS08(j,1:3);
    end
end
alleta=0;
[eta_lnDSI_BA08_ok,eps_lnDSI_BA08_ok]=get_interintraeventterms(z_lnDSI_BA08_ok,EQID_ok,sigma_DSI_BA08_ok(:,1)',sigma_DSI_BA08_ok(:,2)',sigma_DSI_BA08_ok(:,3)',alleta);
[eta_lnDSI_CY08_ok,eps_lnDSI_CY08_ok]=get_interintraeventterms(z_lnDSI_CY08_ok,EQID_ok,sigma_DSI_CY08_ok(:,1)',sigma_DSI_CY08_ok(:,2)',sigma_DSI_CY08_ok(:,3)',alleta);
[eta_lnDSI_CB08_ok,eps_lnDSI_CB08_ok]=get_interintraeventterms(z_lnDSI_CB08_ok,EQID_ok,sigma_DSI_CB08_ok(:,1)',sigma_DSI_CB08_ok(:,2)',sigma_DSI_CB08_ok(:,3)',alleta);
[eta_lnDSI_AS08_ok,eps_lnDSI_AS08_ok]=get_interintraeventterms(z_lnDSI_AS08_ok,EQID_ok,sigma_DSI_AS08_ok(:,1)',sigma_DSI_AS08_ok(:,2)',sigma_DSI_AS08_ok(:,3)',alleta);

%now plot against std normal distribution
%plot CDF of residual_inter
alpha=0.05;
N=length(eta_lnDSI_BA08_ok);
ecdf=1/(N+1):1/(N+1):N/(N+1);
[H,P,KSSTAT,CV] = kstest(eta_lnDSI_BA08_ok,[sort(eta_lnDSI_BA08_ok') ecdf'],alpha); %just used to get CV nothing else

fig2=figure(2);
axes('Parent',fig2,'FontSize',14);
h1=cdfplot(eta_lnDSI_BA08_ok); hold on; set(h1,'Color',[1 0 0]);
cdf=0.001:0.001:0.999;

plot(norminv(cdf,0,1),cdf,'LineWidth',3,'Color',[0.5 0.5 0.5],'LineStyle','-');
plot(norminv(cdf,0,1),cdf+CV,'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--');
plot(norminv(cdf,0,1),cdf-CV,'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--');
h1=cdfplot(eta_lnDSI_CY08_ok); set(h1,'Color',[0 1 0]);
h1=cdfplot(eta_lnDSI_CB08_ok); set(h1,'Color',[0 0 1]);
h1=cdfplot(eta_lnDSI_AS08_ok); set(h1,'Color',[1 1 1]);
% cdfplot(residual_EQinter);
xlim([-3 3]); ylim([0 1]); title('inter-event residuals');
legend('Empirical','Theoretical','KS bounds','Location','SouthEast');

%plot CDF of residual_intra
alpha=0.05;
N=length(eps_lnDSI_BA08_ok);
ecdf=1/(N+1):1/(N+1):N/(N+1);
[H,P,KSSTAT,CV] = kstest(eps_lnDSI_BA08_ok,[sort(eps_lnDSI_BA08_ok') ecdf'],alpha); %just used to get CV nothing else

fig3=figure(3);
axes('Parent',fig3,'FontSize',14);
h1=cdfplot(eps_lnDSI_BA08_ok); hold on; set(h1,'Color',[1 0 0]);
cdf=0.001:0.001:0.999;
plot(norminv(cdf,0,1),cdf,'LineWidth',3,'Color',[0.5 0.5 0.5],'LineStyle','-');
plot(norminv(cdf,0,1),cdf+CV,'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--');
plot(norminv(cdf,0,1),cdf-CV,'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--');
h1=cdfplot(eps_lnDSI_CY08_ok); set(h1,'Color',[0 1 0]);
h1=cdfplot(eps_lnDSI_CB08_ok); set(h1,'Color',[0 0 1]);
h1=cdfplot(eps_lnDSI_AS08_ok); set(h1,'Color',[1 1 1]);
% cdfplot(residual_intra);
xlim([-3 3]); ylim([0 1]); title('intra-event residuals');
legend('Empirical','Theoretical','KS bounds','Location','SouthEast');

show()
