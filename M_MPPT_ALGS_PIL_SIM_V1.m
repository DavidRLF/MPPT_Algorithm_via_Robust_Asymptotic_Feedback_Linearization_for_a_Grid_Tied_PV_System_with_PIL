clc; clear all; close all;

%% PV array based on Canadian Solar CS6X-280P panels
No_Cadenas_Paralelo = 2;
No_Modulos_PorCadena = 18;
Irr_in=0;
Npar=No_Cadenas_Paralelo;
impp_STC = 15.72/2;
G_STC = 1000;

%% Boost converter parameters and operating point
% PV array (T = 25, Pmp = 10.07 kW, Vmp = 640.8 V)
vpv = 640.8;       % Minimum input voltage
vdc = 1000;        % Desired output voltage (DC bus voltage)
Fs = 5e3;          % Switching frequency
Ppv = 10.07e3;     % Input power
ipv = Ppv/vpv;     % Input current
iL = ipv;          % Inductor current considered equal to ipv
d =(vdc-vpv)/vdc;  % Duty cycle
Rpv = vpv/ipv;     % Rpv = Rmppt
Idc = ipv*(1-d);   % Load current calculation
Rdc = vdc/(Idc);   % Load resistance calculation
Lmin =(d*(1-d)^2*Rdc)/(2*Fs); % Minimum inductance for CCM
%L = 68.2729*Lmin;  % To ensure CCM
L = 100e-3;
ILmax = vpv/((1-d)^2*Rdc)+(vpv*d)/(2*L*Fs); % Maximum inductor current
ILmin = vpv/((1-d)^2*Rdc)-(vpv*d)/(2*L*Fs)  % Minimum inductor current
Cdc = 470e-6;               % Output capacitor 
dVdc = (d*vdc)/(Rdc*Cdc*Fs) % Output voltage ripple of 1 V
Cpv = 80e-6;                % Input capacitor (Scenarios 2 and 5)
b = 16;                     % DPWM bit resolution
Ucmax = (2^b-1);            % Maximum control signal (0–Ucmax)
Kdpwm = 1/Ucmax;            % DPWM gain (digital PWM model)
UC = d/Kdpwm;               % Operating point for UC
X1 = iL;                    % Operating point for state X1 
X2 = vdc;                   % Operating point for state X2
Ref = ipv;                  % Reference to be tracked by the controller

%% Continuous-time model and open-loop
% x1 = ipv (PV array current), x2 = vdc (output voltage)
% State-space matrices
Amc = [0 -(1-Kdpwm*UC)/L
      (1-Kdpwm*UC)/Cdc -1/(Cdc*Rdc)];
Bmc = [(Kdpwm*X2)/L
      -(Kdpwm*X1)/Cdc]; 
Cmc = [1/2 0     % To control x1 = ipv = iL
      0 1];      % To control x2 = vdc
Dmc = [0
      0];
states = {'x1' 'x2'};
inputs = {'uc'}; 
outputs = {'x1=ipv' 'x2=vdc'};
Sys_Boost_Modelo_Continuo = ss(Amc,Bmc,Cmc,Dmc,'statename',states,'inputname',inputs,'outputname',outputs)
tf(Sys_Boost_Modelo_Continuo)
Gs_uc_to_x1 = (ans(1,1))
Gs_uc_to_x2 = (ans(2,1))
[num_Gs_uc_to_x1, den_Gs_uc_to_x1] = tfdata(Gs_uc_to_x1, 'v');
[num_Gs_uc_to_x2, den_Gs_uc_to_x2] = tfdata(Gs_uc_to_x2, 'v');

%% Discrete-time model and open-loop of the Boost converter
% x1 = ipv (PV array current), x2 = vdc (output voltage)
% State-space matrices
Ts1 = 1/Fs;
Amd = [1 (Ts1*(Kdpwm*UC-1))/L
   -(Ts1*(Kdpwm*UC-1))/Cdc 1-Ts1/(Cdc*Rdc)];
Bmd = [(Kdpwm*Ts1*X2)/L
    -(Kdpwm*Ts1*X1)/Cdc];
Cmd = [1/2 0      % To control x1 = ipv = iL
       0 1];      % To control x2 = vdc
Dmd = [0
      0];
