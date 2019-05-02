clear all
close all
clc

% CONSTANTES DEL PROBLEMA
datos.n_rotors = 4; %núm de rotors
datos.DL = 25;
datos.W = 0.5*10000;
datos.R = sqrt(datos.W / (datos.DL * pi)); %radi del rotor
datos.rho = 1.225; %densitat de l'aire [kg/m^3]
datos.Vc = 5; %Velocitat de climbing [m/s]
datos.nb = 2; % num de pales

datos.Mtip = 0.5; 
datos.T = 288.15; % ISA
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

ent = 1;
AirfoilPlot(ent)
Corbes_Cl_Cd(ent)
Vi_MTH (datos)


datos.N = 200;
r_root = 0.5;
Y = linspace(r_root,datos.R,datos.N);

for i=1:datos.N
    [ solucio.sigma(i) , solucio.theta(i) ]= BEM(datos,Y(i));
end

datos.Y = Y;
clear Y

for i=1:datos.N
 solucio.vi(i) = Vi_BEM (datos, solucio,i);
end

%% FEM DERIVADA

for i=1:datos.N
    if ( datos.Y(i)/datos.R > 0.69 && datos.Y(i)/datos.R < 0.71)
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
plot(datos.Y/datos.R, solucio.corda_lin*100);
title ('$$\sigma$$ linealitzada y ideal','Interpreter','latex','Fontsize',18);
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('cuerda linealizada [cm]','Interpreter','latex','Fontsize',16);


figure
plot(datos.Y/datos.R, rad2deg(solucio.theta_lin));
hold on
plot(datos.Y/datos.R, rad2deg(solucio.theta));

title ('$$\sigma$$ linealitzada y ideal','Interpreter','latex','Fontsize',18);
hold on;
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('$$\sigma_{ideal}$$','Interpreter','latex','Fontsize',16);
legend('Linealitzada','Ideal','Interpreter','latex');







figure
plot(datos.Y/datos.R,solucio.sigma);
title ('$$\sigma$$ ideal','Interpreter','latex','Fontsize',18);
hold on;
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('$$\sigma_{ideal}$$','Interpreter','latex','Fontsize',16);


figure
plot( datos.Y/datos.R , rad2deg(solucio.theta) );
title ('$$\theta$$ ideal','Interpreter','latex','Fontsize',18);
hold on;
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('$$\theta_{ideal}$$','Interpreter','latex','Fontsize',16);


figure
plot(datos.Y/datos.R, solucio.vi);
title ('Velocitat induida','Interpreter','latex','Fontsize',18);
xlabel('R','Interpreter','latex','Fontsize',16);
ylabel('Velocitat Induida [m/s]','Interpreter','latex','Fontsize',16);

%%% FUNCIONES


function Vi_MTH (datos)
global param
    % T = datos.W;
    A = pi*datos.R^2;
    param.Vi = sqrt(datos.W/(2 * datos.rho * A));

end

function velocitat = Vi_BEM (datos,solucio,i)
global aero

lambda = solucio.sigma(i)*aero.clalpha/16*(sqrt(1+32/(solucio.sigma(i)... %% Ha de ser CL_alfa no Cl
    *aero.clalpha)*solucio.theta(i)*datos.Y(i)/datos.R)-1);
velocitat = lambda*datos.omega*datos.R;
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
    
    SIGMA = r*lambda_i*(lambda_c+lambda_i)/((r^2+(lambda_i + lambda_c)^2)...
        *(aero.cl(k)*cos(THETA) - aero.cd(k)*sin(THETA)))*8;
   
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
    aero.clalpha = (aero.cl(90)-aero.cl(32))/(deg2rad(aero.alpha(90))-deg2rad(aero.alpha(32)));
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
    
    fprintf('El coeficiente de cl_opt: %f  y el ángulo de alpha_opt: %f \n',aero.cl_opt, aero.alp_opt);
    
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
    
    new_alpha(1) = -45; new_cl(1) = -0.0; new_cd(1) = -0.0;
    new_alpha(2) = -45+5; new_cl(2) = -0.1; new_cd(2) = -0.0;
    new_alpha(3) = -45+10; new_cl(3) = -0.2; new_cd(3) = -0.0;
    
    for i=4:length(aero.alpha)+3
       new_alpha (i) = aero.alpha(i-3); 
       new_cl(i) = aero.cl(i-3);
       new_cd(i) = aero.cd(i-3);
    end
    
    N = length(new_alpha);
    
    new_alpha(N+1) = 45-15; new_cl(N+1) = 0.5; new_cd(N+1) = 0.0;
    new_alpha(N+2) = 45-5; new_cl(N+2) = 0.1; new_cd(N+2) = 0.0;
    new_alpha(N+3) = 45; new_cl(N+3) = 0.0; new_cd(N+3) = 0.0;
   
    figure;
    plot(new_alpha,new_cl,'-.','Color','b');
    title ('$$C_l$$ vs $$\alpha$$ modified','Interpreter','latex','Fontsize',16);
    hold on;
    plot(aero.alpha,aero.cl,'b');
    legend('Modified','Original')
    xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',12);
    ylabel('Lift coeficient $$C_l$$','Interpreter','latex','Fontsize',12);
    
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

title ('Airfoil SC2110','Interpreter','latex','Fontsize',16);
xlabel('X-axis [m]','Interpreter','latex','Fontsize',12);
ylabel('Y-axis [m]','Interpreter','latex','Fontsize',12);
end