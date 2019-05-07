%mass=10+15; %massa de l'aeronau desitjada en kg
%radi=0.5; %radi del rotor en metres
%noves dades joan
mass=3.5;
radi=0.2;
altitud=2000;%alitiud de vol en m
Mtip=0.5; %mach a punta de pala
compressibilitat=false;%si es vol fer correció per compressibilitat o prandtl posar true, sinó posar false
prandtl=false;
vclimb=0;
theta0=0.2222;  %valors d'angle (en radians) i sigma ja linealitzats 
theta1=-0.0714;
sigma0=0.0349;
sigma1=-0.0249;
nblades=2;
nrotors=4;
nelements=1000;
%Distribució de cl, cd i alpha del perfil respecte l'angle d'atac en
%radians
cl=[0 -0.6180 -0.9213 -0.6730 0 0.4372 0.6 0.7421 0.8731 0.9214 0.6189 0];
cd=[0 0.18910 0.05678 0.02848 0.03079 0.02820 0.02753 0.03062 0.03880 0.05679 0.18909 0];
alpha=[-90 -15 -10 -5 0 2 4 6 8 10 15 90];
alpha=alpha*pi/180;


weight=mass*9.81;
[T,a,P,rho]=atmosisa(altitud);
area=pi*radi*radi;
vind=sqrt(weight/(2*rho*area*4));
omegaideal=sqrt(((Mtip*a*Mtip*a)-(vind*vind)))/radi;%velocitat angular de disseny
lamdaideal=vind/(omegaideal*radi);
rroot=0;
delta=0.0000001;
pas=1/nelements;