states = {'x1' 'x2'};
inputs = {'uc'}; 
outputs = {'x1=ipv' 'x2=vdc'};
Sys_Boost_Modelo_Discreto = ss(Amd,Bmd,Cmd,Dmd,Ts1,'statename',states,'inputname',inputs,'outputname',outputs)
tf(Sys_Boost_Modelo_Discreto)
Gz_uc_to_x1=(ans(1,1));
[num_Gz_uc_to_x1, den_Gz_uc_to_x1] = tfdata(Gz_uc_to_x1, 'v');

%% Design of discrete SF controller + integral action
% System
Cmd_Control = [1 0]; % Control output y = x1 = ipv
Dmd_Control = [0];
Amd = [1 -(Ts1*(1-Kdpwm*UC))/L
   (Ts1*(1-Kdpwm*UC))/Cdc 1-Ts1/(Cdc*Rdc)];
Bmd = [(Kdpwm*Ts1*X2)/L
    -(Kdpwm*Ts1*X1)/Cdc];
% Augmented matrices Aamd and Bamd
% Aamd for Simulink block-diagram environment,
% since the integral action represented by a third state is modeled
% explicitly using an accumulative-sum block
% with gain Ts of the form x3[k+1] = x3[k] + Ts*(X2ref[k] - x2(k))
Aamd = [ 1                        -(Ts1*(1-Kdpwm*UC))/L             0;
        (Ts1*(1-Kdpwm*UC))/Cdc   1-Ts1/(Cdc*Rdc)                    0;
        -Ts1                       0                                1 ]; 
% Aamd for script environment, since the integral action represented by
% a third state is modeled as x3[k+1] = x3[k] + (X2ref[k] - x2(k))
% without including Ts because ss(..) already accounts for it                                             
Aamdprima = [ 1                        -(Ts1*(1-Kdpwm*UC))/L             0;
             (Ts1*(1-Kdpwm*UC))/Cdc   1-Ts1/(Cdc*Rdc)                  0;
             -1                       0                                1 ]; 
Bamd = [ (Kdpwm*Ts1*X2)/L;
         -(Kdpwm*Ts1*X1)/Cdc;
         0 ];
Eamd = [zeros(size(Aamd,1)-1,1); 1];
Camd = [Cmd_Control 0];
% Desired poles in z (converted from continuous)
%Testd = 0.06245;
Testd = 0.0036;     % Scenarios 1–5
%Testd = 0.00128;
zeta_d = 1.0;
p3 = 43;
wn_d = 4 / (zeta_d * Testd);
s1 = -zeta_d * wn_d;
s2 = -zeta_d * wn_d;
s3 = -p3;
z1 = exp(s1 * Ts1);
z2 = exp(s2 * Ts1);
z3 = exp(s3 * Ts1);
Polos_Des_Boost_Mod_Disc = [z1 z2 z3];   % Following the design method
% If using the trial-and-error method
% z1p = exp(s1p * Ts1); % If using the trial-and-error method
% z2p = exp(s2p * Ts1); % If using the trial-and-error method
% z3p = exp(s3p * Ts1); % If using the trial-and-error method
% Polos_Des_Boost_Mod_Disc = [z1p z2p z3p]; % If using the trial-and-error method
% Controllability check
Co_Boost_Modelo_Disc = ctrb(Aamd, Bamd);
if rank(Co_Boost_Modelo_Disc) < size(Aamd,1)
    error('The augmented system is not fully controllable.')
end
% Compute gains with acker as used in Simulink environment
Kmd = acker(Aamd, Bamd, Polos_Des_Boost_Mod_Disc);  
K1y2md = Kmd(1:end-1) % To be used in Simulink (closed loop)
% Invert Ki sign to avoid opposite integral action
% since we use Vref - Vo; if it were Vo - Vref, inversion would not be needed
Kimd = -Kmd(end) % To be used in Simulink closed loop with block model
                 % For Simulink using a function block, multiply
                 % Kimd*Ts due to the Aamd model and integrator implementation as:
                 % Acc_Int = Ki * ek * Ts + Acc_Int_1;
