clc;
close all;
clear all;
tic;
run('inputdata.m');
compressibilitat=true;
prandtl=true;
vclimb=2.5;
[omega2,lamdaigrafic2,cllgrafic2,cdlgrafic2,posicio,ideal,cllidea2,forca2]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal);
vclimb=5;
[omega5,lamdaigrafic5,cllgrafic5,cdlgrafic5,posicio,ideal,cllideal5,forca5]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal);
vclimb=7.5;
[omega7,lamdaigrafic7,cllgrafic7,cdlgrafic7,posicio,ideal,cllideal,forca7]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal);

    figure;
    plot(posicio,lamdaigrafic2);
    hold on;
    plot(posicio,lamdaigrafic5);
    plot(posicio,lamdaigrafic7);
    plot(posicio,ideal);
    hold off;
    legend('2','5','7.5','ideal')
    grid on;
    title('lamda induïda amb climb');