clear all
close all
clc

% CONSTANTES DEL PROBLEMA
datos.n_rotors = 4; %num de rotors
datos.DL = 80;
datos.W = 9.8 * (0.5+0.7*0.2);
datos.R = sqrt(datos.W / (datos.DL * pi)); %radi del rotor
datos.rho = 1.225; %densitat de l'aire [kg/m^3]
datos.Vc = 0; %Velocitat de climbing [m/s]
datos.nb = 2; % num de pales

datos.Mtip = 0.5; 
datos.alt = 1500 + 30;
datos.T = 273 + 15 - (6.5/1000 * datos.alt); % ISA [K]
datos.Rg = 287; 
datos.gamma = 1.4;
datos.a = sqrt(datos.gamma * datos.Rg * datos.T);

datos.omega = datos.Mtip * datos.a / datos.R;

% VARIABLES
global aero
aero.cl = [];
aero.cd = [];
aero.cdp = [];
aero.cm = [];
aero.alpha = [];

global param
param.cl_opt = 0;
param.alp_opt = 0;
param.Vi = 0;

global solucio

ent = 1;
AirfoilPlot(ent)
Corbes_Cl_Cd(ent)
Vi_MTH (datos)


datos.N = 17;
r_root = 0.005;
Y = linspace(r_root,datos.R,datos.N);

for i=1:datos.N
    [ solucio.sigma(i) , solucio.theta(i) ]= BEM(datos,Y(i));
end



datos.Y = Y;
clear Y

BEM_lineal(datos)
prandtl=true;

for i=1:datos.N
[solucio.vi(i), solucio.vi_p(i)] = Vi_BEM (datos, solucio,i,prandtl);
end

figure
plot(datos.Y/datos.R, solucio.vi); hold on;
plot(datos.Y/datos.R, solucio.vi_p);
title ('Velocitat induida','Interpreter','latex','Fontsize',18);
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('Velocitat Induida [m/s]','Interpreter','latex','Fontsize',16);
legend('Velocitat induida ideal','Velocitat induida amb correcció per efectes de Prandtl');



%% OPERACION Omega 

% Ara sigma es coneguda, la corda tambe
% La velocitat induida no

  [Omega] = NO_BEM (datos, solucio,i);


function [Omega] = NO_BEM (datos, solucio,i) 
delta=10;
delta_p=10;
omega_ant=datos.omega;%suposem una omega inicial
while delta>10^-3 && delta_p>10^-3
omega=omega_ant;
sumatori=0;  
sumatori_p=0;
r = datos.Y/datos.R;
lambda_Vc=datos.Vc/(omega*datos.R);
lambda_Vi=solucio.vi/(omega*datos.R);
alpha = solucio.theta_lin -  atan((lambda_Vc+lambda_Vi)/r);
cl = pchip(aero.funcio_alpha,aero.funcio_cl , alpha);
cd = pchip(aero.funcio_alpha,aero.funcio_cd, alpha);
phi = atan((lambda_Vc+lambda_Vi)/r);
for i=1:datos.N
sumatori=sumatori+(solucio.sigma(i)*(datos.Y(i)^2+(lambda_Vc+lambda_Vi(i))^2)*(cl(i)*cos(phi(i))+cd(i)*sin(phi(i))))
end
syms om
eq = 0.5*datos.nb*datos.R^4*pi*om*sumatori==0.25*datos.W*0.981
omega_ant = solve(eq,om);
delta = abs(omega-omega_ant);
end
disp(omega_ant)

%Omega = 0:1:5000;
%disp('aqui');
%fun = int(dFz) - W; 

end




%% --- FUNCIONES ---

function BEM_lineal (datos)

global solucio

for i=1:datos.N
    if ( datos.Y(i)/datos.R > 0.69 && datos.Y(i)/datos.R < 0.73)
        m_1 = ( solucio.theta(i+1) - solucio.theta(i)) / (( datos.Y(i+1) - datos.Y(i))/datos.R);
        m_2 = ( solucio.sigma(i+1) - solucio.sigma(i)) / (( datos.Y(i+1) - datos.Y(i))/datos.R);
        solucio.theta_7 = solucio.theta(i);
        solucio.sigma_7 = solucio.sigma(i);
    end
end

