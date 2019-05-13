% clear all 
 close all
%clc
tic

% CONSTANTES DEL PROBLEMA
datos.n_rotors = 4; %num de rotors
datos.DL = 80; % DL = W/A 
datos.W = 9.8 * ( 0.5+0.7*0.2);
datos.R = sqrt( datos.W / (datos.DL * pi)); %radi del rotor
datos.rho = 1.225; %densitat de l'aire [kg/m^3]

datos.Vc = 0.0; %Velocitat de climbing [m/s]
%datos.Vc = -2.5; %Velocitat de climbing [m/s]
%datos.Vc = -5.0; %Velocitat de climbing [m/s]
%datos.Vc = -7.5; %Velocitat de climbing [m/s]

datos.nb = 2; % num de pales

datos.Mtip = 0.5; 
datos.alt = 1500 + 30;
datos.T = 273 + 15 - (6.5/1000 * datos.alt); % ISA [K]
datos.Rg = 287; 
datos.gamma = 1.4;
datos.a = sqrt(datos.gamma * datos.Rg * datos.T);

datos.omega = datos.Mtip * datos.a / datos.R;

global inc_graus
    inc_graus = 0.1;
global delta 
    delta = 10^-3; % pel calcul de Velocitat induides (DEPEN BASTANT DE inc_graus)
global delta2 
    delta2 = 10^-4;

% VARIABLES
global aero
global solucio

%% --- INICI --------------------------------------------------------------

ent = 1;
AirfoilPlot(ent)
Corbes_Cl_Cd(ent)
Vi_MTH (datos)

datos.N = 100;
r_root = 0.01; % [m] => 1 cm
Y = linspace(r_root , datos.R , datos.N);
datos.Y = Y;
clear Y

for i=1:datos.N
   [ solucio.sigma(i) , solucio.theta(i) ]= BEM(datos,i);
end

BEM_lineal(datos)

%% Velocitat Induida, altra manera de ferho (sense solve)

for i=1:datos.N
[solucio.vi(i) solucio.lambda_i(i) solucio.phi_BEM(i) solucio.alpha_BEM(i) solucio.indice(i) ] = Vi_BEM2 (datos, solucio,i);
end

global Vi_tip
global Vi_root
Vi_tip = solucio.vi(datos.N);
Vi_root = solucio.vi(1);

for i=1:datos.N
%[solucio.vi_p(i) solucio.alpha_vi_p(i) ] = Vi_BEM2_Pr (datos, solucio,i);

phi = solucio.phi_BEM(i);
f_tip = datos.nb / 2 * ( 1 - datos.Y(i)/datos.R ) / ( (datos.Y(i)/datos.R) * sin(phi));
F_tip = 2/pi * acos( exp(-f_tip) );  

r_root = datos.Y(1)/datos.R;

f_root = datos.nb / 2 * ( datos.Y(i)/datos.R - r_root ) / ( (datos.Y(i)/datos.R) * sin(phi));
F_root = 2/pi * acos( exp(-f_root) );  

%F = F_tip;
F = F_tip*F_root;

solucio.vi_p(i) = solucio.vi(i) * F;

% CONSTRUIM SOLUCIO DE MTH
solucio.vi_m(i) = solucio.Vi_mth;
end

figure
plot(datos.Y/datos.R, solucio.vi_m); hold on; 
plot(datos.Y/datos.R, solucio.vi);  
plot(datos.Y/datos.R, solucio.vi_p); grid on;
title ('Velocitat inducida','Interpreter','latex','Fontsize',18);
xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
ylabel('Velocitat Inducida [m/s]','Interpreter','latex','Fontsize',16);
legend('MTH','BEM','BEM + Pérdidas','Location','Southwest');

%% TROBAR => Omega 

% EL ROTOR ES DISSENYA (corda, sigma...)  PER A Vc = 0, ara la omega variara

% fprintf(' \n \n    MTH -------- \n ');
% fprintf(' \n \n    BEM -------- \n');
 fprintf(' \n \n    BEM+perdidas -------- \n ');

