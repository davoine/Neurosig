function [t,y] = Wuetal2005(tfinal)

%% Parametros
global C
global g_K g_Na_t g_Na_p g_L
global E_K E_Na E_L
global I

% Potencial de Nernst
E_K = -92;
E_Na = 55;
E_L = -60;

% Conductancias maximas
g_K = 6;
g_Na_t = 12;
g_Na_p = 1.1;
g_L = 2;

% Capacitancia
C = 1;

%% Resolucion de la ecuacion diferencial
tspan = [0 tfinal];
% Condiciones iniciales
% y = [V,n,m,h]
y0 = [-60,0,0,0];
options = odeset('RelTol',1e-9,'AbsTol',[1e-8 1e-5 1e-5 1e-5]);
[t, y] = ode45(@modeloWuetal2005,tspan,y0,options);

% Corrientes
V = y(:,1);
n = y(:,2);
h_t = y(:,3);
h_p = y(:,4);

m_t_inf = 1./(1+exp(-(V+31.3)/4.3));
h_t_inf = 1./(1+exp((V+55)/7.1));
tau_h_t = 3;

m_p_inf =  1./(1+exp(-(V+50)/6.4));
h_p_inf = 1./(1+exp((V+52)/14));
tau_h_p = 1e3 + 1e4./(1+exp((V+60)/10));

I_K = g_K.*n.^4.*(V-E_K);
I_Na_t = g_Na_t*m_t_inf.*h_t.*(V-E_Na);
I_Na_p = g_Na_p*m_p_inf.*h_p.*(V-E_Na);

% I = 20*(1+square(t/(2*pi),20));
I =20*(1+chirp(t,0,tfinal,100));
%% Figuras
figure(1)
plot(t,y(:,1),'k')
hold on
plot(t,I,'b')
hold off
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
legend('n','h_T','h_P')

figure(3)
plot(t,I_K,'g')
hold on
plot(t,I_Na_t,'r')
plot(t,I_Na_p,'b')
hold off
xlabel('tiempo')
legend('I_K','I_{NaT}','I_{NaP}')

%% Funcion con las ecuaciones diferenciales
function dydt = modeloWuetal2005(t,y)
% definimos:
% y(1) = V
% y(2) = n
% y(3) = h_t
% y(4) = h_p
V = y(1);
n = y(2);
h_t = y(3);
h_p = y(4);

%% Parametros


% Potencial de Nernst
E_K = -92;
E_Na = 55;
E_L = -60;

% Conductancias maximas
g_K = 6;
g_Na_t = 12;
g_Na_p = 1.1;
g_L = 2;

% Capacitancia
C = 1;


% Curvas de activacion e inactivacion
tau_n = 4;
n_inf = 1/(1+exp(-(V+43)/3.9));

m_t_inf = 1/(1+exp(-(V+31.3)/4.3));
h_t_inf = 1/(1+exp((V+55)/7.1));
tau_h_t = 3;

m_p_inf =  1/(1+exp(-(V+50)/6.4));
h_p_inf = 1/(1+exp((V+52)/14));
tau_h_p = 1e3 + 1e4/(1+exp((V+60)/10));

% Corrientes
I_K = g_K*n*(V-E_K);
I_Na_t = g_Na_t*m_t_inf*h_t*(V-E_Na);
I_Na_p = g_Na_p*m_p_inf*h_p*(V-E_Na);
I_L = g_L*(V-E_L);

% I = 20*(1+square(t/(2*pi),20));
I =80*(1+chirp(t,0,tfinal,100));

%% Ecuaciones diferenciales
dydt(1) = (1/C)*(I-I_K-I_Na_t-I_Na_p-I_L);
dydt(2) = (n_inf-n)/tau_n;
dydt(3) = (h_t_inf-h_t)/tau_h_t;
dydt(4) = (h_p_inf-h_p)/tau_h_p;
dydt = dydt';
end

end
