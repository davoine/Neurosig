clear all
close all
clc

tfinal = 1500;
tspan = [0 tfinal];
% y = [V, n_DRK, n_4AP, h_t, s]
y0 = [-65.5 0 0 0 0];
options = odeset('MaxStep',1e-3,'RelTol',1e-5,'AbsTol',[1e-9 1e-3 1e-3 1e-3 1e-3]);
[t, y] = ode45(@modeloLiuetal2008, tspan, y0, options);
% [t, y] = ode45(@modeloLiuetal2008, tspan, y0);

% Variables de estado
V = y(:,1);
n_DRK = y(:,2);
n_4AP = y(:,3);
h_T = y(:,4);
s = y(:,5);
% 
% tumb = 100;
% I = 100*stepfun(t,tumb).*sin((t-tumb).^3);
% I = 2/10*(t-tumb).*stepfun(t,tumb);
% I = 900/100*stepfun(t,tumb);
%% Parametros

% Potencial de Nernst (en mV)
E_K = -92;
E_Na = 50;
E_L = -72;
E_h = -40.8;

% Conductancias maximas (en uS)
g_DRK = 0.6e-3;
g_4AP = 0.6e-3;
g_h = 2.4e-3;
g_NaT = 1.08e-3;
g_NaP = 7.2e-5;
g_L = 1.2e-4;

% Capacitancia (en nF)
C = 60e-3; % 60 pF

% Curvas de activacion e inactivacion
n_DRK_inf = 1./(1+exp(-(V+4.2)/12.9));
n_4AP_inf = 1./(1+exp(-(V+43)/3.9));
m_T_inf = 1./(1+exp(-(V+31.3)/4.3));
h_T_inf = 1./(1+exp((V+55)/7.1));
m_P_inf =  1./(1+exp(-(V+50)/6.4));
s_inf = 1./(1+exp((V+105)/7.3));

% Corrientes
I_L = g_L.*(V-E_L);
I_DRK = g_DRK.*n_DRK.*(V-E_K);
I_4AP = g_4AP.*n_4AP.*(V-E_K);
I_NaP = g_NaP.*m_P_inf.*(V-E_Na);
I_NaT = g_NaT.*m_T_inf.*h_T.*(V-E_Na);
I_h = g_h*s.*(V-E_h);

%% Figuras
figure(1)
plot(t,y(:,1),'k')
hold on
% plot(t,I,'b')
hold off
axis tight
xlabel('tiempo (ms)')
% legend('potencial de membrana V_{m} (mV)','corriente inyectada (%100) (pA)')

figure(2)   
plot(t,y(:,2),'g')
hold on
plot(t,y(:,3),'r')
plot(t,y(:,4),'b')
plot(t,y(:,5),'k')
hold off
axis tight
xlabel('tiempo (ms)')
ylabel('porcentaje (%)')
legend('n_{DRK}','n_{4-AP}','h_T','s')

figure(3)
plot(t,I_L,'g')
hold on
plot(t,I_NaT,'r')
plot(t,I_NaP,'b')
plot(t,I_4AP,'k.')
plot(t,I_DRK,'k*')
plot(t,I_h,'k-')
axis tight
hold off
xlabel('tiempo (ms)')
ylabel('corriente (pA)')
legend('I_L','I_{NaT}','I_{NaP}','I_{4-AP}','I_{DRK}','I_{h}')