% Compute gains with acker as used in the script environment
Kmdprima = acker(Aamdprima, Bamd, Polos_Des_Boost_Mod_Disc); % Script usage
% Closed-loop system to evaluate in script
Afmd = Aamdprima-Bamd*Kmdprima; 
% Eigenvalues (closed-loop poles) using Simulink Kmd; should
% match the desired poles
Polos_Boost_Lazo_Cerrado_Disc = eig(Aamd-Bamd*Kmd)
% Closed-loop Boost with state-feedback (script environment)
SLC_Boost_m_SF_Disc = ss(Afmd,Eamd,Camd,0,Ts1);
% Open-loop and closed-loop responses (SF + integral)
figure(1)
% Open-loop (x1 vs u1)
subplot(2,1,1)
hold on
step((Ucmax-UC) * Gz_uc_to_x1, 'b')     % Discrete
legend('Discrete')
title('Boost Converter Open-Loop Model (x1/uc = ipv/(d/Kdpwm))')
ylabel('ipv current [A]')
grid on
% Closed-loop (x1 vs u1)
subplot(2,1,2)
hold on
step(Ref * SLC_Boost_m_SF_Disc, 'b')       % Discrete
legend('Discrete')
title('Boost Closed-Loop with State Feedback + Integral Action')
ylabel('ipv current [A]')
xlabel('Time [s]')
grid on
hold off;

%% DC-AC inverter  
Fc = 2e3;               % Carrier triangular base frequency (Hz) for the inverter
fs = 60;                % Grid base frequency (Hz) 
ws = 2*pi*fs;           % Grid base angular frequency (rad/s)
vdc = 1000;             % DC bus base voltage (V)
S = 10e3*3/2;           % System apparent power base (VA)
VL = (381.051/2);       % Line-line base voltage (rms)
Vf = VL/sqrt(3);        % Phase base voltage (rms) 
vdc_ref = vdc;          % Desired DC bus voltage (V)
Lbase = vdc^2/(ws*S);   % Base inductance of L filter (H)
% Final inductor value (H). If fc = 2 kHz and THD < 10%, then:
L_pu = 0.3;
Linv = L_pu*Lbase;
Linv = 0.03;             % Value chosen by trial-and-error
Rinv = (Linv*377/fs/2);  % Internal resistance of Linv
Rinv = 0.0417;
Cinv = 470e-6;           % Inverter input capacitor
Ts4 = 1/(4*Fc);          % Sampling time (s)
Td = Ts4/2;              % PWM update delay (s)
Ts_inv = 1/(100*Fc);     % PWM sampling time and other non-controller blocks
Vp = 1;                  % PWM carrier peak voltage (V)

%% Digital PI controller design based on the inverter frequency 
% "PWM update delay is neglected"
% dq-axis current PI controllers
Porcentaje1 = 1.0;                    % Desired maximum overshoot Mp (%)
Mp1 = Porcentaje1/100;
Zeta1 = sqrt(log(Mp1)^2/(log(Mp1)^2+pi^2)); % Damping factor
tset1 = 10e-3;                      % Desired settling time (s)                                  
Porcentaje = 2;                     % Allowed max error at tset1 
E1 = Porcentaje/100;                 
wn1 = -log(E1)/(Zeta1*tset1);       % Natural frequency (rad/s)
Kp2 = 2*Linv*Vp*Zeta1*wn1-Rinv*Vp;  % Proportional gain
Ki2 = Linv*Vp*wn1^2;                % Integral gain
% Voltage-loop PI controller, in case a LPF is placed for id
Tlpf = 0.02;                        % LPF response time
Alpha = 2;                          % Max Mp of 5%, per Naslin method  
Kp3 = (Cinv)/(Alpha*Tlpf);          % Proportional gain  
Ki3 = (Cinv)/(Alpha^3*Tlpf^2);      % Integral gain
% Voltage-loop PI controller, without LPF for id
Porcentaje = 1;                     % Desired maximum overshoot Mp (%) 
Mp2 = Porcentaje/100;               % Damping factor
Zeta2 = sqrt(log(Mp2)^2/(log(Mp2)^2+pi^2));
n = 0.6;                    % Times slower than dq current control   
tset2 = tset1*n;            % Settling time (s) 
Porcentaje = 4;             % Allowed max error at tset2
E2 = Porcentaje/100;
wn2 = -log(E2)/(Zeta2*tset2); % Natural frequency (rad/s)
Kp4 = 2*Cinv*Zeta2*wn2;       % Proportional gain
Ki4 = Cinv*wn2^2;             % Integral gain
% PLL PI controller
Zeta3 = 0.707;                % Damping
wn3 = (120*pi)/2;             % Grid frequency 
Kp5 = (2*Zeta3*wn3);          % Proportional gain
Ki5 = wn3^2;                  % Integral gain
% Digital controller gains
KI2 = Ki2*Ts4;
KP2 = Kp2-KI2/2;
KI3 = Ki3*Ts4;
KP3 = Kp3-KI3/2;
KI4 = Ki4*Ts4;
KP4 = Kp4-KI4/2;
KI5 = Ki5*Ts_inv;
KP5 = Kp5*Ts_inv-KI5/2;

