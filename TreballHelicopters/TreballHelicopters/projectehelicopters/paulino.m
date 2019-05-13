clc;close all; clear;
syms r % All in function of radio
%% Introduccio manual
%prompt = 'Indiqui el numero de elements que vols per a simular la corda : ';
%elements = input(prompt);
%nodes = elements + 1;
%prompt = 'Introdueixi el Cl optim : '; % Aleix 0,9 aprox -> tram lineal
cl_optim = 0.6;
%prompt = 'Introdueixi el Cd : '; % 0,01 !!! Ull necessitaria + precissio a la grafica
cd = 0.03;
%prompt = 'Introdueixi el alpha optim en graus : '; % Aleix uns 8 º
alpha_optim = (10)*pi/180; %radiants
%% Dades
EW = 10; %KG
MPL = 30; %KG
R = 0.5; %m
elements=100;
incr_r = 1/elements; % Increment de r en la corda adimensionalitzada
h = 2000; %m
altura = 300; %m
carrega_vol_disseny = 0.5; %tant per 1
n_pales = 2; % a reconsiderar
gravetat = 9.81; %N/kg
Mtip = 0.5;
jamma = 1.4;
%Calcul densitat ISA 2300
densitat_1981 = 0.8232*1.225;
densitat_2438 = 0.7860*1.225;
densitat_2300 = densitat_1981+((densitat_2438 - densitat_1981)/(2438-1981))*(2300-1981); %Surt d'interpolar la taula
%Calcul temperatura ISA 2300
temperatura_1981 = 2.3+273.15; %K
temperatura_2438 = -0.6+273.15; %K
temperatura_2300 = temperatura_1981+((temperatura_2438 - temperatura_1981)/(2438-1981))*(2300-1981);  %Surt d'interpolar la taula
%V_punta
V_punta = Mtip*sqrt(jamma*286.68*temperatura_2300);
%% Rotor Ideal
Vi = sqrt((EW+MPL*carrega_vol_disseny)*gravetat/(2*densitat_2300*pi*4*R^2)); %Vi constant
Omega = (sqrt((V_punta^2)-(Vi^2)))/R; %Omega
%Suposem que en vol ideal de disseny la V_ascens = 0 ---> Vol punt fix
% Mirem si el angle phi es petit
lambda_i = Vi/(Omega*R);
phi_r =atan(lambda_i/r); %radians
phi_r1 = atan(lambda_i/0.7); %radians
phi_r1_graus = phi_r1*180/pi; %-> Surt 3.12 º. O sigui es pot considerar angles petits
%% Continuem : ( amb for )
%sigma = zeros(1,nodes);
%corda = zeros(1,nodes);
%tita = zeros(1,nodes);
%r=0.000000000001;
%for e=1:nodes
%    sigma(1,e) = (8*lambda_i^2)/(cl_optim*r);
%    corda(1,e) = (sigma(1,e)*pi*R)/(n_pales);
%    tita(1,e) = alpha_optim + atan(lambda_i/r);
%    r = r+incr_r;
%end
%% Continuem : ( amb r variable )
sigma = (8*r*lambda_i^2)/(((r^2)+lambda_i^2)*(cl_optim*cos(phi_r)-cd*sin(phi_r)));
corda = (sigma*pi*R)/(n_pales);
tita = alpha_optim + atan(lambda_i/r);
