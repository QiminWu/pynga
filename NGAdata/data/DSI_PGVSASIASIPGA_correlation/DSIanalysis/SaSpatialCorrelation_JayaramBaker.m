function [rho]=SaSpatialCorrelation_JayaramBaker(h,T,casei,bound)

%written: Brendon Bradley
%         25 June 2009

%Purpose: To provide the empirical equations developed by Jayaram and Baker
%(2009) for predicting the spatial correlation of spectral acceleration
%ordinates of period T at a seperation distance of h (in km).

%Reference: Jayaram N, Baker JW.  Correlation model for spatially
%distributed ground motion intensities.  Earthquake Engineering and
%Structural Dynamics (in press) DOI: 10.1002/eqe.922

%Input variables:
%h      -   The spatial seperation distance (in km) of the two locations were the
%           correlation in ground motion is desired
%T      -   The vibration period of interest
%casei  -   The case number. 
%           Case 1: If the Vs30 values do not show or are not expected to
%           show clustering (i.e. the geological condition of the soil
%           varies widely over the region
%           Case 2: If the Vs30 values show or are expected to show
%           clustering 
%bound  -   Whether to consider the proposed relation (==0) of Jayaram and Baker
%           Or to consider an upper (==1) of lower bound (==-1)

%Output Variables:
%rho    -   The correlation desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Code

if nargin<3
    casei=1;
end
if nargin<4
    bound=0;
end

%Determine equation based on period
if T<1
    if casei==1
        if bound==0
            b=8.5+17.2*T;
        elseif bound==1
            b=8.5+17.2*T+10;
        elseif bound==-1
            b=8.5+17.2*T-5;
        end
    elseif casei==2
        if bound==0
            b=40.7-15*T;
        elseif bound==1
            b=40.7-15*T+10;
        elseif bound==-1
            b=40.7-15*T-5;
        end
    else
        disp('Error: Case number is incorrect');
    end
elseif T>=1
    if bound==0
        b=22+3.7*T;
    elseif bound==1
        b=22+3.7*T+10;
    elseif bound==-1
        b=22+3.7*T-5;
    end
end

%now compute correlation given range
rho=exp(-3*h/b);
%End of function SaSpatialCorrelation_JayaramBaker
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%