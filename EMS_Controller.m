function [I1, I2, I3] = EMS_Controller(SOC1, SOC2, SOC3, Price, P_threshold)
% EMS Controller: Computes current references for 3 EV
% bidirectional buck-boost converters based on SOC and real-time electricity price.

% Inputs:
% SOC1, SOC2, SOC3 - State of charge of each EV [%]
% Price            - Current electricity unit price [INR/kWh]
% P_threshold      - User-defined price threshold [INR/kWh]

% Outputs:
% I1, I2, I3       - Reference current [A]: +ve = charge, -ve = discharge

Imax = 30;
SOC = [SOC1, SOC2, SOC3];
I = zeros(1,3);

idx_low = find(SOC < 20);
all_above_20 = all(SOC >= 20);
[~, idx_min] = min(SOC);

% CASE 1: High price & critically low SOC -> peer DC bus charging
if Price > P_threshold && ~isempty(idx_low)
    for i = 1:3
        if i == idx_min
            I(i) = Imax; % Charge the weakest EV
        else
            I(i) = -Imax / 2; % Support via DC bus discharge
        end
    end

% CASE 2: Low price -> grid charging for all EVs (tapered by SOC)
elseif Price <= P_threshold
    for i = 1:3
        I(i) = Imax * (1 - SOC(i) / 100);
    end

% CASE 3: High price + all EVs healthy -> V2G discharge
elseif Price > P_threshold && all_above_20
    for i = 1:3
        I(i) = -Imax;
    end
    
% CASE 4: Safety fallback
else
    I = zeros(1, 3); 
end

I1 = I(1); 
I2 = I(2); 
I3 = I(3);

end