for i=1:datos.N

   solucio.theta_lin(i) =  solucio.theta_7 + m_1 * (datos.Y(i)/datos.R-0.7);
   solucio.sigma_lin(i) = solucio.sigma_7 + m_2 * (datos.Y(i)/datos.R-0.7);
   solucio.corda_lin(i) = solucio.sigma_lin(i)*datos.R*pi / datos.nb; %Massa petites? Si son massa petites augmentar-les. 

end


figure
plot(datos.Y/datos.R, solucio.corda_lin*100); grid on;
title ('Cuerda obtenida mediante método linealizado','Interpreter','latex','Fontsize',18);
xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
ylabel('Cuerda [cm]','Interpreter','latex','Fontsize',16);


figure
plot(datos.Y/datos.R, rad2deg(solucio.theta));
hold on; grid on;
plot(datos.Y/datos.R, rad2deg(solucio.theta_lin),'-.');
title ('$$\theta$$ ideal y linealizada','Interpreter','latex','Fontsize',24);
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('$$\theta$$ [deg]','Interpreter','latex','Fontsize',16);
legend('Ideal','Linealizada','Interpreter','latex','Fontsize',16);


figure
plot(datos.Y/datos.R,solucio.sigma);
title ('$$\sigma$$ ideal y linealizada','Interpreter','latex','Fontsize',24);
hold on;  grid on;
plot(datos.Y/datos.R,solucio.sigma_lin,'-.');
xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
ylabel('$$\sigma$$','Interpreter','latex','Fontsize',16);
legend('Ideal','Linealizada','Interpreter','latex','Fontsize',16);


figure
plot( datos.Y/datos.R , rad2deg(solucio.theta));
hold on;  grid on;
plot( datos.Y/datos.R , rad2deg(solucio.theta_lin),'-.');
title ('$$\theta$$ ideal','Interpreter','latex','Fontsize',20);
xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
ylabel('$$\theta_{ideal}$$','Interpreter','latex','Fontsize',16);

end

function Vi_MTH (datos)
global param
    % T = datos.W;
    A = pi*datos.R^2;
    param.Vi = sqrt(0.25*datos.W*9.81/(2 * datos.rho * A)); %0.25*W perque hi ha 4 rotors

end



function [velocitat,velocitat_p] = Vi_BEM (datos,solucio,i,prandtl)
delta = 10;
i 
lambda_i = 3.5; %Per iniciar la iteracio suposem una lambda_i inicial

while delta>10e-2
global aero
syms lamb
lambda_c = datos.Vc/(datos.omega*datos.R);
r = datos.Y(i)/datos.R;
alpha = solucio.theta_lin(i) -  atan((lambda_c+lambda_i)/r);
cl = pchip(aero.funcio_alpha,aero.funcio_cl , alpha);
cd = pchip(aero.funcio_alpha,aero.funcio_cd, alpha);
phi = atan((lambda_c+lambda_i)/r);
f = datos.nb/2*(1-datos.Y(i)/datos.R)/((datos.Y(i)/datos.R)*phi);
F = 2/pi*acos(exp(-f));


eqn = 8*(lamb+lambda_c)*lamb*r == (r^2+(lambda_c+lamb)^2)*(cl*cos(atan((lambda_c+lamb)/r) )-...
    cd*sin(atan((lambda_c+lamb)/r)) )*solucio.sigma(i);

sol = solve(eqn,lamb);
    
for j=1:length(sol)
    bool = isreal(double(sol(j)));
    if bool == 1
        sol_bona = double(sol(j));
    end
end

delta = abs(double(sol_bona)-lambda_i);
lambda_i = double(sol_bona);

end

if prandtl == true
delta_p=10;
lambda_p = 3.5;

while delta_p>10e-2
global aero
syms lamb
lambda_c = datos.Vc/(datos.omega*datos.R);
r = datos.Y(i)/datos.R;
alpha = solucio.theta_lin(i) -  atan((lambda_c+lambda_i)/r);
cl = pchip(aero.funcio_alpha,aero.funcio_cl , alpha);
cd = pchip(aero.funcio_alpha,aero.funcio_cd, alpha);
phi = atan((lambda_c+lambda_i)/r);
f = datos.nb/2*(1-datos.Y(i)/datos.R)/((datos.Y(i)/datos.R)*phi);
F = 2/pi*acos(exp(-f));
eqn_p = 8*F*(lamb+lambda_c)*lamb*r == (r^2+(lambda_c+lamb)^2)*(cl*cos(atan((lambda_c+lamb)/r) )-...
    cd*sin(atan((lambda_c+lamb)/r)) )*solucio.sigma(i);
