%% Lab 2: Engine Operation
%Molecular Weights 
M_CO = 12.01+16.01;
M_HC = 1 + 1.85*12.01; 
M_CO2 = 12.01+2*16.01;
M_H2 = 2*1.01;
M_Fuel = 18*1.01+8*12.01; 

%% Part I: Change Timing 
labPart = 1;
[Lambda, Timing, MAP, NIMEP, FuelPW, FuelPress, COV, T, NOx, CO, HC, CO2] = engineLabData(labPart); 

x_CO = []; x_HC = []; x_CO2 = []; x_H2 = []; Fuel = []; fuelFrac = []; EI_CO = []; EI_HC = []; EI_CO2 = []; EI_H2 = [];

for i = 1:12
 
    NDIR_CO = CO(i);% %vol, dry
    NDIR_HC = HC(i); %pppm C1 
    NDIR_CO2 = CO2(i); % %vol, dry
    [x_CO_wet, x_HC_wet, x_CO2_wet, x_H2_wet, m_f, fuelFraction] = patrickWetCode(NDIR_CO, NDIR_HC, NDIR_CO2);
    % RPM = 2000;
    cycle_dur = 2/2000; %seconds / cycle 
    m_f = m_f*sqrt((1.027+FuelPress(i)-MAP(i))/cycle_dur); %g/s 
    moles_fuel = m_f/M_Fuel; %moles/s 
    %chemical reaction equation, 1 mole of fuel ... you'll get
    % 79.08 moles of exhaust
    moles_exhaust = 79.08*moles_fuel; %moles/s
    x_CO = [x_CO x_CO_wet]; %mole/mole 
    x_HC = [x_HC x_HC_wet]; %mole/mole
    x_CO2 = [x_CO2 x_CO2_wet]; %mole/mole
    x_H2 = [x_H2 x_H2_wet]; %mole/mole
    Fuel = [Fuel m_f]; %g/s 
    m_CO = x_CO_wet*moles_exhaust*M_CO; %g/s
    m_HC = x_HC_wet*moles_exhaust*M_HC; %g/s
    m_CO2 = x_CO2_wet*moles_exhaust*M_CO2; %g/s
    m_H2 = x_H2_wet*moles_exhaust*M_H2; %g/s
    EI_CO = [EI_CO m_CO/m_f]; %emisssions index
    %EI_HC in 10^4 
    EI_HC = [EI_HC m_HC/m_f]; %emisssions index
    EI_CO2 = [EI_CO2 m_CO2/m_f]; %emisssions index
    EI_H2 = [EI_H2 m_H2/m_f]; %emisssions index
end 


%% Part II: Change Lambda

%Repeat everything from Part I: Change Timing
