clc;close all; clear all;
syms r % All in function of radio
%% Introduccio manual
%prompt = 'Indiqui el numero de elements que vols per a simular la corda : ';
%elements = 100;%text
%nodes = elements + 1;%text
%prompt = 'Introdueixi el Cl optim : '; % Aleix 0,9 aprox -> tram lineal
cl_optim = 0.6163;
%prompt = 'Introdueixi el Cd : '; % 0,01 !!! Ull necessitaria + precissio a la grafica
cd = 0.01432;
%prompt = 'Introdueixi el alpha optim en graus : '; % Aleix uns 8 º
alpha_optim = (5)*pi/180; %radiants 
%% Dades
EW = 10; %KG 
MPL = 30; %KG 
R = 0.5; %m 
%elements=100;
%incr_r = 1/elements; % Increment de r en la corda adimensionalitzada
h = 2000; %m
altura = 300; %m
carrega_vol_disseny = 0.5; %tant per 1
n_pales = 2; % a reconsiderar
gravetat = 9.81; %N/kg
Mtip = 0.5;
jamma = 1.4;

%PAULINO
%{
%Calcul densitat ISA 2300
densitat_1981 = 0.8232*1.225;
densitat_2438 = 0.7860*1.225;
densitat_2300 = densitat_1981+((densitat_2438 - densitat_1981)/(2438-1981))*(2300-1981); %Surt d'interpolar la taula
%Calcul temperatura ISA 2300
temperatura_1981 = 2.3+273.15; %K
temperatura_2438 = -0.6+273.15; %K
temperatura_2300 = temperatura_1981+((temperatura_2438 - temperatura_1981)/(2438-1981))*(2300-1981);  %Surt d'interpolar la taula
%}

%NURIA
theta=1-22.56e-6*h;
rho= 1.225*theta^4.256;%densitat a 2000 metres
temperatura=288.15*theta; %temperatura a 2000 metres
%V_aire
V_tip = Mtip*sqrt(jamma*286.68*temperatura);
%% Rotor Ideal
Vi = sqrt((EW+MPL*carrega_vol_disseny)*gravetat/(2*rho*pi*4*R^2)); %Vi constant
Omega = (sqrt((V_tip^2)-(Vi^2)))/R; %Omega--paulino
%Omega=V_tip/R;%Omega--nuria
%Suposem que en vol ideal de disseny la V_ascens = 0 ---> Vol punt fix
% Mirem si el angle phi es petit
lambda_i = Vi/(Omega*R);
phi_r =atan(lambda_i/r); %radians
phi_r1 = atan(lambda_i/0.7); %radians
phi_r1_graus = phi_r1*180/pi; %-> Surt 3.12 º. O sigui es pot considerar angles petits

%% Continuem : ( amb r variable ) paulino
%{
sigma = (8*r*lambda_i^2)/(((r^2)+lambda_i^2)*(cl_optim*cos(phi_r)-cd*sin(phi_r)));
%representacio gràfica de sigma(rotor ideal)

figure(1);
ezplot(sigma,[0,1]);

corda = (sigma*pi*R)/(n_pales);
tita = alpha_optim + atan(lambda_i/r);

%representacio gràfica de tita rotor ideal
figure(2);
ezplot(tita,[0,1]);
%}

%% Linealitzacio tita i sigma nuria
%calcul tita1
syms x y 
tita = alpha_optim + atan(lambda_i/x);
deriv_tita=diff(tita);
tita1=inline(deriv_tita);
x=0.7;
tita1=tita1(x);
%calcul tita 0
tita_ideal= alpha_optim + atan(lambda_i/0.7);
tita0=tita_ideal-tita1*0.7;
%-----------------------------------
%representacio linealitzada
figure(1);
f1=tita0+tita1*r;
ezplot(f1,[0,1]);
hold on;
%representacio tita ideal
tita = alpha_optim + atan(lambda_i/r);
ezplot(tita,[0,1]); %si fem fplot qued amés ampliat, nose quina preferiu posar!!
title('\theta(r) segons rotor ideal i segons llei linealitzada. ')
legend('\theta_{linealitzada}','\theta_{ideal}')

%---------------------------------------
%--------------------------------------
%calcul sigma1
phi_r =atan(lambda_i/y);
sigma = (8*y*lambda_i^2)/(((y^2)+lambda_i^2)*(cl_optim*cos(phi_r)-cd*sin(phi_r)));
deriv_sigma=diff(sigma);
sigma1=inline(deriv_sigma);
y=0.7;
sigma1=sigma1(y);
%calcul sigma 0
sigma_ideal=(8*0.7*lambda_i^2)/(((0.7^2)+lambda_i^2)*(cl_optim*cos(phi_r1)-cd*sin(phi_r1)));
sigma0=sigma_ideal-sigma1*0.7;
%-----------------------------------
%representacio linealitzada
figure(2);
f2=sigma0+sigma1*r;
ezplot(f2,[0,1]);
hold on;
%representacio ideal
phi_r =atan(lambda_i/r);
sigma = (8*r*lambda_i^2)/(((r^2)+lambda_i^2)*(cl_optim*cos(phi_r)-cd*sin(phi_r)));
ezplot(sigma,[0,1]);
title('\sigma(r) segons rotor ideal i segons llei linealitzada. ')
legend('\sigma_{linealitzada}','\sigma_{ideal}')
%------------------------------------
%--------------------------------------
%representacio corda linealitzada
f3= (f2*pi*R)/(n_pales);
figure(3);
ezplot(f3,[0,1]);
title('c(r) segons llei linealitzada. ')

% Pi = 2*rho*pi*(R^2)*Vi^3;% Potència ideal=potència total
% corda=(sigma*pi*R)/(n_pales);
% dFx_dr = 0.5*rho*((Omega*R)^2)*((r^2)+lambda_i^2)*corda*n_pales*R*(cl_optim*sin(phi_r)+cd*cos(phi_r));
% figure(4);
% ezplot(dFx_dr,[0,1]);
% title('dFx/dr en MTH');
%% Continuem : ( amb for ) paulino
%{
sigma = zeros(1,nodes);
corda = zeros(1,nodes);
tita = zeros(1,nodes);
r=0.000000000001;
for e=1:nodes
    sigma(1,e) = (8*lambda_i^2)/(cl_optim*r);
   corda(1,e) = (sigma(1,e)*pi*R)/(n_pales);
   tita(1,e) = alpha_optim + atan(lambda_i/r);
    r = r+incr_r;
end
%}
