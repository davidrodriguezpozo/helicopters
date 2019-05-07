function [lamdai,phi,cll,cdl]=calcullamdai(lamdac,delta,r,cl,cd,alpha,sigma0,sigma1,prandtl,nblades,rroot,theta0,theta1,omega,a,compressibilitat,radi,lamdaideal)

%Funció que calcula la lamda induïda a cada punt
theta=theta0+theta1*r;
sigmal=sigma0+sigma1*r;
i=1;
trobat=false;
primer=true;
lamdaanterior=1;
lamdanova=lamdaideal;
fanterior=0;
while trobat==false
  
   phi=atan((lamdac+lamdanova)/r);

     if prandtl==true
        phi=perduesprandtl(phi,r,lamdac,lamdanova,nblades,rroot,delta);

     end
    alphalocal=theta-phi;
    [cll,cdl]=coeficients(cl,cd,alpha,alphalocal,omega,r,a,compressibilitat,radi);
    fnova=4*r*lamdanova*(lamdac+lamdanova)-(sigmal/2)*(r*r+(lamdac+lamdanova)*(lamdac+lamdanova))*(cll*cos(phi)-cdl*sin(phi));
    [lamdaanterior,fanterior,lamdanova,trobat,primer]=newton(lamdaanterior,fanterior,lamdanova,fnova,primer,delta);
    i=i+1;
end
lamdai=lamdanova;

phi=phi;
cll=cll;
cdl=cdl;
end