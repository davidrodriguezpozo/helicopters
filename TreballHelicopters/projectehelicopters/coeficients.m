function [cll,cdl]=coeficients(cl,cd,alpha,alphalocal,omega,r,a,compressibilitat,radi)
%Aquesta funci� retorna els valors del cl i el cd locals a cada secci� de
%la pala. Per fer-ho cal introduir les taules de cl, cd, alpha i un angle
%al qual es vulgui calcular. Per calcular el factor de compressibilitat cal
%introduir la velocitat angular, la posici� radial, la velocitat del so i
%el radi i dir si compressbilitat �s true.
cll=pchip(alpha,cl,alphalocal);
cdl=pchip(alpha,cd,alphalocal);
    if compressibilitat==true
    Mlocal=omega*r*radi/a;
    correccio=sqrt(1-Mlocal*Mlocal);
    cll=cll*correccio;
    end
end