Vcs = [0 2.5 5 7.5];

% Ara sigma es coneguda, la corda tambe
% La velocitat induida no

%[Omega] = NO_BEM (datos, solucio,i);
for i=1:length(Vcs)
    
    datos.Vc = Vcs(i);
    
    [Omega(i)] = NO_BEM2 (datos, solucio);
    
    solucio.omega = Omega(i);
    
    fprintf(' --- Velocidad de climbing: %f \n',datos.Vc);
    fprintf('Velocidad angular: %f \n',Omega(i));
    
    [Potencia(i) Pot_paras(i)] = Power (datos, solucio, Omega(i));

    fprintf('Potencia: %f \n',Potencia(i));
    fprintf('Potencia parasita: %f \n',Pot_paras(i));
    
end

figure;
plot (Omega,Potencia+Pot_paras);

disp('FIN');

toc

%% --- FINAL -------------------------------------------------------------

%% ----- FUNCIONES --------

function OMEGA = NO_BEM2 (datos, solucio)
global aero 

    Omegas = 1500:0.5:3000;
    
    % Ara es coneguda: theta, sigma
    % Vi ?
    
    delta = datos.R / datos.N;
    dif = 0; DIF = -1000;
    
    for i = 1:length(Omegas)
        Integral = 0;
            
            omega = Omegas(i);
            
            % Calculem la Vi en cada seccio
            for  j= 1:datos.N
                [ Vi_2(j) lambda_i_2(j) phi_2(j) alpha_2(j) ind_2(j) ] = Vi_BEM3 (datos, solucio, omega, j);
                
                % MTH
                
                
                % BEM+PERDUES (posar % quan no es vulgui fer perdues per estalviar calculs)
                
%                         phi = phi_2(j);
%                         f_tip = datos.nb / 2 * ( 1 - datos.Y(j)/datos.R ) / ( (datos.Y(j)/datos.R) * sin(phi));
%                         F_tip = 2/pi * acos( exp(-f_tip) );  
% 
%                         r_root = datos.Y(1)/datos.R;
% 
%                         f_root = datos.nb / 2 * ( datos.Y(j)/datos.R - r_root ) / ( (datos.Y(j)/datos.R) * sin(phi));
%                         F_root = 2/pi * acos( exp(-f_root) );  
% 
%                         %F = F_tip;
%                         F = F_tip*F_root;
% 
%                         solucio.vi_p(j) = Vi_2(j) * F;
%                 
%                 % BEM 
%                 r = datos.Y(j)/datos.R; 
%                 cl = aero.funcio_cl(ind_2(j));
%                 cd = aero.funcio_cd(ind_2(j));
%             
%                 lambda_c = datos.Vc/(omega*datos.R); %S'ha de calcular 
%                 
%                 phi = phi_2(j); %S'ha de calcular 
                
                %% CALCUL DE LAMBDA ( BEM i BEM + perdues, MTH a part)
                
                   %BEM
                lambda_i = lambda_i_2(j); %S'ha de calcular
                   %BEM + perdues
                %lambda_i = solucio.vi_p(j)/(omega*datos.R); 
                
                %%
                
                sigma = solucio.sigma_lin(j); %LA CALCULADA 
                chord = solucio.corda_lin(j); %LA CALCULADA 
                
                dFz = 1/2 * datos.rho * omega^2 * datos.R^2 ...
                *((r^2+(lambda_c + lambda_i)^2) * ...
                datos.nb * chord *(cl*cos(phi) - cd*sin(phi))) * datos.R;
            
                Integral = Integral + dFz * delta;
                
            end   
            
        pes = datos.W/4;
        dif = Integral - pes;
        
        if (abs(dif) < abs(DIF)) 
            omega_sol = Omegas(i);
            DIF = abs(dif);
        end    
    end
    
    OMEGA = omega_sol;
end

