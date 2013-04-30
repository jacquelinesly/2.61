function [x_CO_wet, x_HC_wet, x_CO2_wet, x_H2_wet, m_f, fuelFraction] = patrickWetCode(NDIR_CO, NDIR_HC, NDIR_CO2)

inj1dur = 5.78; %% value from lab 
C = [0.00,  0.0014615896,  -0.0008128021];
HCratio = 1.85;
m_f = C(1)*(inj1dur)^2 + C(2)*(inj1dur) + C(3) ;   % inj_PW in [millisec], mf in [g/(cycle*sqrt(deltaP)]
% the delta p in the calibration is the pressure drop across the injector
% convert g/s 

%-------------- Calculate Water Concentration in Exhaust -----------------%
%Equations from http://www.ecfr.gov/cgi-bin/retrieveECFR?gp=&SID=77c338ef343a95729b9280cd1a7daa67&n=40y34.0.1.1.13&r=PART&ty=HTML#40:34.0.1.1.13.7.29.11

x_CO_dry = NDIR_CO/100; %Assumes concentrations are completely dry when measured by the NDIR
x_HC_dry = (NDIR_HC*3/.509)/1000000; %All in mol/mol
x_CO2_dry = NDIR_CO2/100;
K_H2O_gas = 3.5; %Assumed value

T_airtank = 20; %20 C
Rel_hum = .37; %relative humidity in Boston

Sat_fit=polyfit([15 20 25],[.017 .023 .031],1); %Linear estimate of saturation H2O content at 1.02 bar 
x_sat_int = Sat_fit(1)*T_airtank + Sat_fit(2); %Based on ambient temperature [deg C]

x_H2O_int = Rel_hum*x_sat_int; %Get amount of water in intake air
x_H2O_int_dry = x_H2O_int/(1-x_H2O_int); %Convert to dry mole fraction

x_CO2_int_dry = .000375; %mol/mol Assumed based on emissions standards
x_O2_int = (.209820 - x_CO2_int_dry)/(1 + x_H2O_int_dry);
x_CO2_int = x_CO2_int_dry/(1 + x_H2O_int_dry);

err = 1; %Error in Percent
x_H2O_exh_dry = 2*x_H2O_int/(1-2*x_H2O_int); %Initial Guesses
x_H2_dry = (x_CO_dry*x_H2O_exh_dry)/(K_H2O_gas*x_CO2_dry); %Initial Guesses
x_C_comb_dry = x_CO2_dry + x_CO_dry + x_HC_dry; %Initial Guesses
x_H2O_exh_old = 2*x_H2O_int; %Initial Guesses

while err > .1
    x_int_exh_dry = (1/(2*x_O2_int))*((HCratio/2 + 2)*(x_C_comb_dry - x_HC_dry) - (x_CO_dry + x_H2_dry));
    x_C_comb_dry = x_CO2_dry + x_CO_dry + x_HC_dry - x_CO2_int*x_int_exh_dry;
    x_H2_dry = (x_CO_dry*x_H2O_exh_dry)/(K_H2O_gas*x_CO2_dry);
    x_H2O_exh_dry = (HCratio/2)*(x_C_comb_dry - x_HC_dry) + x_H2O_int*x_int_exh_dry - x_H2_dry;
    x_H2O_exh = x_H2O_exh_dry/(1+x_H2O_exh_dry);
    err = 100*abs((x_H2O_exh - x_H2O_exh_old)/x_H2O_exh_old);
    x_H2O_exh_old = x_H2O_exh;
end

x_H2_dry;  %Desired Outputs from loop
x_H2O_exh;  %Desired Outputs from loop

%-------------------------------------------------------------------------%
%------------------- Convert NDIR to wet values---------------------------%
x_CO_wet = x_CO_dry*(1 - x_H2O_exh); %mol/mol  %mole fraction
x_HC_wet = x_HC_dry*(1 - x_H2O_exh)*1000000; %ppmC1 wet
x_CO2_wet = x_CO2_dry*(1 - x_H2O_exh); %mol/mol wet %mole fraction
x_H2_wet = x_H2_dry*(1 - x_H2O_exh);  %mol/mol wet %mole fraction

fuelFraction = 10^6 - x_CO_wet - x_HC_wet - x_CO2_wet - x_H2_wet;
%-------------------------------------------------------------------------%
%x_CO_wet, x_HC_wet, x_CO2_wet, x_H2_wet

end  
