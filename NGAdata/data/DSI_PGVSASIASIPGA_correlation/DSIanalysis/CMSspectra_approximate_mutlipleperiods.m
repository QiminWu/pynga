function [SA_CMSmedian,SA_CMSbeta]=CMSspectra_approximate_multipleperiods(M,R,epsilon,targetSa,targetperiod,periodrange,IMR,siteprop,faultprop)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Purpose: To compute the approximate CMS spectra fixed at multiple periods
%by using the mean M,R,epsilon values from PSHA deaggregation

%required M-files in same folder
%   SA_correlation.m

%Reference: 
%Baker, JW and Cornell, CA, 2006.  Spectral acceleration, record
%selection and epsilon.  Earthquake Engineering and Structural Dynamics.
%35: 1077-1095.
%Baker, JW.  2005.  Vector-valued Intensity Measures for probabilistic
%seismic demand analysis, PhD Thesis.  Stanford University, CA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%input data
M=6.5;
R=15;
eps=1;
targetSaavg=0.3;   %in g
targetperiod=[0.6 0.8 1.0 1.2]; %seconds

siteprop.soiltype='rock';
faultprop.faultstyle='normal';
siteprop.g=981;
siteprop.V30=300;

periodrange=0:0.05:4;
IMR=@BooreAtkinson_2007_nga;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get predicted SAavg
for i=1:length(targetperiod)
    siteprop.period=targetperiod(i);
    [SApredicted(i),sigma_SApredicted(i)]=feval(IMR,M,R,siteprop,faultprop);
end

%compute SAavg
SAavg_sum=0;
SAavg_var=0;
for i=1:length(targetperiod)
    SAavg_sum=SAavg_sum+log(SApredicted(i));
    for j=1:length(targetperiod)
        [rhoij]=SA_correlation(targetperiod(i),targetperiod(j));
        SAavg_var=SAavg_var+rhoij*sigma_SApredicted(i)*sigma_SApredicted(j);
    end
end
SAavg_median=exp(SAavg_sum/length(targetperiod));
SAavg_beta=sqrt(SAavg_var/length(targetperiod).^2);
%end of SAavg computation


%adjust epsilon value to get target Sa
epsilonmod=log(targetSaavg/SAavg_median)/SAavg_beta;

%get unconditional spectra and correlation at range of periods
for i=1:length(periodrange)
    siteprop.period=periodrange(i);
    [SA(i),sigma_SA(i)]=feval(IMR,M,R,siteprop,faultprop);
    rho_sum=0.0;
    for j=1:length(targetperiod)
        [rhoij]=SA_correlation(periodrange(i),targetperiod(j));
        rho_sum=rho_sum+rhoij*sigma_SApredicted(j);
    end
    rhoSA_avg(i)=rho_sum/(length(targetperiod)*SAavg_beta);
    %get CMS
    SA_CMSmedian(i)=exp(log(SA(i))+sigma_SA(i)*rhoSA_avg(i)*epsilonmod);
    SA_CMSbeta(i)=sigma_SA(i)*sqrt(1-rhoSA_avg(i)^2);
end

%84th and 16th percentiles CMS
SA_CMS16=exp(log(SA_CMSmedian)-SA_CMSbeta);
SA_CMS84=exp(log(SA_CMSmedian)+SA_CMSbeta);

%plotting
figure(1)
plot(periodrange,SA,'-r');
hold on
plot(periodrange,SA_CMSmedian,'b-');
plot(periodrange,SA_CMS16,'b--');
plot(periodrange,SA_CMS84,'b--');
plot(periodrange,exp(log(SA)+epsilonmod*sigma_SA),'--r');

figure(2)
plot(periodrange,rhoSA_avg)