function [POTENCIA POT_PAR]= Power(datos,solucio, OMEGA)
global aero

    Integral = 0; Integral2 = 0; 
    delta = datos.R / datos.N;
    omega = OMEGA;
    
    for j = 1:datos.N
        
        r = datos.Y(j)/datos.R; 
        cl = aero.funcio_cl(solucio.indice(j));
        cd = aero.funcio_cd(solucio.indice(j));
        lambda_c = datos.Vc / (omega*datos.R);
        lambda_i = solucio.lambda_i(j);

            phi = solucio.phi_BEM(j);
            sigma = solucio.sigma_lin(j);
            chord = solucio.corda_lin(j);
            
            F=1;
            
            u = sqrt( (omega*datos.Y(j))^2 + (datos.Vc + solucio.vi(j))^2 );
            
            % De les diapos 
            dT = 2 * datos.rho * omega^2 * datos.R^2 * lambda_i * ...
                (lambda_c + lambda_i)* datos.R^2 * 2 * datos.Y(j)/datos.R;
            
            %dD = 1/2 * rho * u^2 * Cd * c
            dD_par = 1/2 * datos.rho* cd * u * chord ; 
        
        % Pot = dT * (Vc + Vi);
        Integral = Integral + dT * delta *(solucio.vi(j)+datos.Vc); 
        % Pot_para = dD * u;
        Integral2 = Integral2 + datos.nb*datos.n_rotors*(dD_par * u) * delta; 
        
    end
    POTENCIA = Integral;
    POT_PAR = Integral2;
end

function [Vi, LAMBDA, PHI, ALPHA, IND] = Vi_BEM3 (datos, solucio, omega, i)
global aero
global delta
global inc_graus

    alphas = -10:inc_graus:20;
    % xq = -rad2deg(pi/4):0.05:rad2deg(pi/4);
    lambda_c = datos.Vc / (omega*datos.R);
    r = datos.Y(i)/datos.R;
    
    dif = 0;  DIF = 1000;
    lambda_sol = 0;
    trobat = 0; 
    
    j = 1;
    
    while j <= length(alphas) && trobat == 0
        lambda_i = (tan( solucio.theta_lin(i) - deg2rad(alphas(j)) ) - lambda_c )* r;
        
        phi = atan((lambda_c+lambda_i)/r);
        
        cl = aero.funcio_cl(j); cd = aero.funcio_cd(j);
        
        num1 = 8*(lambda_i+lambda_c)*lambda_i*r;
        num2 = ((r^2+(lambda_c+lambda_i)^2)*(cl*cos(phi) - cd*sin(phi))) *solucio.sigma(i);
        
    dif = num1 - num2;

    if (abs(dif) < abs(DIF)) && lambda_i > 0 %% SI NO ENS QUEDEM AMB EL MÉS PETIT    
        lambda_sol = lambda_i;
       DIF = abs(dif);
       alpha_sol = alphas(j);
    end
    
       if (abs(dif) < delta)
           lambda_sol = lambda_i;
           alpha_sol = alphas(j); 
           phi_sol = phi; 
           trobat = 1;
           ind = j;
       end
    
        j=j+1;
    
    end
    
    Vi = lambda_sol*datos.omega*datos.R;
    ALPHA = alpha_sol;
    LAMBDA = lambda_sol;
    PHI = phi_sol;
    IND = ind;
end

