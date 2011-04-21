function [t,y] = resolver_HH(tfinal)


%% Parametros
global C
global g_K g_Na g_L
global E_K E_Na E_L
% global V_n k_n V_max_n sigma_n C_amp_n C_base_n
% global V_m k_m V_max_m sigma_m C_amp_m C_base_m
% global V_h k_h V_max_h sigma_h C_amp_h C_base_h
% global I
global I_inyectada

% Potencial de Nernst (trasladados, para que el
% voltaje de reposo sea el nulo):
E_K = -20;
E_Na = 120;
E_L = 10.6;

% Conductancias maximas
g_K = 36;
g_Na = 120;
g_L = 0.3;

% Capacitancia
C = 1;

%% Resolucion de la ecuacion diferencial
tspan = [0 tfinal];
% Condiciones iniciales
% y = [V,n,m,h]
y0 = [0,0,0,0];
options = odeset('RelTol',1e-9,'AbsTol',[1e-8 1e-5 1e-5 1e-5]);
[t, y] = ode23s(@HH,tspan,y0,options);

% Corrientes
V = y(:,1);
n = y(:,2);
m = y(:,3);
h = y(:,4);
I_K = g_K.*n.^4.*(V-E_K);
I_Na = g_Na.*m.^3.*h.*(V-E_Na);
I_inyectada = 10*(1+square((t-10)/(2*pi),20)); % generacion de onda cuadrada
% I_inyectada = awgn(I_inyectada,1);

%% Figuras
figure(1)
plot(t,y(:,1),'k')
hold on
plot(t,I_inyectada,'b')
hold off
xlabel('tiempo')
ylabel('voltaje')
title('potencial de m   embrana V_{m}')

figure(2)
plot(t,y(:,2),'g')
hold on
plot(t,y(:,3),'r')
plot(t,y(:,4),'b')
hold off
xlabel('tiempo')
ylabel('porcentaje')
legend('n','m','h')

figure(3)
plot(t,I_K,'g')
hold on
plot(t,I_Na,'r')
plot(t,I_inyectada,'k')
hold off
xlabel('tiempo')
legend('I_K','I_{Na}','I_{inyectada}')

%% Funcion con las ecuaciones diferenciales
function dydt = HH(t,y)
    % definimos:
    % y(1) = V
    % y(2) = n
    % y(3) = m
    % y(4) = h
    V = y(1);
    n = y(2);
    m = y(3);
    h = y(4);

%% Parametros

% Parametros de activacion e inactivacion
% Rectificador retardado (corriente de potasio, no inactivable)
% V_n = -53;
% k_n = 15;
% V_max_n = -79;
% sigma_n = 50;
% C_amp_n = 4.7;
% C_base_n = 1.1;

% Corriente de sodio persistente
% activacion
% V_m = -40;
% k_m = 15;
% V_max_m = -38;
% sigma_m = 30;
% C_amp_m = 0.46;
% C_base_m = 0.04;
% 
% % inactivacion
% V_h = -62;
% k_h = -5.8;
% V_max_h = -67;
% sigma_h = 20;
% C_amp_h = 7.4;
% C_base_h = 1.2;

% Corrientes
I = 10*(1+square((t-10)/(2*pi),10)); % generacion de onda cuadrada
% I = awgn(I,10);
% de ciclo de trabajo duty/100
I_K = g_K*n^4*(V-E_K);
I_Na = g_Na*m^3*h*(V-E_Na);
I_L = g_L*(V-E_L);

%% Curvas de activacion e inactivacion
% h_inf = (1+exp((V_h-V)/k_h))^(-1);
% m_inf = (1+exp((V_m-V)/k_m))^(-1);
% n_inf = (1+exp((V_n-V)/k_n))^(-1);
% 
% tau_h = C_base_h + C_amp_h*exp((V_max_h-V)^2/(sigma_h^2));
% tau_m = C_base_m + C_amp_m*exp((V_max_m-V)^2/(sigma_m^2));
% tau_n = C_base_n + C_amp_n*exp((V_max_n-V)^2/(sigma_n^2));

alfa_n = 0.01*(10-V)/(exp((10-V)/10)-1);
beta_n = 0.125*exp(-V/80);
alfa_m = 0.1*(25-V)/(exp((25-V)/10)-1);
beta_m = 4*exp(-V/18);
alfa_h = 0.07*exp(-V/20);
beta_h = 1/(exp((30-V)/10)-1);

n_inf = alfa_n/(alfa_n+beta_n);
m_inf = alfa_m/(alfa_m+beta_m);
h_inf = alfa_h/(alfa_h+beta_h);

tau_n = 1/(alfa_n+beta_n);
tau_m = 1/(alfa_m+beta_m);
tau_h = 1/(alfa_h+beta_h);

%% Ecuaciones diferenciales
dydt(1) = (1/C)*(I-I_K-I_Na-I_L);
dydt(2) = (n_inf-n)/tau_n;
dydt(3) = (m_inf-m)/tau_m;
dydt(4) = (h_inf-h)/tau_h;
dydt = dydt';
end

end