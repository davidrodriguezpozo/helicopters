function [phi]=perduesprandtl(phiinici,r,lamdac,lamdai,nblades,rroot,delta)
% Aquesta funci� calcula l'angle phi de les p�rdues de prandtl. Per fer-ho
% cal introduir una phi on comen�a (que �s la normal), la posici� radial
% adimensional, les velocitats adimensionals, el nombre de pales, rroot i
% l'error desitjat delta.
ftip=(nblades/2)*(1-r)/(r*sin(phiinici));
froot=(nblades/2)*(r-rroot)/(r*sin(phiinici));
F=(4/(pi*pi));
F=F*acos(exp(-ftip));
F=F*acos(exp(-froot));
phiactual=0.5*(phiinici+atan((lamdac+(lamdai/F))/r));
error=abs(phiactual-phiinici);
i=0;
while error>=delta
    phianterior=phiactual;
    ftip=(nblades/2)*(1-r)/(r*sin(phianterior));
froot=(nblades/2)*(r-rroot)/(r*sin(phianterior));
F=(4/(pi*pi));
F=F*acos(exp(-ftip));
F=F*acos(exp(-froot));
phiactual=0.5*(phianterior+atan((lamdac+(lamdai/F))/r));
error=abs(phiactual-phianterior);
i=i+1;
end

    
phi=phiactual;
end