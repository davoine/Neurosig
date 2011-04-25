function [tdec,fundec] = decimar12(t,fun,tdec1,tdec2,m)
%% Decima la funcion fun entre tdec1 y tdec2
% Devuelve el vector de tiempos y la función decimados
% [t,fun] es el par de vectores a decimar
% m es el orden del decimado (cada m valores se deja 1)
%% Encontramos los indices de las abscisas
itdecc1 = find(t>tdec1); % Vector con todos los indices desde tdec1
% Encontramos el indice desde donde empezamos a decimar
if isempty(itdecc1)
    itdec1 = 1;
else
    itdec1 = itdecc1(1);
end

itdecc2 = find(t>tdec2); % Vector con todos los indices desde tdec2
% Encontramos el indice hasta donde decimamos
if isempty(itdecc2)
    itdec2 = length(t);
else
    itdec2 = itdecc2(1);
end

%% Definimos los vectores finales decimados
% copiando los originales hasta el indice previo al decimado

for k =1:itdec1-1
  tdec(k) = t(k);
  fundec(k) = fun(k);
end

%% Decimamos
cont = itdec1; % inicializamos el contador sobre los nuevos vectores
p = 1;

for k=itdec1:itdec2-1
  if p == m
	tdec(cont) = t(k);
	fundec(cont) = fun(k);
	cont = cont + 1;
	p = 1;
  else p = p + 1;
  end
end

% copiando los originales desde el final del decimado
for k =itdec2:length(t)
  tdec(cont) = t(k);
  fundec(cont) = fun(k);
  cont = cont+1;
end
