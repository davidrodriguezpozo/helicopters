clc;
close all;
clear all;
tic;
run('inputdata.m')
%% Per plotejar els gràfics de cl i cd
% figure;
% plot(alpha*180/pi,cl,'-o');
% xlim([-10 15]);
% figure;
% plot(alpha*180/pi,cd,'-o');
% xlim([-10 15]);
% figure;
% plot(alpha*180/pi,eff,'-o');
% xlim([-10 15]);
%% Càlculs 
compressibilitat=false;
prandtl=false;
[omegaf,lamdaigraficf,cllgraficf,cdlgraficf,posicio,ideal,cllideal,forcaf,mthdfx]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal);
compressibilitat=true;
prandtl=true;
[omegat,lamdaigrafict,cllgrafict,cdlgrafict,posicio,ideal,cllideal,forcat,mthdfx]=calculomega(sigma0,sigma1,nrotors,rho,omegaideal,radi,weight,pas,vclimb,delta,cl,cd,alpha,prandtl,nblades,rroot,theta0,theta1,a,compressibilitat,lamdaideal);
% Plot lamda induïda
%     figure;
%     plot(posicio,lamdaigraficf);
%     hold on;
%     plot(posicio,lamdaigrafict);
%     plot(posicio,ideal);
%     hold off;
%     legend('false','true','ideal')
%     grid on;
%     title('lamda induïda');
%% Plot cl 
%      figure;
%     plot(posicio,cllgraficf);
%     hold on;
%     plot(posicio,cllgrafict);
%     plot(posicio,cllideal);
%     hold off;
%     legend('false','true','ideal')
%     grid on;
%     title(' distribucio cl');
 %% Plot dfx
     figure;
    plot(posicio,forcaf);
    hold on;
    plot(posicio,forcat);
    plot(posicio,mthdfx);
    hold off;
    legend('false','true','ideal');
    grid on;
    title('distribucio forca resistencia');
    
toc;