%% 50 kVA transformer (e.g., small building)
Ptrafo   = 100e3;   % Rated power [W]
Ftrafo   = fs;      % Operating frequency [Hz] 
VLLsec   = 33000;   % Grid side line-line voltage [Vrms]
VLLprim  = VL;      % Inverter side line-line voltage [Vrms]

%% Electric grid
VLngrid = 33000/sqrt(3);    % Line-to-neutral voltage [rms]
Fred    = fs;               % Grid frequency [Hz]
In = 1e6/(1.73*(Vf));
Icc_calc = In/(5/100);

%% Linearizing control design without integral action (discrete)
% Boost converter model transformed by the control law
Atd=[1];
Btd=[Ts1]; 
Ctd=[1];   % To control z(k) = ipv(k)
Dtd=[0];
states = {'z(K)'};
inputs = {'vt(k)'};
outputs = {'ipv(k)'};
Sys_d = ss(Atd,Btd,Ctd,Dtd,Ts1,'statename',states,'inputname',inputs,'outputname',outputs);
tf(Sys_d)
Gz_vt_to_ipv=ans(1,1)
Ctd=[1]; % Control of ipv(k) = z(k)
Dtd=[0];
sys_boost_Gz_vt_to_ipv=ss(Atd,Btd,Ctd,Dtd,Ts1);
% Design parameters
%Testcl = 0.0042;   % Desired settling time
Testcl = 0.0055;    % Desired settling time (Scenarios 1–5)
%Testcl = 0.00203;  % Desired settling time
zeta = 1;       % Desired damping (not necessary here, kept for consistency)
omega_n = 4 / (zeta*Testcl);
% Desired pole
p1 = -omega_n;  % Real negative pole for desired dynamics
% Discrete conversion via exponential
p_dis = exp(p1*Ts1);
% Feedback gain
Kt_acker_d = acker(Atd, Btd, p_dis);  % Single value
K1 = Kt_acker_d;
% Desired reference for z(k) (ipv(k) here)
z1_ref_acker = Ref; % Adjust as needed
% Modify control law to include reference term
u_ref_acker_d = Kt_acker_d*[z1_ref_acker]; % Only z1_ref affects input
% New closed-loop system with reference
Aft_acker_d = Atd-Btd*Kt_acker_d;
Bft_acker_d = Btd*u_ref_acker_d; % Add reference at the input
% Closed-loop poles (should match desired)
Polos_boost_d_lazo_cerrado_acker=eig(Aft_acker_d)
% Transformed converter with state feedback, no integral action (closed loop)
slc_boost_d_SF_conREF_acker=ss(Aft_acker_d,Bft_acker_d,Ctd,0,Ts1);
slc_boost_d_SF_sinREF_acker=ss(Aft_acker_d,Btd,Ctd,0,Ts1);
% Open- and closed-loop responses (state feedback)
% without integral action
figure(2)
subplot(311)
step(((Ucmax-UC))*Gz_uc_to_x1)
title('Boost Open-Loop (Discrete Step)');
subplot(312)
step(1.0*slc_boost_d_SF_conREF_acker)
title('Closed-Loop Acker Boost Transformed Type-1 System With Reference Tracking (Discrete Step)');
subplot(313)
step(1.0*slc_boost_d_SF_sinREF_acker)
title('Closed-Loop Acker Boost Transformed Type-1 System Without Reference Tracking (Discrete Step)');

%% High-gain observer poles
% Regarding dominant poles: they must be further left in the complex plane
% (more negative real part) than those of the closed-loop transformed system
% so that the observer is faster and does not degrade control performance.
ep=0.0001; % Smaller -> response resembles the model more,
             % but behaves like state-feedback control
