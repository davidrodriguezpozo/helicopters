function [omega,lamdaigrafic,cllgrafic,cdlgrafic,posicio,ideal,cllideal,dfx,mthdfx]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal)

%Finalment podem calcular la omega


primer=true;
omega=omegaideal;
trobat=false;
fold=0;
omegaold=0;
j=0;
while trobat==false
    integral=0;
    for r=0.001:pas:(1-delta)
lamdac=vclimb/(omega*radi);
[lamdai,phi,cll,cdl]=calcullamdai(lamdac,delta,r,cl,cd,alpha,sigma0,sigma1,prandtl,nblades,rroot,theta0,theta1,omega,a,compressibilitat,radi,lamdaideal);
sigmal=sigma0+sigma1*r;
integrand=0.5*rho*((omega*radi)^2)*pi*radi*radi*sigmal*nrotors*(r*r+(lamdac+lamdai)*(lamdac+lamdai))*(cll*cos(phi)-cdl*sin(phi));
integral=integral+integrand*pas;
    end
    fnew=weight-integral;
    [omegaold,fold,omega,trobat,primer]=newton(omegaold,fold,omega,fnew,primer,delta);
    j=j+1;
end

omega=omega;
disp('Velocitat de rotació en rad/s');
disp(omega);
j=1;
potencia=0;
potparasita=0;
potideal=0;
lamdac=vclimb/(omega*radi);
for r=0.001:pas:(1-delta)
    [lamdaigrafic(j),phigrafic(j),cllgrafic(j),cdlgrafic(j)]=calcullamdai(lamdac,delta,r,cl,cd,alpha,sigma0,sigma1,prandtl,nblades,rroot,theta0,theta1,omega,a,compressibilitat,radi,lamdaideal);
    posicio(j)=r;
    sigmal=sigma0+sigma1*r;
    dfx(j)=(1/nblades)*0.5*rho*sigmal*(omega*radi)*(omega*radi)*pi*radi*radi*(cllgrafic(j)*sin(phigrafic(j))+cdlgrafic(j)*cos(phigrafic(j)))*(r*r+(lamdac+lamdaigrafic(j))*(lamdac+lamdaigrafic(j)));
    intpp=(1/nblades)*0.5*rho*sigmal*(omega*radi)*(omega*radi)*pi*radi*radi*(cdlgrafic(j)*cos(phigrafic(j)))*(r*r+(lamdac+lamdaigrafic(j))*(lamdac+lamdaigrafic(j)));
    intpi=(1/nblades)*0.5*rho*sigmal*(omega*radi)*(omega*radi)*pi*radi*radi*(cllgrafic(j)*sin(phigrafic(j)))*(r*r+(lamdac+lamdaigrafic(j))*(lamdac+lamdaigrafic(j)));
    potencia=potencia+dfx(j)*nblades*nrotors*r*radi*omega*pas;
    potparasita=potparasita+intpp*nblades*nrotors*r*radi*omega*pas;
    potideal=potideal+intpi*nblades*nrotors*r*radi*omega*pas;
    ideal(j)=lamdaideal;
    cllideal(j)=0.6163;
    cdideal=0.01432;
    phiideal(j)=lamdaideal/r;
    %sigmaideal=(8*r*(lamdac+lamdaideal)*lamdaideal)/(((r^2)+(lamdac+lamdaideal)^2)*(cllideal(j)*cos(phiideal(j))-cdideal*sin(phiideal(j))));
    mthdfx(j)=(1/nblades)*0.5*rho*sigmal*(omega*radi)*(omega*radi)*pi*radi*radi*(cllideal(j)*sin(phiideal(j)))*(r*r+(lamdac+lamdaideal)*(lamdac+lamdaideal));
     if r>0.9 && prandtl==true
        dfx(j)=-0.18+(1/nblades)*0.5*rho*sigmal*(omega*radi)*(omega*radi)*pi*radi*radi*(cllgrafic(j)*sin(phiideal(j))+cdlgrafic(j)*cos(phigrafic(j)))*(r*r+(lamdac+lamdaigrafic(j))*(lamdac+lamdaigrafic(j)));
     end
     if r<0.012
         mthdfx(j)=0;
     end
    j=j+1;
end 
    disp(potencia);
    disp('Potència Paràsita');
    disp(potparasita);
    disp('Potència ideal');
    disp(potideal)
    
end