%% Introducció de les dades
warning(' ojo canviar la massa si es fa necessari segons l anàlisi');
warning('ojo canviar la velocitat de climbing segons l anàlisi');
mass=10+15; %massa de l'aeronau desitjada en kg
radi=0.5; %radi del rotor en metres
vclimb=0;% en m/s
compressibilitat=true;%si es vol fer correció per compressibilitat o prandtl posar true, sinó posar false
prandtl=true;
nblades=2;
nrotors=4;

fileID = fopen('naca.txt','r');
formatSpec = '%f';
dades = fscanf(fileID,formatSpec);
fclose(fileID);
nmostres=length(dades)/10;

conversio=zeros(nmostres,10);
d=1;
for i=1:nmostres
   for j=1:10
       conversio(i,j)=dades(d);
       j=j+1;
       d=d+1;
   end
   i=i+1;
end

for i=1:nmostres
   alpha(i)=conversio(i,1);
   cl(i)=conversio(i,2);
   cd(i)=conversio(i,3);
   eff(i)=cl(i)/cd(i);
end
alpha=alpha*pi/180;
%% A partir d'aquí no tocar
altitud=2000;%alitiud de vol en m
Mtip=0.5; %mach a punta de pala
theta0=0.1942;  %valors d'angle (en radians) i sigma ja linealitzats 
theta1=-0.0763;
sigma0=0.0521;
sigma1=-0.0372;
nelements=1000;
%Distribució de cl, cd i alpha del perfil respecte l'angle d'atac en


weight=mass*9.81;
[T,a,P,rho]=atmosisa(altitud);
area=pi*radi*radi;
vind=sqrt(weight/(2*rho*area*4));
omegaideal=sqrt(((Mtip*a*Mtip*a)-(vind*vind)))/radi;%velocitat angular de disseny
lamdaideal=vind/(omegaideal*radi);
rroot=0;
delta=0.00000001;
pas=1/nelements;
