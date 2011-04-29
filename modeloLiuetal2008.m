%% Modelo
% Basado en "Transition between two excitabilities in mesencephalic V
% neurons" Yihui Liu & Jing Yang & Sanjue Hu
% J Comput Neurosci (2008) 24:95–104

function dydt = modeloLiuetal2008(t,y)

% Variables de estado
V = y(1);
n_DRK = y(2);
n_4AP = y(3);
h_T = y(4);
s = y(5);


% Parametros
E_K = -92;
E_Na = 50;
E_L = -72;
E_h = -40.8;

% Conductancias maximas (en pS)
g_L = 120;
g_NaT = 1080;
g_NaP = 72;
g_DRK = 600;
g_4AP = 600;
g_h = 2400;
% g_4AP = 240;

% Capacitancia (en pF)
C = 60;

% Curvas
n_DRK_inf = (1+exp(-(V+4.2)/12.9))^(-1);
tau_DRK = 10;

n_4AP_inf = (1+exp(-(V+43)/3.9))^(-1);
tau_4AP = 2;

m_T_inf = (1+exp(-(V+31.3)/4.3))^(-1);

h_T_inf = (1+exp((V+55)/7.1))^(-1);
tau_NaT = 1.5;

m_P_inf = (1+exp(-(V+50)/6.4))^(-1);

s_inf = (1+exp((V+105)/7.3))^(-1);
tau_s = 100;

% Corrientes (en pA)
I_L = g_L*(V-E_L);
I_DRK = g_DRK*n_DRK*(V-E_K);
I_4AP = g_4AP*n_4AP*(V-E_K);
I_NaP = g_NaP*m_P_inf*(V-E_Na);
I_NaT = g_NaT*m_T_inf*h_T*(V-E_Na);
I_h = g_h*s*(V-E_h);

% I = 1000*(1+square((t-10)/(2*pi),20));
tumb = 500;
I = 200*stepfun(t,tumb)*sin((t-tumb)^3);

% I = 2*(t-tumb)*stepfun(t,tumb);
% I = 900*stepfun(t,tumb);

% Ecuaciones diferenciales
dydt(1) = (1/C)*(I - I_L - I_DRK - I_4AP - I_NaP - I_NaT - I_h);
dydt(2) = (n_DRK_inf - n_DRK)/tau_DRK;
dydt(3) = (n_4AP_inf - n_4AP)/tau_4AP;
dydt(4) = (h_T_inf - h_T)/tau_NaT;
dydt(5) = (s_inf - s)/tau_s;
dydt = dydt';   