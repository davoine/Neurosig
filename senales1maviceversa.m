%% Script senales1.m
% La señal a procesar tiene que estar en el mismo directorio que el script.
% Lo primero que aparece es un cuadro de diálogo
% para seleccionar el archivo a procesar (sin encabezados).
% 
% Suponiendo siempre que la primer columna es el tiempo,
% va a preguntar por el orden de las otras dos:
% Si primero está la presináptica y luego la post, hay que poner 1, sino 0.
% 
% Luego grafica las señales, los módulos de sus FFT
% y el módulo de la transferencia
% (esta última en dB, calculando los dB como |H|dB = 20*log(|H|)).
% 
% Pregunta luego por el orden del filtro de media móvil (n).
% Para el punto k-ésimo, calcula el promedio con los n puntos anteriores:
% xnuevo[k]=(x[k]+x[k-1]+...+x[k-n+1])/n
% 
% Luego por el orden del decimado (m):
% cada m puntos, se queda con uno sólo.
% 
% Finalmente, por la frecuencia a partir de la cual decima (fdec)
% (en las frecuencias menores a fdec, la señal queda igual).
% 
% Grafica la nueva transferencia sobre la anterior
% (negro sobre azul, en dB también) y luego la grafica sola (en dB),
% grabándola automáticamente como Hf.jpg, Hf.eps y Hf.fig, en el mismo directorio.

clear all
close all
clc

%% Cargado de senales
% 
[archivoentrada, ruta] = uigetfile( ...
{''}, ...
   'Elegir la senal a procesar');
A = load(archivoentrada);
% A = load ('18_11_10 140 Average');
pre1post2 = input('Si la primer senal es la presinaptica y la segunda la postsinaptica, digite 1.\nEn caso contrario, digite 0.\n');
t = A(:,1); % tiempo
fs = 1/(t(2)-t(1)); %frecuencia de muestreo

v1ini = A(:,2); % senal original pre
v1m = mean(v1ini); %valor de continua pre
v1 = v1ini-v1m; %senal sin continua pre

v2ini = A(:,3); % senal original post
v2m = mean(v2ini);  %valor de continua post
v2 = v2ini-v2m; %senal sin continua post

if pre1post2 ==0
    % La primer senal es postsinaptica y la segunda pre
    % cambiamos el nombre de las senales de manera acorde
    alrevesini = v1ini;
    alrevesm = v1m;
    alreves = v1;
    v1ini = v2ini;
    v1m = v2m;
    v1 = v2;
    v2ini = alrevesini;
    v2m = alrevesm;
    v2 = alreves;
end
figure(1)
plot(t(1:length(t)),v1)
xlabel('tiempo (s)')
hold on
plot(t(1:length(t)),v2,'k')
legend('Senal 1', 'Senal 2')
hold off
grid on
axis tight
% saveas(1,'v1v2t.fig')
% saveas(1,'v1v2t.png')

%% FFTs

L = length(t); % largo del vector de tiempo
NFFT = 2^nextpow2(L); % L = 2^NFFT (aprox)
f = fs/2*linspace(0,1,NFFT/2+1); % vector de frecuencia

%% Analizamos v1
V1 = fft(v1,NFFT)/L;

figure(2)
semilogx(f,2*abs(V1(1:NFFT/2+1))) 
title('Componentes de frecuencia')
% axis tight
xlabel('frecuencia (Hz)')
ylabel('|V1(f)|')
grid on
% saveas(2,'V1f.fig')
% saveas(2,'V1f.png')

%% Analizamos v2
V2 = fft(v2,NFFT)/L;
figure(3)
semilogx(f,2*abs(V2(1:NFFT/2+1)))
% axis tight
title('Componentes de frecuencia')
xlabel('frecuencia (Hz)')
ylabel('|V2(f)|')
grid on
% saveas(3,'V2f.fig')
% saveas(3,'V2f.png')
%% Transferencia
H=V2(1:NFFT/2+1)./V1(1:NFFT/2+1); % Transferencia
ArgH = phase(H); % fase de la transferencia
HdB = 20*log10(abs(H));

%% Grafica 4
figure(4)
semilogx(f,HdB)
xlabel('frecuencia (Hz)')
ylabel('|H(f)|_{dB}')
% axis([0 600 0.01 10])
axis tight
grid on
% saveas(4,'Hf010kHz.fig')
% saveas(4,'Hf010kHz.png')
%% Cortando data hasta 600 Hz
ifmaxx = find(f>600);
ifmax = ifmaxx(1);
fposta=f(1:ifmax);
Hposta=H(1:ifmax);
ArgHposta = phase(Hposta);
HpostadB = 20*log10(abs(Hposta));

%% Grafica 5
figure(5)
semilogx(fposta,HpostadB)
grid on
axis tight
xlabel('frecuencia (Hz)')
ylabel('|H(f)_{dB}|')

%% Procesamiento: pedido de parametros al usuario
n = input('Indique el orden del filtro de media movil n: ');
disp('Indique si el filtro de media movil se aplica hacia adelante (1)');
adelante = input('o hacia atras (0): ');
disp('La senal sera decimada con un orden m1 entre fdec1 y fdec 2')
disp('y con m2 desde fdec2 al final (600 Hz)')
m1 =  input('Indique el orden del primer decimado m1: ');
fdec1 = input('Indique la frecuencia fdec1: ');
m2 =  input('Indique el orden del segundo decimado m2: ');
fdec2 = input('Indique la frecuencia fdec2: ');

%% Filtro de media movil
% [Hmavf1] = filtromediamovil(Hposta, n, adelante);
% if adelante
%     adelante = 0;
% else
%     adelante = 1;
% end
[Hmavf] = filtromediamovil(Hposta, n, adelante);
% Hmavf = (Hmavf1+Hmavf2)/2;

%% Decimacion entre fdec1 y fdec2, con orden m1
[ffinal1, Hfinal1] = decimar12(fposta,Hmavf,fdec1,fdec2,m1);

%% Decimacion entre fdec2 y ffinal (600 Hz), con orden m2
finfinita = 10*ffinal1(length(ffinal1));
[ffinal, Hfinal] = decimar12(ffinal1,Hfinal1,fdec2,finfinita,m2);

% ffinal = fposta;
% Hfinal = Hmavf;
%% Pasamos a modulo en dB y argumento en radianes
HfinaldB = 20*log10(abs(Hfinal));
ArgHfinal = phase(Hfinal);
% Graficamos encima de la transferencia original
hold on
semilogx(ffinal,HfinaldB,'k.-')
axis tight
legend('Transferencia original (en dB)','Transferencia filtrada y decimada (en dB)')
hold off

%% Figuras 6 y 7
figure(6)
semilogx(ffinal,HfinaldB,'k')
xlabel('Frecuencia (Hz)')
ylabel('|H(f)_{dB}|')
axis tight
title('Modulo de la transferencia entre la celula postsinaptica y presinaptica')

figure(7)
semilogx(ffinal,ArgHfinal,'k')
xlabel('Frecuencia (Hz)')
ylabel('Arg(H(f))')
axis tight
title('Fase de la transferencia entre la celula postsinaptica y presinaptica')

%% Guardamos data
paraguardar = [ffinal', HfinaldB', ArgHfinal'];
save('transferencia.txt', 'paraguardar', '-ASCII')

saveas(6,'HdBf.eps')
saveas(6,'HdBf.jpg')
saveas(6,'HdBf.fig')

saveas(7,'ArgHf.eps')
saveas(7,'ArgHf.jpg')
saveas(7,'ArgHf.fig')