%alpha1 = 2;
%alpha2 = 1;
Zeta_obs=1;
Test_obs=4;
wn_obs = 4 / (Zeta_obs*Test_obs);
Alpha1 = 2*Zeta_obs*wn_obs;
Alpha2 = wn_obs;
wp_sist_cont=sqrt((Kdpwm*UC-1)^2/(Cdc*L));
Ep_cont=1/(48.6*wp_sist_cont) % Scenarios 1, 2 and 3
Epsilon=Ep_cont/Ts1
K1disc=Alpha1/(Epsilon*Ts1);
K2disc=Alpha2^2/(Epsilon^2*Ts1^2);
% Warning for the F28069M board
% (use an arbitrary threshold 1e38 as a double overflow reference)
umbral_f28069m = 1e38;
if abs(K1disc) > umbral_f28069m || abs(K2disc) > umbral_f28069m
    disp('Warning: One of the gains exceeds the double range on the F28069M board.');
end
polos_obs_cont = roots([1 Alpha1/Ep_cont Alpha2/Ep_cont^2])
polos_obs_dig = exp(polos_obs_cont*Ts1)


%% Operating point for linearizing control
X2;
L;
Ts=Ts1;


%% PI controller design (continuous and discrete)
% Using SISO TOOL
%      a*(1+b*s)
% Cpi = ---------
%          s
% For a time Ta = 0.1 seconds
%a = 5.5e6; % Good candidate 1
%b = 0.0065;
%a =80.0e6;
%b = 0.0010;
a = 9.5e6;  % Scenarios 1–5
b = 0.0024;


Kp1 = a*b
Ti1 = Kp1/a
% Discretizing the controller
KI1=Kp1/Ti1*Ts1;
KP1=Kp1-KI1/2;
Cs_PI_SISO=tf([Kp1 Kp1/Ti1],[1 0]);
Cz_PI=zpk(tf([(KP1+KI1) -KP1],[1 -1],Ts1))   % Discretized controller
TFclz=feedback(Cz_PI*Gz_uc_to_x1,1);
figure(3)
step(Ref * TFclz, 'b'); 
legend('Discrete (Digital)', 'Location', 'Best');
title('Step Response Closed-Loop Boost with PI');
xlabel('Time (s)');
ylabel('ipv current [A]');
grid on;

%% Responses of all controllers
figure(4)
hold on;
% Step response with State Feedback (SF)
step(Ref * SLC_Boost_m_SF_Disc, 'b');
% Step response with PI control
step(Ref * TFclz, 'r');
% Step response with Linearizing Control (discrete)
step(1.0 * slc_boost_d_SF_conREF_acker, 'g');
legend('State Feedback Digital', 'PI Digital', ...
      'Linearizing Control Digital', ...
       'Location', 'Best');
title('Step Response Closed-Loop Boost with Different Controllers');
xlabel('Time (s)');
ylabel('Current i_{pv} [A]');
grid on;
hold off;


%% Nominal parasitics
ESRCpv=0.2;
RL=0.3;
Ronfet=0.05;
Vfdiode=0.7;
Rondiode=0.05;
ESRCdc=0.2;
Fact1 = 0.7;
Fact2 = 1.3;


%% Scenario 1
% Cpv=0.880e-6;
% ESRCpv=Fact1*ESRCpv;
% L=Fact1*L;
% RL=Fact1*RL;
% Ronfet=Fact1*Ronfet;
% Vfdiode=Fact1*Vfdiode;
% Rondiode=Fact1*Rondiode;
% Cdc=Fact1*Cdc;
% ESRCdc=Fact1*ESRCdc;

% %% Scenario 2
% Cpv=0.880e-6;
% % Disable ESRCpv of Cpv
% L=L;
% % Disable RL of L
% Ronfet=0.001;
% Vfdiode=0.0;
% Rondiode=0.001;
% Cdc=Cdc;
% % Disable ESRCdc of Cdc

% %% Scenario 3
% Cpv=0.880e-6;
% ESRCpv=Fact2*ESRCpv;
% L=Fact2*L;
% RL=Fact2*RL;
% Ronfet=Fact2*Ronfet;
% Vfdiode=Fact2*Vfdiode;
% Rondiode=Fact2*Rondiode;
% Cdc=Fact2*Cdc;
% ESRCdc=Fact2*ESRCdc;

% %% Scenario 4 
Cpv=Cpv;
ESRCpv=ESRCpv;
L=L;
RL=RL;
Ronfet=Ronfet;
Vfdiode=Vfdiode;
Rondiode=Rondiode;
Cdc=Cdc;
ESRCdc=ESRCdc;
