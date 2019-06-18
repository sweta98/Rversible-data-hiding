function k=numofelofT(PMx,PMy,X,Y,x,y)
M=[PMx,X,x];N=[PMy,Y,y];
Mx=min(M);
Nx=max(M);
My=min(N);
Ny=max(N);
A=[];
k=1;
P1=[PMx,PMy];
P2=[X,Y];
P3=[x,y];
for i=Mx:Nx
        for j=My:Ny
               P=[i,j];
               Q = det([P1-P2;P3-P1]);
               T = Q*det([P3-P;P2-P3])>=0 & Q*det([P1-P;P3-P1])>=0 & Q*det([P2-P;P1-P2])>=0;
                if(T==1)          
                    k=k+1;                    
                end
        end
end 
end