sol_p = solve(eqn_p,lamb);

for k=1:length(sol_p)
    bool = isreal(double(sol_p(k)));
    if bool == 1
        sol_bona_p = double(sol_p(k));
    end
end
delta_p = abs(double(sol_bona_p)-lambda_p);
lambda_p = double(sol_bona_p);
end

end

velocitat = lambda_i*datos.omega*datos.R;
velocitat_p = 0;
if prandtl == true
velocitat_p = lambda_p*datos.omega*datos.R;
end

end


function [SIGMA, THETA] = BEM (datos, Y, param)
    global param
    global aero

    %sigma = dato.n*c / pi * R;
    
    lambda_i = param.Vi/ (datos.omega * datos.R);
    Vc = 0;
    lambda_c = Vc/ (datos.omega * datos.R);
    r = Y/datos.R;
    alpha = param.alp_opt;
    
    %alpha = theta - phi;
    
    THETA =  atan((lambda_c + lambda_i)/r) + deg2rad(alpha);
    
    %sigma/8*(r^2+(lambda_i + lambda_c)^2)*(cl*cos(theta) - cd*sin(theta)) = r*lamba_i*(lambda_c+lambda_i);
    
    for k=1:length(aero.alpha)
        if aero.alpha(k) == aero.alp_opt
           trobat = k;
        end    
    end
    
    PHI = THETA - alpha;
    
    SIGMA = r*lambda_i*(lambda_c+lambda_i)/((r^2+(lambda_i + lambda_c)^2)...
        *(aero.cl(k)*cos(PHI) - aero.cd(k)*sin(PHI)))*8;
   
end

function Corbes_Cl_Cd (ent)
global aero

coef = dlmread('Polar_SC2110.dat');
    
    %   alpha    CL        CD       CDp       CM     Top_Xtr  Bot_Xtr
    
    aero.alpha = coef(:,1);
    aero.cl = coef(:,2);
    aero.cd = coef(:,3);
    aero.cdp = coef(:,4);
    aero.cm = coef(:,5);
    aero.clalpha = (aero.cl(90)-aero.cl(32))/(deg2rad(aero.alpha(90))-deg2rad(aero.alpha(32))); %dona 5.8 que es resultat abstant bo
    cl_cd_max = 0;
    %aero.cdmin = min(aero.cd);
    for i = 1:size(aero.cd)
        if aero.cl(i)/aero.cd(i) > cl_cd_max
            cl_cd_max = aero.cl(i)/aero.cd(i);
            aero.cl_opt = aero.cl(i);
            aero.cd_opt = aero.cd(i);
            aero.alp_opt = aero.alpha(i);
        end
    end    
    
    fprintf('El coeficiente de cl_opt: %f  y el Ã¡ngulo de alpha_opt: %f \n',aero.cl_opt, aero.alp_opt);
    
%     figure;
%     plot(alpha,cl);
%     title ('$$C_l$$ vs $$\alpha$$','Interpreter','latex','Fontsize',16);
%     xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',12);
%     ylabel('Lift coeficient $$C_l$$','Interpreter','latex','Fontsize',12);
    