function [Vi, LAMBDA, PHI, ALPHA, IND] = Vi_BEM2 (datos, solucio, i)
global aero
global inc_graus
global delta

    alphas = -10:inc_graus:20;
    % xq = -rad2deg(pi/4):0.05:rad2deg(pi/4);
    lambda_c = datos.Vc / (datos.omega*datos.R);
    r = datos.Y(i)/datos.R;
    
    dif = 0;  DIF = 1000;
    lambda_sol = 0;
    trobat = 0; 
    
    j = 1;
    
    while j <= length(alphas) && trobat == 0
        lambda_i = (tan( solucio.theta_lin(i) - deg2rad(alphas(j)) ) - lambda_c )* r;
        
        phi = atan((lambda_c+lambda_i)/r);
        
        %cl = pchip(aero.funcio_alpha,aero.funcio_cl , alphas(j)); %Interpola per trobar cl per aquell angle
        %cd = pchip(aero.funcio_alpha,aero.funcio_cd, alphas(j)); %Interpola per trobar cd per aquell angle
        
        % VA MOLT LENT AMB PCHIP = si els coeficients de alphes van igual en
        % aero.funcio_cl = puc fer cl(j) 
        % S'HA DE FER QUE ALPHAS = AERO.funcioalphas = OJOOOO!!
        
        cl = aero.funcio_cl(j); cd = aero.funcio_cd(j);
        
        num1 = 8*(lambda_i+lambda_c)*lambda_i*r;
        num2 = ((r^2+(lambda_c+lambda_i)^2)*(cl*cos(phi) - cd*sin(phi))) *solucio.sigma(i);
        
    dif = num1 - num2;

    if (abs(dif) < abs(DIF)) && lambda_i > 0 %% SI NO ENS QUEDEM AMB EL MÉS PETIT    
        lambda_sol = lambda_i;
       DIF = abs(dif);
       alpha_sol = alphas(j);
    end
    
       if (abs(dif) < delta)
           lambda_sol = lambda_i;
           alpha_sol = alphas(j); 
           phi_sol = phi; 
           trobat = 1;
           ind = j;
       end
    
        j=j+1;
    
    end
    
    Vi = lambda_sol*datos.omega*datos.R;
    ALPHA = alpha_sol;
    LAMBDA = lambda_sol;
    PHI = phi_sol;
    IND = ind;
end

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


% figure
% plot(datos.Y/datos.R, solucio.corda_lin*100); grid on;
% title ('Cuerda obtenida mediante método linealizado','Interpreter','latex','Fontsize',18);
% xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
% ylabel('Cuerda [cm]','Interpreter','latex','Fontsize',16);
% 
% 
% figure
% plot(datos.Y/datos.R, rad2deg(solucio.theta));
% hold on; grid on;
% plot(datos.Y/datos.R, rad2deg(solucio.theta_lin),'-.');
% title ('$$\theta$$ ideal y linealizada','Interpreter','latex','Fontsize',24);
% xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
% ylabel('$$\theta$$ [deg]','Interpreter','latex','Fontsize',16);
% legend('Ideal','Linealizada','Interpreter','latex','Fontsize',16);
% 
% 
% figure
% plot(datos.Y/datos.R,solucio.sigma);
% title ('$$\sigma$$ ideal y linealizada','Interpreter','latex','Fontsize',24);
% hold on;  grid on;
% plot(datos.Y/datos.R,solucio.sigma_lin,'-.');
% xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
% ylabel('$$\sigma$$','Interpreter','latex','Fontsize',16);
% legend('Ideal','Linealizada','Interpreter','latex','Fontsize',16);


% % figure
% % plot( datos.Y/datos.R , rad2deg(solucio.theta));
% % hold on;  grid on;
% % plot( datos.Y/datos.R , rad2deg(solucio.theta_lin),'-.');
% % title ('$$\theta$$ ideal','Interpreter','latex','Fontsize',20);
% % xlabel('r ($$ r = \frac{Y}{R}$$)','Interpreter','latex','Fontsize',16);
% % ylabel('$$\theta_{ideal}$$','Interpreter','latex','Fontsize',16);

end

function Vi_MTH (datos)
global solucio
    % T = datos.W;
    A = pi*datos.R^2;
    solucio.Vi_mth = sqrt(0.25*datos.W/(2 * datos.rho * A)); %0.25*W perque hi ha 4 rotors

end

