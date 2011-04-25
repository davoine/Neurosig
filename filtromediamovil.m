function [fmav] = filtromediamovil(fun, n, adelante)
%% Filtro de media móvil (MAV)
% Se le pasan los datos originales fun, la cantidad de puntos n
% y si es hacia adelante (a partir del punto n, promediando con los anteriores n-1 puntos)

fmav = fun; % Definimos la transferencia filtrada

if adelante
% sus primeros n valores quedaran igual
% en el siguiente for promediaremos los demas
	for k = n+1:length(fun)
	  sumf = 0; % inicializamos el promedio
	  for p = 1:n
		sumf = sumf + fun(k-p+1);
	  end
	  fmav(k) = sumf/n;
	end
else
% sus ultimos n valores quedaran igual
% en el siguiente for promediaremos los demas
	for k = 1:length(fun)-n
	  sumf = 0; % inicializamos el promedio
	  for p = 1:n
		sumf = sumf + fun(k+p-1);
	  end
	  fmav(k) = sumf/n;
	end
end