%     figure;
%     plot(cd,cl);
%     title ('Polar plot','Interpreter','latex','Fontsize',16);
%     xlabel('Lift coeficient $$C_l$$','Interpreter','latex','Fontsize',12);
%     ylabel('Drag coeficient $$C_d$$','Interpreter','latex','Fontsize',12);
%     
%     figure;
%     plot(cdp,alpha);
%     title ('$$C_{dp}$$ vs $$\alpha$$','Interpreter','latex','Fontsize',16);
%     xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',12);
%     ylabel('Parasit Drag coeficient $$C_l$$','Interpreter','latex','Fontsize',12);
    
    % Ens inventem punts per cl i cd per alpha propers a pi/2 ==> de cara
    % al fsolve (que segons el profe dona errors) a banda i banda per
    % utilitzar el comando PCHIP que serveix per interpolar 
    
    n = length(aero.cl);
    
    new_alpha(1) = -45; new_cl(1) = -0.0; new_cd(1) = 1;
    new_alpha(2) = -45+5; new_cl(2) = -0.1; new_cd(2) = 0.7;
    new_alpha(3) = -45+10; new_cl(3) = -0.2; new_cd(3) = 0.3;
    
    for i=4:length(aero.alpha)+3
       new_alpha (i) = aero.alpha(i-3); 
       new_cl(i) = aero.cl(i-3);
       new_cd(i) = aero.cd(i-3);
    end
    
    N = length(new_alpha);
    
    new_alpha(N+1) = 45-15; new_cl(N+1) = 0.5; new_cd(N+1) = 0.3;
    new_alpha(N+2) = 45-5; new_cl(N+2) = 0.1; new_cd(N+2) = 0.7;
    new_alpha(N+3) = 45; new_cl(N+3) = 0.0; new_cd(N+3) = 1;
    
    aero.new_cl =new_cl;
    aero.new_alpha =new_alpha;
    aero.new_cd =new_cd;
    
    % Definim les funcions amb PCHIP
    xq = -rad2deg(pi/4):0.05:rad2deg(pi/4);
    %x_d = -rad2deg(pi/4):0.01:rad2deg(pi/4);
    aero.funcio_cl = pchip(new_alpha,new_cl,xq);
    aero.funcio_cd = pchip(new_alpha,new_cd,xq);
    aero.funcio_alpha = xq;
    
    figure;
    plot(new_alpha,new_cl,'-.','Color','k');
    title ('$$C_l$$ vs $$\alpha$$','Interpreter','latex','Fontsize',24);
    hold on;  grid on;
    plot(aero.alpha,aero.cl,'b');
    xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',20);
    ylabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
    plot(aero.funcio_alpha,aero.funcio_cl,'*r');
    legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
    
    figure;
    plot(new_alpha,new_cd,'-.','Color','k');
    title ('$$C_d$$ vs $$\alpha$$','Interpreter','latex','Fontsize',24);
    hold on; grid on;
    plot(aero.alpha,aero.cd,'b');
    xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',20);
    ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
    plot(aero.funcio_alpha,aero.funcio_cd,'*r');
    legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
    
    figure;
    plot(new_cl,new_cd,'-.','Color','k');
    title ('$$C_d$$ vs $$C_l$$','Interpreter','latex','Fontsize',24);
    hold on; grid on;
    plot(aero.cl,aero.cd,'b');
    xlabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
    ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
    plot(aero.funcio_cl,aero.funcio_cd,'*r');
    legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
    
    figure;
    plot(aero.cl,aero.cd,'b');
    title ('$$C_d$$ vs $$C_l$$','Interpreter','latex','Fontsize',24);
    xlabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
    ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
    grid on;
    
    
    %clear aero.alpha 
    %aero.alpha = new_alpha;
    %aero.cl = new_cl;
    
    
    %{
    figure;
    plot(new_cl,new_cd,'-.','Color','b');
    title ('$$C_l$$ vs $$\alpha$$ modified','Interpreter','latex','Fontsize',16);
    hold on;
    plot(cl,cd,'b');
    legend('Modified','Original')
     title ('Polar plot','Interpreter','latex','Fontsize',16);
     xlabel('Lift coeficient $$C_l$$','Interpreter','latex','Fontsize',12);
     ylabel('Drag coeficient $$C_d$$','Interpreter','latex','Fontsize',12);
    %}
    
    
    
    
end


function AirfoilPlot (ent)
Airfoil = dlmread('airfoil_SC2110_coord.dat');

k=1; 
j=1; 
cont = 0;

for i=1:size(Airfoil,1)
    
    
    if (Airfoil(i,1) > -0.001 && Airfoil(i,1) < 0.001)
       cont =cont+1;
    end
    
    if cont == 1
       airfoil_up(j,1) = Airfoil(i,1);
       airfoil_up(j,2) = Airfoil(i,2);
       j=j+1;
    else 
       airfoil_low(k,1) = Airfoil(i,1);
       airfoil_low(k,2) = Airfoil(i,2);
       k=k+1;
    end
    

end


figure;
plot(airfoil_up(:,1),airfoil_up(:,2),'b');
hold on; axis equal; grid on;
plot(airfoil_low(:,1),airfoil_low(:,2),'b');
xlim([-0.1 1.1]);

title ('Airfoil SC2110','Interpreter','latex','Fontsize',24);
xlabel('X-axis [m]','Interpreter','latex','Fontsize',12);
ylabel('Y-axis [m]','Interpreter','latex','Fontsize',12);
%axis off;
end
