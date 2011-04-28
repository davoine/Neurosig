function [t,y] = Liuetal2008Chandler99(tfinal)
% Basado en "Transition between two excitabilities in mesencephalic V
% neurons" Yihui Liu & Jing Yang & Sanjue Hu
% J Comput Neurosci (2008) 24:95–104
% y Chandler (1999)

%% Parametros
% 
% % Potencial de Nernst (en mV)
% E_K = -92;
% E_Na = 50;
% E_L = -72;
% E_h = -40.8;
% 
% 
% % Conductancias maximas (en uS)
% g_DRK = 0.6e-3;
% g_4AP = 0.6e-3;
% g_h = 2.4e-3;
% g_Na_t = 1.08e-3;
% g_Na_p = 72e-6;
% g_L = 120e-6;
% 
% % Capacitancia (en nF)
% C = 60e-3; % 60 pF

%% Resolucion de la ecuacion diferencial
tspan = [0 tfinal];
% Condiciones iniciales
% y = [V,n_DRK,n_4AP,h_t,s]
y0 = [-60 0 0 0 0];
options = odeset('RelTol',1e-9,'AbsTol',[1e-8 1e-5 1e-5 1e-5 1e-5]);
[t, y] = ode45(@modeloLiuetal2008,tspan,y0,options);

% Variables de estado
V = y(:,1);
n_DRK = y(:,2);
n_4AP = y(:,3);
h_t = y(:,4);
s = y(:,5);

% I_inyectada = 1000*(1+square((t-10)/(2*pi),20));
I_inyectada = 0;
% I =20*(1+chirp(t,0,tfinal,100));
%% Figuras
figure(1)
plot(t,y(:,1),'k')
hold on
plot(t,I_inyectada,'b')
hold off
xlabel('tiempo (ms)')
legend('potencial de membrana V_{m} (mV)','corriente inyectada I (nA)')
% 
% figure(2)
% plot(t,y(:,2),'g')
% hold on
% plot(t,y(:,3),'r')
% plot(t,y(:,4),'b')
% plot(t,y(:,5),'k')
% hold off
% xlabel('tiempo')
% ylabel('porcentaje')
% legend('n_{DRK}','n_{4-AP}','h_T','s')
% 
% % figure(3)
% % plot(t,I_K,'g')
% % hold on
% % plot(t,I_Na_t,'r')
% % plot(t,I_Na_p,'b')
% % hold off
% % xlabel('tiempo')
% % legend('I_K','I_{NaT}','I_{NaP}')

%% Funcion con las ecuaciones diferenciales
function dydt = modeloLiuetal2008(t,y)
%% Variables de estado
% definimos:
% y(1) = V
% y(2) = n_DRK
% y(3) = n_4AP
% y(4) = h_t
% y(5) = s

V = y(1);
n_DRK = y(2);
n_4AP = y(3);
h_t = y(4);
s = y(5);

%% Parametros

% Potencial de Nernst (en mV)
E_K = -92;
E_Na = 50;
E_L = -72;
E_h = -40.8;

% Conductancias maximas (en uS)
g_DRK = 45e-3;
g_4AP = 8.3e-3;
g_h = 20.2e-3;
g_Na_t = 1.08e-3;
g_Na_p = 72e-6;
g_L = 3e-3;

% Capacitancia (en nF)
C = 60e-3; % 60 pF


% Curvas de activacion e inactivacion
tau_n_DRK = 10;
n_DRK_inf = 1/(1+exp(-(V+4.2)/12.9));

tau_n_4AP = 2;
n_4AP_inf = 1/(1+exp(-(V+43)/3.9));

m_t_inf = 1/(1+exp(-(V+31.3)/4.3));

h_t_inf = 1/(1+exp((V+55)/7.1));
tau_h_t = 1.5;

m_p_inf =  1/(1+exp(-(V+50)/6.4));

s_inf = 1/(1+exp(-(V+50)/6.4));
tau_s = 100;

% Corrientes
I_L = g_L*(V-E_L);
I_DRK = g_DRK*n_DRK*(V-E_K);
I_4AP = g_4AP*n_4AP*(V-E_K);
I_Na_p = g_Na_p*m_p_inf*(V-E_Na);
I_Na_t = g_Na_t*m_t_inf*h_t*(V-E_Na);
I_h = g_h*s*(V-E_h);

% Intensidad en nA
% I = 100*(1+square((t-10)/(2*pi),20));
I = 200*t;
% I =20*(1+chirp(t,0,tfinal,100));

%% Ecuaciones diferenciales
dydt(1) = (1/C)*(I-I_DRK-I_4AP-I_Na_t-I_Na_p-I_L-I_h);
dydt(2) = (n_DRK_inf-n_DRK)/tau_n_DRK;
dydt(3) = (n_4AP_inf-n_4AP)/tau_n_4AP;
dydt(4) = (h_t_inf-h_t)/tau_h_t;
dydt(5) = (s_inf-s)/tau_s;
dydt = dydt';
end

end