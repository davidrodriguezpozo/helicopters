function [xold,yold,xnew,trobat,primer]=Newton(xold,yold,xnew,ynew,primer,delta)
if (abs(ynew))<=delta
    trobat=true;
else
    if primer==true
        xold=xnew;
        yold=ynew;
        xnew=xold*2;
        primer=false;
    else
        pendent=(ynew-yold)/(xnew-xold);
        yold=ynew;
        xold=xnew;
        xnew=xnew-ynew/pendent;
    end
    trobat=false;
end
end