function PosArry = CreateSourcePosAry_CB_Helical(BetaS,BetaE,SO,h,ViewN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SO     : Distance between the source-Center and the origin
% ViewN   : The total source number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PosArry{:,1} x coordinate of the source position
% PosArry[:,2] y coordinate of the source position
% PosArry[:,3] z coordinate of the source position
% PosArry[:,4] x component of the unit vector 
% PosArry[:,5] y component of the unit vector 
%%%%%%%%%%%%%%%%%%%%%% View
PosArry = zeros(ViewN,5);
deltafai=(BetaE-BetaS)/(ViewN-1);
for i=1:ViewN
View    = BetaS+(i-1)*deltafai;
PosArry(i,1) = SO*cos(View);
PosArry(i,2) = SO*sin(View);
PosArry(i,3) = h*View/(2*pi);
PosArry(i,4) = cos(View);
PosArry(i,5) = sin(View);
end


 



