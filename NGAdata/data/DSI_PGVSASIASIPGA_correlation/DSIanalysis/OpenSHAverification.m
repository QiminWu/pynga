function temp

% meansigma_ml=[0.10000    0.26689    0.17849 
%    0.12228    0.29802    0.19659 
%    0.14953    0.33281    0.21653 
%    0.18286    0.35964    0.23457 
%    0.22361    0.37079    0.24119 
%    0.27344    0.36898    0.24283 
%    0.33437    0.35470    0.23633 
%    0.40888    0.33015    0.21914 
%    0.50000    0.30584    0.20736];
% % 
% meansigma_java=[0.10000000000000002 0.2668885863560815 0.1784860711647104
% 0.1222844544993852 0.2980249513014719 0.19659357003908323
% 0.1495348781221221 0.33280987630402314 0.21652577170034826
% 0.18285790999795748 0.3596381341688383 0.23457407011790113
% 0.22360679774997905 0.37079179194562295 0.24118509350790657
% 0.2734363528521053 0.3689819206306244 0.24282685221210262
% 0.33437015248821106 0.35470238480470945 0.2363339051237758
% 0.40888271697897133 0.3301513135281545 0.21913797507405688
% 0.5000000000000001 0.30583631827480134 0.20735867847566664];
% 
% plot(meansigma_java(:,1),meansigma_java(:,2),'o-'); hold on;
% plot(meansigma_ml(:,1),meansigma_ml(:,2),'x-.r');
% legend('Matlab','OpenSHA');

weightmean_ml=[0.10000    0.01114    0.00297 
   0.12228    0.02477    0.01036 
   0.14953    0.03029    0.02043 
   0.18286    0.03704    0.03375 
   0.22361    0.04529    0.05055 
   0.27344    0.05538    0.07098 
   0.33437    0.06772    0.09500 
   0.40888    0.08281    0.12235 
   0.50000    0.04556    0.13628 ];

weightmean_java=[0.10000000000000002 0.01114222724969259 0.002973733279528665
0.1222844544993852 0.02476743906106104 0.010355048099563554
0.1495348781221221 0.03028672774928614 0.0204347702154571
0.18285790999795748 0.037035959813928473 0.03375431370009041
0.22360679774997905 0.04528922142707392 0.05054718526885725
0.2734363528521053 0.055381677369116006 0.07098202295225926
0.33437015248821106 0.067723182063433 0.09500359713672248
0.40888271697897133 0.08281492375589453 0.12234505299446502
0.5000000000000001 0.04555864151051439 0.13627854017964228];

plot(weightmean_java(:,1),weightmean_java(:,3),'o-'); hold on;
plot(weightmean_ml(:,1),weightmean_ml(:,3),'x-.r');
legend('OpenSHA','Matlab');

