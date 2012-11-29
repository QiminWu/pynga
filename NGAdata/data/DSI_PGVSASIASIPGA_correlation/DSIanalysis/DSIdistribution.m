function ASIdistribution

%purpose: to use simulation of the SA attenuation relationships in order to
%investigate the distribution of DSI based on the equations given in the
%nonliquefiable paper

%methodology: 
%1) randomly generate a set of variables for the spectral
%acceleration terms at T=0.5:0.25:5
%2) using an attenuation for a given M,R combination determine the (logrithmic) mean and
%standard deviation from attenuation relations
%3) convert to non-log forms
%4) compute DSI using trapezoidal rule 
%5) repeat using monte carlo 
%6) goodness-of-fit test

nMC=10000;
nreps=1 %20;
M=6.5;  R=30;  %magnitude and distance in km

%get attenuation relation data
g=981.;  %acc of gravity in m/s
dT=0.1;
T=2.0:dT:5;
siteprop.V30=300;  %shear wave velocity in m/s
faultprop.faultstyle='strikeslip';

for i=1:length(T)
    siteprop.period=T(i);
    [median_lnSA(i),sigma_lnSA(i,:)]=BooreAtkinson_2007_nga(M,R,siteprop,faultprop);
end
% plot(T,median_lnSA)

%get correlation values using Baker emperical expression
for i=1:length(T)
    for j=1:length(T)
        [rho(i,j)]=SA_correlation(T(i),T(j)); 
%           if i==j
%               rho(i,j)=1;
%           else
%               rho(i,j)=0;
%           end
        cov_lnSA(i,j)=rho(i,j)*sigma_lnSA(i,1)*sigma_lnSA(j,1);
    end
end
% plot(T,rho)

%compute first order moments
mu_SA=median_lnSA.*exp(0.5*sigma_lnSA(:,1)'.^2);
std_SA=mu_SA.*sqrt(exp(sigma_lnSA(:,1)'.^2)-1);
% plot(T,median_lnSA,'-b',T,median_lnSA.*exp(sigma_lnSA),'--b',T,median_lnSA.*exp(-sigma_lnSA),'--b')
% hold on
% plot(T,mu_SA,'-r',T,mu_SA+std_SA,'--r',T,mu_SA-std_SA,'--r')
%convert to Sd
omega=2*pi./T;
mu_Sd=g*mu_SA./omega.^2;
std_Sd=g*std_SA./omega.^2;
%mean
mu_DSI=dT*(0.5*(mu_Sd(1)+mu_Sd(length(T)))+sum(mu_Sd(2:length(T)-1)));
%std
var_DSI=0;
weights=dT/2*ones(1,length(T)); weights(2:length(T)-1)=2*weights(2:length(T)-1);
for i=1:length(T)
    for j=1:length(T)
        rhon(i,j)=(exp(rho(i,j)*sigma_lnSA(i,1)*sigma_lnSA(j,1))-1)/sqrt((exp(sigma_lnSA(i,1)^2)-1)*(exp(sigma_lnSA(i,1)^2)-1));
        var_DSI=var_DSI+weights(i)*weights(j)*rhon(i,j)*std_Sd(i)*std_Sd(j);
    end
end
std_DSI=sqrt(var_DSI);
%now convert back to LN form
std_lnDSI=sqrt(log((std_DSI/mu_DSI)^2+1));
mu_lnDSI=log(mu_DSI)-0.5*std_lnDSI^2;
%end of emperical approach
for j=1:nreps
        j
    for i=1:nMC
        %compute one realisation of spectral acceleration terms
        R_SA = mvnrnd(log(median_lnSA),cov_lnSA);

        %now convert the log-form to non-log form
        SA=exp(R_SA);
    %     plot(T,SA,'o',T,median_lnSA,'-r')
    %now convert to PSV
        omega=2*pi./T;
        Sd=g*SA./omega.^2;

        %compute DSI
        DSI(i)=dT*(0.5*(Sd(1)+Sd(length(T)))+sum(Sd(2:length(T)-1)));
    end

    DSIsort=sort(DSI);
    CDF=1/(nMC+1):1/(nMC+1):(1-1/(nMC+1));
    DSI_LN=logninv(CDF,mu_lnDSI,std_lnDSI);

    %compare using KS test
    moments(1:2)=[mu_lnDSI std_lnDSI];
    alpha=0.05; inputdata=DSI; outplot=0;
    [H,P,KSSTAT(j),CV]=KStest_lognormality(alpha,inputdata,outplot,moments);

    [A2a(j),A2acrit,P,alpha] = AnDartest_normal(log(inputdata),alpha);

    %compare moments
    mean(DSI);
    std(DSI);
    mu_err(j)=(mean(DSI)-mu_DSI)/mu_DSI*100;
    std_err(j)=(std(DSI)-std_DSI)/std_DSI*100;

    %plot normal and lognormal approaches
    if nreps==1
        
        figure(4)
        plot(DSIsort,CDF,'-b',DSI_LN,CDF,'-r',norminv(CDF,mu_DSI,std_DSI),CDF,'-g'); legend('raw','LN','N');
        
        %from specific mfile
%         IMR=@BooreAtkinson_2007_nga; siteprop.g=g;
%         [DSI,sigma_DSI]=Bradleyetal_2011_DSI(M,R,siteprop,faultprop,IMR);
%         hold on;
%         plot(logninv([0.01:0.01:0.99],log(DSI),sigma_DSI(1)),[0.01:0.01:0.99],'k:','LineWidth',5);
    end

end

figure(1)
cdfplot(mu_err)
hold on
cdfplot(std_err)

figure(2)
cdfplot(KSSTAT)
hold on
plot([CV CV],[0 1],'--')
[KSSTAT' A2a' mu_err' std_err']

figure(3)
cdfplot(A2a)
hold on
plot([A2acrit A2acrit],[0 1],'--')

















