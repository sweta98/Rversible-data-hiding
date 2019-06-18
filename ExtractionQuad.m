function [P,T,K,predicted_image1,S,complexity1,LSB2]=ExtractionQuad(w,watermarkFN, OrigFN,payloadsize,locationmap,m,count1,count2,BH,square_order,S2,S3)
%This function extracts the watermark and resotres the original image. The
% values of P and T should be 1 if everything is recovered correctly.
% Input Arguments: watermaredFN is Watermarked image file name, watermarkFN
% is the watermark data in an excel sheet, OrgFN is the original cover
% image file name, payloadsize is the length of the watermark data
% (payload)
% Read the wateramarked image
%w1=imread(watermarkedImFN);
w1=double(w);
[sx,sy]=size(w1);
LSEQ=sx*sy; 
% Prediction error and Pixel complexity estimation
%[G1,AC1,PE1]=InterpolationaatDecoding(S2,w);
[Predicted_Error1,complexity1,predicted_image1]=Decodingend(w1,S2,S3,m);
s1=1;
for i=1:sx
    for j=1:sy
        if s1>length(BH)
            break;
        end   
        if(locationmap(i,j)==0)
            LSB2(s1)=num2str( mod(w(i,j),2) );
            s1=s1+1;
        end
        position=i;
    end
end

%Extracting the Auxiliary Information
if(bin2dec(LSB2(1))==1)
        set=1;%used to find the overflow map is needed or not
        L1= bin2dec(LSB2(2:20));     %length of compressed map
        lengthLM= LSB2(21:L1+20);  % compressed sequence
        Tcp = bin2dec(LSB2(L1+21:L1+25));  %Tcp
        Tpst=bin2dec(LSB2(L1+26:L1+30)); %Tpst
else
    set=0;
    Tcp = bin2dec(LSB2(2:6));
    Tpst=bin2dec(LSB2(7:11));
end

%Decompressing the overflow/underflow Map
if(set==1)
    for i=1:length(lengthLM)
    LeSE(i)=str2double(lengthLM(i));
    end
    Dseq = arithdeco(LeSE,[count1,count2],LSEQ); %extracting the overflow/underflow map
   for i=1:length(Dseq)
    if(Dseq(1,i)==2)
        Dseq(1,i)=0;
    end
   end
   loc1 = reshape( Dseq, [sx sy] );
else
    loc1=zeros(sx,sy);
end

%extracting the message and original velues
K=1;S=[];
K1=payloadsize+length(BH)+1;
for i=1:length(square_order)    
    sq=square_order(i);
    M1=[S2(1,sq) S2(2,sq) S2(3,sq) S2(4,sq)];
    Mx=max(min(M1),position+1);
    Nx=max(M1);
    N=[S3(1,sq) S3(2,sq) S3(3,sq) S3(4,sq)];
    My=min(N);
    Ny=max(N);
for l=Mx:Nx
    for n=My:Ny
           if (locationmap(l,n)==0 && loc1(l,n)==0)
          if K==K1
              break;
          end
           %if(loc(m,n)==0)&&(loc1(m,n)==0)
          %if(loc1(m,n)==0)
            if(complexity1(l,n)<Tpst)&&(K <=K1-2) %extracting embedded two bits
                 if((Predicted_Error1(l,n)>=-4*Tcp)&&(Predicted_Error1(l,n)<=(4*Tcp+3)))  
                     b=floor(Predicted_Error1(l,n))-4*floor(Predicted_Error1(l,n)/4);
                      if(b==0)
                        S(K)=0;                  %b is the embedded two bits
                        S(K+1)=0;
                      elseif(b==1)
                         S(K)=0;
                         S(K+1)=1;
                      elseif(b==2)
                           S(K)=1;
                        S(K+1)=0;
                      elseif(b==3)
                        S(K)=1;
                        S(K+1)=1;
                      end
                      K=K+2;
                      w1(l,n)=w1(l,n)-3*floor(Predicted_Error1(l,n)/4)-b;
                 elseif(Predicted_Error1(l,n)>(4*Tcp+3))   %shifting in left direction to that of original
                        w1(l,n)=w1(l,n)-3*Tcp-3;
                 elseif((Predicted_Error1(l,n)<(-4*Tcp)))
                        w1(l,n)=w1(l,n)+(3*Tcp);       %shifting in right direction to that of original
                 end 
            else 
                if((Predicted_Error1(l,n)>=-2*Tcp)&&(Predicted_Error1(l,n)<=(2*Tcp+1)))   
                      b1=floor(Predicted_Error1(l,n))-2*(floor((Predicted_Error1(l,n))/2));
                      %b=mod(PE1(m,n),2);
                       S(K)=b1;
                       K=K+1;
                       w1(l,n)=((w1(l,n)+predicted_image1(l,n)-b1)/2);         
                elseif(Predicted_Error1(l,n)>(2*Tcp+1))
                  w1(l,n)=w1(l,n)-Tcp-1;
                elseif((Predicted_Error1(l,n)<(-2*Tcp)))
                  w1(l,n)=w1(l,n)+(Tcp);
                end
            end
           end
        end
    end
end
payload=S(1:payloadsize); %Computing the LSBbits
LSBit=S(payloadsize+1:length(S));   %Extracting the original LSBs
%Restoring the original LSBits in the first few rows
s1=1;
for i=1:sx
    for j=1:sy
        if(s1>length(BH))
            break;
        end
        if(locationmap(i,j)==0)
            w1(i,j)=bitset(w1(i,j),1,LSBit(s1));
            s1=s1+1;
        end
    end
end

% Write the restored image
%imwrite( uint8(w), 'restored.tif', 'tif' );

% Read the original payload
range='A1:RT488';
Qp=xlsread(watermarkFN,1,range); 
originM=reshape(Qp,1,numel(Qp));  
M2=originM(1:payloadsize); % M2 is the payload
% Comparison of the recovered payload with the original
P=isequal(payload,M2);

% Read the original payload
y = imread( OrigFN );
y=double(y);

% Comparison of the restored image with the original
T=isequal(w1,y);

end