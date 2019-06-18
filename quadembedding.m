function  [K1,w]=quadembedding(w,locationmap,payloadsize1,complexity,Tpst,Tcp,M,loc1,Predicted_Error,row,square_order,xvert,yvert)
K1=1;
for i=1:length(square_order)    
    sq=square_order(i);
    M1=[xvert(1,sq) xvert(2,sq) xvert(3,sq) xvert(4,sq)];
    Mx=max(min(M1),row);
    Nx=max(M1);
    N=[yvert(1,sq) yvert(2,sq) yvert(3,sq) yvert(4,sq)];
    My=min(N);
    Ny=max(N);
    for m=Mx:Nx
       for n=My:Ny
            if((locationmap(m,n)==0 && loc1(m,n)==0))
                if(K1>payloadsize1)
                    break;
                end
                if(complexity(m,n)<Tpst) && (K1<=payloadsize1-1)
                    if((Predicted_Error(m,n)<=Tcp)&&(Predicted_Error(m,n)>=(-Tcp)))
                        b=2*M(K1)+M(K1+1);
                     w(m,n)=w(m,n)+3*Predicted_Error(m,n)+b;   %embedding two bits
                     K1=K1+2;
                     elseif(Predicted_Error(m,n)>Tcp)
                     w(m,n)=w(m,n)+3*Tcp+3;
                  elseif(Predicted_Error(m,n)<(-Tcp))
                     w(m,n)=w(m,n)-(3*Tcp);
                    end
                else  
                 if((Predicted_Error(m,n)<=Tcp)&&(Predicted_Error(m,n)>=(-Tcp)))
                     w(m,n)=w(m,n)+Predicted_Error(m,n)+M(K1);%embedding one bit
                     K1=K1+1;
                 elseif(Predicted_Error(m,n)>Tcp)
                     w(m,n)=w(m,n)+Tcp+1;
                 elseif(Predicted_Error(m,n)<(-Tcp))
                     w(m,n)=w(m,n)-Tcp;
                 end
                end
            end
       end
    end
end
K1=K1-1;
end
                    