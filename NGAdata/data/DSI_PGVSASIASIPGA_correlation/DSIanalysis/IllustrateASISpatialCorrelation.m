function IllustrateASISpatialCorrelation

%written: Brendon Bradley
%         25 June 2009

%Purpose: To compute the spatial correlation of ASI based on Sa spatial
%correlation equations

%Input Variables:
%h   - The spatial seperation distance in km
%IMR - a vector giving the relationship to use to compute the Sa correlations
%      (currently only "SaSpatialCorrelation_JayaramBaker" is avaliable for
%      spatial correlations, and "SA_correlation" for the site specific
%      correlation)
%casei- see "SaSpatialCorrelation_JayaramBaker"
%bound- see "SaSpatialCorrelation_JayaramBaker"


%two cases: 1 comparison of ASI correlation with other IMs
%2: effects of M,R etc on ASI correlation

casenumber=4;

if casenumber==1
    M=7.0;
    Rjb1=40;
    siteprop.V30=300;  %shear wave velocity in m/s
    faultprop.faultstyle='strikeslip';
    IMR=@BooreAtkinson_2007_nga;
    h=0:1:50;
    Rjb2=sqrt(Rjb1^2+h.^2);

    casei=1;
    bound=0;

    for i=1:length(h)
        %get distribution of ASI at sites 1 and 2
        [ASI1,sigma_ASI1]=Bradleyetal_2008_ASI(M,Rjb1,siteprop,faultprop,IMR);
        [ASI2,sigma_ASI2]=Bradleyetal_2008_ASI(M,Rjb2(i),siteprop,faultprop,IMR);
        ASI_mean1=ASI1*exp(0.5*sigma_ASI1^2);
        ASI_mean2=ASI2*exp(0.5*sigma_ASI2^2);
        sigma_ASI_normal1=ASI_mean1*sqrt(exp(sigma_ASI1^2)-1);
        sigma_ASI_normal2=ASI_mean2*sqrt(exp(sigma_ASI2^2)-1);
        %now get distributions of Sa at sites 1 and 2
        dT=0.05;
        T=0.1:dT:0.5;
        %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
        weight=dT*ones(1,length(T)); 
        weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

        for j=1:length(T)
            siteprop.period=T(j);
            [SA1(j),sigma_SA1(j)]=feval(IMR,M,Rjb1,siteprop,faultprop);
            [SA2(j),sigma_SA2(j)]=feval(IMR,M,Rjb2(i),siteprop,faultprop);

            SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
            SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
            %convert lognormal standard deviation in SA to normal 
            sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
            sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
        end

        %now get correlation between all of the Sa terms for computing the
        %correlation in ASI
        Cov_ASInm=0;
        for j=1:length(T)
            for k=1:length(T)
                geomean_period=sqrt(T(j)*T(k));
                [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei,bound);
                [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                Cov_ASInm=Cov_ASInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SA_normal1(j)*sigma_SA_normal2(k);
            end
        end
        rho_ASInm(i)=Cov_ASInm/(sigma_ASI_normal1*sigma_ASI_normal2);
    end

    fig1=figure(1); axes('Parent',fig1,'FontSize',14);
    plot(h,rho_ASInm,'LineWidth',3,'Color',[0.749 0.749 0]); hold on; ylim([0 1]);
    xlabel('Separation distance, h (km)','FontSize',14); ylabel('Correlation coefficient, \rho','FontSize',14);
    %also plot the correlation for some Sa periods
    [rho_PGA]=SaSpatialCorrelation_JayaramBaker(h,[0],casei,bound);
    [rho_Sa05]=SaSpatialCorrelation_JayaramBaker(h,[0.5],casei,bound);
    [rho_Sa20]=SaSpatialCorrelation_JayaramBaker(h,[1.5],casei,bound);
    plot(h,rho_PGA,'LineWidth',3,'Color',[0.5 1 0],'LineStyle','-.');
    plot(h,rho_Sa05,'LineWidth',3,'Color',[1 0 0]);
    plot(h,rho_Sa20,'LineWidth',3,'Color',[0 0 0],'LineStyle','--');

    %also get correlation for SI
    for i=1:length(h)
        %get distribution of SI at sites 1 and 2
        g=981.;
        siteprop.g=g;
        [SI1,sigma_SI1]=Bradleyetal_2008_SI(M,Rjb1,siteprop,faultprop,IMR);
        [SI2,sigma_SI2]=Bradleyetal_2008_SI(M,Rjb2(i),siteprop,faultprop,IMR);
        SI_mean1=SI1*exp(0.5*sigma_SI1^2);
        SI_mean2=SI2*exp(0.5*sigma_SI2^2);
        sigma_SI_normal1=SI_mean1*sqrt(exp(sigma_SI1^2)-1);
        sigma_SI_normal2=SI_mean2*sqrt(exp(sigma_SI2^2)-1);
        %now get distributions of Sa at sites 1 and 2
        dT=0.1;
        T=0.1:dT:2.5;
        %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
        weight=dT*ones(1,length(T)); 
        weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

        for j=1:length(T)
            siteprop.period=T(j);
            [SA1(j),sigma_SA1(j)]=feval(IMR,M,Rjb1,siteprop,faultprop);
            [SA2(j),sigma_SA2(j)]=feval(IMR,M,Rjb2(i),siteprop,faultprop);

            SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
            SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
            SV1(j)=(T(j)/(2*pi))*SA_mean1(j)*g;
            SV2(j)=(T(j)/(2*pi))*SA_mean2(j)*g;
            %convert lognormal standard deviation in SA to normal 
            sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
            sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
            sigma_SV_normal1(j)=(T(j)/(2*pi))*sigma_SA_normal1(j)*g;
            sigma_SV_normal2(j)=(T(j)/(2*pi))*sigma_SA_normal2(j)*g;
        end

        %now get correlation between all of the Sa terms for computing the
        %correlation in SI
        Cov_SInm=0;
        for j=1:length(T)
            for k=1:length(T)
                geomean_period=sqrt(T(j)*T(k));
                [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei,bound);
                [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                Cov_SInm=Cov_SInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SV_normal1(j)*sigma_SV_normal2(k);
            end
        end
        rho_SInm(i)=Cov_SInm/(sigma_SI_normal1*sigma_SI_normal2);
    end    
    plot(h,rho_SInm,'LineWidth',3,'Color',[0 0 1],'LineStyle',':');  
    legend('ASI','PGA','Sa(0.5s)','Sa(1.5s)','SI');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%case2: look at M,R effect of correlation of ASI.
if casenumber==2
    M=[8.0 5.0];
    Rjb1=[100 10];
    siteprop.V30=300;  %shear wave velocity in m/s
    faultprop.faultstyle='strikeslip';
    IMR=@BooreAtkinson_2007_nga;
    h=0:1:50;


    casei=1;
    bound=0;

    for m=1:2
        Rjb2=sqrt(Rjb1(m)^2+h.^2);
        for i=1:length(h)
            %get distribution of ASI at sites 1 and 2
            [ASI1,sigma_ASI1]=Bradleyetal_2008_ASI(M(m),Rjb1(m),siteprop,faultprop,IMR);
            [ASI2,sigma_ASI2]=Bradleyetal_2008_ASI(M(m),Rjb2(i),siteprop,faultprop,IMR);
            ASI_mean1=ASI1*exp(0.5*sigma_ASI1^2);
            ASI_mean2=ASI2*exp(0.5*sigma_ASI2^2);
            sigma_ASI_normal1=ASI_mean1*sqrt(exp(sigma_ASI1^2)-1);
            sigma_ASI_normal2=ASI_mean2*sqrt(exp(sigma_ASI2^2)-1);
            %now get distributions of Sa at sites 1 and 2
            dT=0.05;
            T=0.1:dT:0.5;
            %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
            weight=dT*ones(1,length(T)); 
            weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

            for j=1:length(T)
                siteprop.period=T(j);
                [SA1(j),sigma_SA1(j)]=feval(IMR,M(m),Rjb1(m),siteprop,faultprop);
                [SA2(j),sigma_SA2(j)]=feval(IMR,M(m),Rjb2(i),siteprop,faultprop);

                SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
                SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
                %convert lognormal standard deviation in SA to normal 
                sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
                sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
            end

            %now get correlation between all of the Sa terms for computing the
            %correlation in ASI
            Cov_ASInm=0;
            for j=1:length(T)
                for k=1:length(T)
                    geomean_period=sqrt(T(j)*T(k));
                    [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei,bound);
                    [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                    rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                    rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                    Cov_ASInm=Cov_ASInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SA_normal1(j)*sigma_SA_normal2(k);
                end
            end
            rho_ASInm(i,m)=Cov_ASInm/(sigma_ASI_normal1*sigma_ASI_normal2);
        end
    end

    fig2=figure(2); axes('Parent',fig2,'FontSize',14);
    plot(h,rho_ASInm(:,1),'LineWidth',3,'Color',[0.749 0.749 0]); hold on; ylim([0 1]);
    plot(h,rho_ASInm(:,2),'LineWidth',3,'Color',[0.749 0 0]); hold on; ylim([0 1]);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%case3: Comparison of effects of casei value.
if casenumber==3
    M=7;
    Rjb1=40;
    siteprop.V30=300;  %shear wave velocity in m/s
    faultprop.faultstyle='strikeslip';
    IMR=@BooreAtkinson_2007_nga;
    h=0:1:50;
    Rjb2=sqrt(Rjb1^2+h.^2);


    casei=[1 2];
    bound=0;

    for m=1:2
        for i=1:length(h)
            %get distribution of ASI at sites 1 and 2
            [ASI1,sigma_ASI1]=Bradleyetal_2008_ASI(M,Rjb1,siteprop,faultprop,IMR);
            [ASI2,sigma_ASI2]=Bradleyetal_2008_ASI(M,Rjb2(i),siteprop,faultprop,IMR);
            ASI_mean1=ASI1*exp(0.5*sigma_ASI1^2);
            ASI_mean2=ASI2*exp(0.5*sigma_ASI2^2);
            sigma_ASI_normal1=ASI_mean1*sqrt(exp(sigma_ASI1^2)-1);
            sigma_ASI_normal2=ASI_mean2*sqrt(exp(sigma_ASI2^2)-1);
            %now get distributions of Sa at sites 1 and 2
            dT=0.05;
            T=0.1:dT:0.5;
            %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
            weight=dT*ones(1,length(T)); 
            weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

            for j=1:length(T)
                siteprop.period=T(j);
                [SA1(j),sigma_SA1(j)]=feval(IMR,M,Rjb1,siteprop,faultprop);
                [SA2(j),sigma_SA2(j)]=feval(IMR,M,Rjb2(i),siteprop,faultprop);

                SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
                SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
                %convert lognormal standard deviation in SA to normal 
                sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
                sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
            end

            %now get correlation between all of the Sa terms for computing the
            %correlation in ASI
            Cov_ASInm=0;
            for j=1:length(T)
                for k=1:length(T)
                    geomean_period=sqrt(T(j)*T(k));
                    [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei(m),bound);
                    [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                    rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                    rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                    Cov_ASInm=Cov_ASInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SA_normal1(j)*sigma_SA_normal2(k);
                end
            end
            rho_ASInm(i,m)=Cov_ASInm/(sigma_ASI_normal1*sigma_ASI_normal2);
        end
    end

    fig2=figure(2); axes('Parent',fig2,'FontSize',14);
    plot(h,rho_ASInm(:,1),'LineWidth',4,'Color',[0.749 0.749 0]); hold on; ylim([0 1]);
    plot(h,rho_ASInm(:,2),'LineWidth',4,'Color',[0.749 0.749 0],'LineStyle','--'); hold on; ylim([0 1]);
    %also plot the correlation for some Sa periods
    [rho_PGA_case1]=SaSpatialCorrelation_JayaramBaker(h,[0],1,bound);
    [rho_PGA_case2]=SaSpatialCorrelation_JayaramBaker(h,[0],2,bound);
    [rho_Sa10]=SaSpatialCorrelation_JayaramBaker(h,[1.0],1,bound);
    plot(h,rho_PGA_case1,'LineWidth',3,'Color',[0 0.498 0],'LineStyle','-');
    plot(h,rho_PGA_case2,'LineWidth',3,'Color',[0 0.498 0],'LineStyle','--');
    plot(h,rho_Sa10,'LineWidth',3,'Color',[0 0 0],'LineStyle','-');
    legend('ASI - case 1','ASI - case 2','PGA - case 1','PGA - case 2','Sa(1.0s)');
    xlabel('Separation distance, h (km)','FontSize',14); ylabel('Correlation coefficient, \rho','FontSize',14);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if casenumber==4
    M=7.0;
    Rjb1=40;
    siteprop.V30=300;  %shear wave velocity in m/s
    faultprop.faultstyle='strikeslip';
    IMR=@BooreAtkinson_2007_nga;
    h=0:1:50;
    Rjb2=sqrt(Rjb1^2+h.^2);

    casei=[1 2];
    bound=0;
    for m=1:2
        for i=1:length(h)
            %get distribution of ASI at sites 1 and 2
            [ASI1,sigma_ASI1]=Bradleyetal_2008_ASI(M,Rjb1,siteprop,faultprop,IMR);
            [ASI2,sigma_ASI2]=Bradleyetal_2008_ASI(M,Rjb2(i),siteprop,faultprop,IMR);
            ASI_mean1=ASI1*exp(0.5*sigma_ASI1^2);
            ASI_mean2=ASI2*exp(0.5*sigma_ASI2^2);
            sigma_ASI_normal1=ASI_mean1*sqrt(exp(sigma_ASI1^2)-1);
            sigma_ASI_normal2=ASI_mean2*sqrt(exp(sigma_ASI2^2)-1);
            %now get distributions of Sa at sites 1 and 2
            dT=0.05;
            T=0.1:dT:0.5;
            %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
            weight=dT*ones(1,length(T)); 
            weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

            for j=1:length(T)
                siteprop.period=T(j);
                [SA1(j),sigma_SA1(j)]=feval(IMR,M,Rjb1,siteprop,faultprop);
                [SA2(j),sigma_SA2(j)]=feval(IMR,M,Rjb2(i),siteprop,faultprop);

                SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
                SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
                %convert lognormal standard deviation in SA to normal 
                sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
                sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
            end

            %now get correlation between all of the Sa terms for computing the
            %correlation in ASI
            Cov_ASInm=0;
            for j=1:length(T)
                for k=1:length(T)
                    geomean_period=sqrt(T(j)*T(k));
                    [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei(m),bound);
                    [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                    rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                    rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                    Cov_ASInm=Cov_ASInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SA_normal1(j)*sigma_SA_normal2(k);
                end
            end
            rho_ASInm(i,m)=Cov_ASInm/(sigma_ASI_normal1*sigma_ASI_normal2);
        end
    end

    %also get correlation for SI
    for m=1:2
        for i=1:length(h)
            %get distribution of SI at sites 1 and 2
            g=981.;
            siteprop.g=g;
            [SI1,sigma_SI1]=Bradleyetal_2008_SI(M,Rjb1,siteprop,faultprop,IMR);
            [SI2,sigma_SI2]=Bradleyetal_2008_SI(M,Rjb2(i),siteprop,faultprop,IMR);
            SI_mean1=SI1*exp(0.5*sigma_SI1^2);
            SI_mean2=SI2*exp(0.5*sigma_SI2^2);
            sigma_SI_normal1=SI_mean1*sqrt(exp(sigma_SI1^2)-1);
            sigma_SI_normal2=SI_mean2*sqrt(exp(sigma_SI2^2)-1);
            %now get distributions of Sa at sites 1 and 2
            dT=0.1;
            T=0.1:dT:2.5;
            %allocate integration weights for trapz rule (dT/2 for first and last, dT otherwise)
            weight=dT*ones(1,length(T)); 
            weight(1)=weight(1)/2; weight(length(T))=weight(length(T))/2;

            for j=1:length(T)
                siteprop.period=T(j);
                [SA1(j),sigma_SA1(j)]=feval(IMR,M,Rjb1,siteprop,faultprop);
                [SA2(j),sigma_SA2(j)]=feval(IMR,M,Rjb2(i),siteprop,faultprop);

                SA_mean1(j)=SA1(j)*exp(0.5*sigma_SA1(j)^2);
                SA_mean2(j)=SA2(j)*exp(0.5*sigma_SA2(j)^2);
                SV1(j)=(T(j)/(2*pi))*SA_mean1(j)*g;
                SV2(j)=(T(j)/(2*pi))*SA_mean2(j)*g;
                %convert lognormal standard deviation in SA to normal 
                sigma_SA_normal1(j)=SA_mean1(j)*sqrt(exp(sigma_SA1(j)^2)-1);
                sigma_SA_normal2(j)=SA_mean2(j)*sqrt(exp(sigma_SA2(j)^2)-1);
                sigma_SV_normal1(j)=(T(j)/(2*pi))*sigma_SA_normal1(j)*g;
                sigma_SV_normal2(j)=(T(j)/(2*pi))*sigma_SA_normal2(j)*g;
            end

            %now get correlation between all of the Sa terms for computing the
            %correlation in SI
            Cov_SInm=0;
            for j=1:length(T)
                for k=1:length(T)
                    geomean_period=sqrt(T(j)*T(k));
                    [rho_lnSa_nm]=SaSpatialCorrelation_JayaramBaker(h(i),geomean_period,casei(m),bound);
                    [rho_lnSa_ij]=SA_correlation(T(j),T(k));
                    rho_lnSa_injm=rho_lnSa_nm*rho_lnSa_ij;
                    rho_Sa_injm(j,k)=(exp(rho_lnSa_injm*sigma_SA1(j)*sigma_SA2(k))-1)/(sqrt(exp(sigma_SA1(j)^2)-1)*sqrt(exp(sigma_SA2(k)^2)-1));
                    Cov_SInm=Cov_SInm+weight(j)*weight(k)*rho_Sa_injm(j,k)*sigma_SV_normal1(j)*sigma_SV_normal2(k);
                end
            end
            rho_SInm(i,m)=Cov_SInm/(sigma_SI_normal1*sigma_SI_normal2);
        end    
    end
        fig1=figure(1); axes('Parent',fig1,'FontSize',14);
    plot(h,rho_ASInm(:,1),'LineWidth',3,'Color',[0.749 0.749 0]); hold on; ylim([0 1]);
    plot(h,rho_SInm(:,1),'LineWidth',3,'Color',[0 0 1],'LineStyle',':');  
    b=[12.2 32.5 24.5 22.5];
    plot(h,exp(-3*h./b(1)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle','--'); 
    plot(h,rho_ASInm(:,2),'LineWidth',3,'Color',[0.749 0.749 0]); hold on; ylim([0 1]);
    plot(h,rho_SInm(:,2),'LineWidth',3,'Color',[0 0 1],'LineStyle',':'); 
    plot(h,exp(-3*h./b(2)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle','--');
    plot(h,exp(-3*h./b(3)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle','--');
    plot(h,exp(-3*h./b(4)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle','--');
    xlabel('Separation distance, h (km)','FontSize',14); ylabel('Correlation coefficient, \rho','FontSize',14);

    
    legend('ASI','SI','Approx');
end


end