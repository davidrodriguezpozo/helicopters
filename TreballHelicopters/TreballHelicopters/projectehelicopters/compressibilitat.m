function [cll,cdl]=coeficients(cl,cd,alpha,alphalocal,omega,r,a,compressibilitat,radi)

cll=pchip(alpha,cl,alphalocal);
cdl=pchip(alpha,cd,alphalocal);
    if compressibilitat==true
    Mlocal=omega*r*radi/a;
    correccio=sqrt(1-Mlocal*Mlocal);
    cll=cll*correccio;
    end
end