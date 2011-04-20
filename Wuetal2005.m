function [t,y] = resolver_HH(tfinal,I)

%% Parametros
global C
global g_K g_Na g_L
global E_K E_Na E_L
% global V_n k_n V_max_n sigma_n C_amp_n C_base_n
% global V_m k_m V_max_m sigma_m C_amp_m C_base_m
% global V_h k_h V_max_h sigma_h C_amp_h C_base_h
global I

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
[t, y] = ode45(@HH,tspan,y0,options);

% Corrientes
V = y(:,1);
n = y(:,2);
m = y(:,3);
h = y(:,4);
I_K = g_K.*n.^4.*(V-E_K);
I_Na = g_Na.*m.^3.*h.*(V-E_Na);

%% Figuras
figure(1)
plot(t,y(:,1),'k')
xlabel('tiempo')
ylabel('voltaje')
title('potencial de membrana V_{m}')

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
hold off
xlabel('tiempo')
legend('I_K','I_{Na}')

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
I_K = g_K*n^4*(V-E_K);
I_Na = g_Na*m^3*h*(V-E_Na);
I_L = g_L*(V-E_L);

%% Curvas de activacion e inactivacion
h_inf = (1+exp((V_h-V)/k_h))^(-1);
m_inf = (1+exp((V_m-V)/k_m))^(-1);
n_inf = (1+exp((V_n-V)/k_n))^(-1);

tau_n = 4;
n_inf = 1/(1+exp(-(V+43)/3.9));
m_t_inf = 1/(1+exp(-(V+31.3)/4.3));
h_t_inf = 1/(1+exp((V+55)/7.1));
tau_t = 3;
m_p_inf =  1/(1+exp(-(V+50)/6.4));
h_p_inf = 1/(1+exp((V+52)/14));
tau_p_inf = 1e3 + 1e4/(1+exp((V+60)/10));

%% Ecuaciones diferenciales
dydt(1) = (1/C)*(I-I_K-I_Na-I_L);
dydt(2) = (n_inf-n)/tau_n;
dydt(3) = (h_t_inf-h_t)/tau_h_t;
dydt(4) = (h_p_inf-h_p)/tau_h_p;
dydt = dydt';
end

end