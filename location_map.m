function [loc1, numelloc]=location_map(w,locationmap,Tcp,Tpst,complexity,PE)
[sx,sy]=size(w);loc1=zeros(sx,sy);
for m=1:sx
     for n=1:sy
         if(locationmap(m,n)==0)
         if(complexity(m,n)<Tpst)
              if((PE(m,n)<=Tcp)&&(PE(m,n)>=(-Tcp)))  
             if((w(m,n)+3*PE(m,n))>252)||((w(m,n)+3*PE(m,n))<0)
                 loc1(m,n)=1;
             end
             elseif(PE(m,n)>Tcp)
                 if((w(m,n)+3*Tcp)>252)
                       loc1(m,n)=1;
                 end
             elseif(PE(m,n)<(-Tcp))
                 if((w(m,n)-3*Tcp)<0)
                     loc1(m,n)=1;
                 end
             end
         else   %if(complexity(m,n)>=Tpst)
             if((PE(m,n)<=Tcp)&&(PE(m,n)>=(-Tcp))) 
             if((w(m,n)+PE(m,n))>254)||((w(m,n)+PE(m,n))<0)
                 loc1(m,n)=1;
             end
             elseif(PE(m,n)>Tcp)
                 if((w(m,n)+Tcp)>254)
                       loc1(m,n)=1;
                 end
             elseif(PE(m,n)<(-Tcp))
                 if((w(m,n)-Tcp)<0)
                     loc1(m,n)=1;
                 end
             end
         end
         end
     end
end
% Estimate number of pixels where overflow/underflow may occur
numelloc=numel(find(loc1==1));
 end         