function [SIGMA, THETA] = BEM (datos, i)
    global aero
    global solucio
    
    %sigma = dato.n*c / pi * R;
    
    lambda_i = solucio.Vi_mth / (datos.omega * datos.R);
    lambda_c = datos.Vc / (datos.omega * datos.R);
    r = datos.Y(i)/datos.R;
    alpha = aero.alp_opt;
    
    %alpha = theta - phi;
    
    THETA =  atan((lambda_c + lambda_i)/r) + deg2rad(alpha);
    
    PHI = atan((lambda_c + lambda_i)/r);
    
    %sigma/8*(r^2+(lambda_i + lambda_c)^2)*(cl*cos(theta) - cd*sin(theta)) = r*lamba_i*(lambda_c+lambda_i);
  
    cl = aero.cl_opt;
    cd = aero.cd_opt;
    
    %PHI = THETA - deg2rad(alpha);
    
    num = 8*(lambda_c+lambda_i)*lambda_i*r;
    den = (r^2+(lambda_i + lambda_c)^2)*(cl*cos(PHI) - cd*sin(PHI));
    
    SIGMA = num / den;
   
end

function Corbes_Cl_Cd (ent)
global aero
global inc_graus
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
    
   % fprintf('El coeficiente de cl_opt: %f y el Ã¡ngulo de alpha_opt: %f \n',aero.cl_opt, aero.alp_opt);
    
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
    %xq = -rad2deg(pi/4):0.01:rad2deg(pi/4);
    xq = -10:inc_graus:20; % HO CANVIO = TENIR EN COMPTE PER ALPHAS
    
    %x_d = -rad2deg(pi/4):0.01:rad2deg(pi/4);
    aero.funcio_cl = pchip(new_alpha,new_cl,xq);
    aero.funcio_cd = pchip(new_alpha,new_cd,xq);
    aero.funcio_cdp = pchip(new_alpha,new_cd,xq);
    aero.funcio_alpha = xq;
    
%     figure;
%     plot(new_alpha,new_cl,'-.','Color','k');
%     title ('$$C_l$$ vs $$\alpha$$','Interpreter','latex','Fontsize',24);
%     hold on;  grid on;
%     plot(aero.alpha,aero.cl,'b');
%     xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',20);
%     ylabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
%     plot(aero.funcio_alpha,aero.funcio_cl,'*r');
%     legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
%     
%     figure;
%     plot(new_alpha,new_cd,'-.','Color','k');
%     title ('$$C_d$$ vs $$\alpha$$','Interpreter','latex','Fontsize',24);
%     hold on; grid on;
%     plot(aero.alpha,aero.cd,'b');
%     xlabel('$$\alpha$$ [$$^o$$]','Interpreter','latex','Fontsize',20);
%     ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
%     plot(aero.funcio_alpha,aero.funcio_cd,'*r');
%     legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
%     
%     figure;
%     plot(new_cl,new_cd,'-.','Color','k');
%     title ('$$C_d$$ vs $$C_l$$','Interpreter','latex','Fontsize',24);
%     hold on; grid on;
%     plot(aero.cl,aero.cd,'b');
%     xlabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
%     ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
%     plot(aero.funcio_cl,aero.funcio_cd,'*r');
%     legend('Modified','Original','PCHIP','Interpreter','latex','Fontsize',14)
%     
%     figure;
%     plot(aero.cl,aero.cd,'b');
%     title ('$$C_d$$ vs $$C_l$$','Interpreter','latex','Fontsize',24);
%     xlabel('Lift coefficient $$C_l$$','Interpreter','latex','Fontsize',20);
%     ylabel('Drag coefficient $$C_d$$','Interpreter','latex','Fontsize',20);
%     grid on;
%         
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


% figure;
% plot(airfoil_up(:,1),airfoil_up(:,2),'b');
% hold on; axis equal; grid on;
% plot(airfoil_low(:,1),airfoil_low(:,2),'b');
% xlim([-0.1 1.1]);
% 
% title ('Airfoil SC2110','Interpreter','latex','Fontsize',24);
% xlabel('X-axis [m]','Interpreter','latex','Fontsize',12);
% ylabel('Y-axis [m]','Interpreter','latex','Fontsize',12);
% %axis off;
end
