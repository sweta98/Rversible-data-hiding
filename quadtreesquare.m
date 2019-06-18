function [w,locationmap,count1,count2,bpp,PSNR,M2,BH,K1,M,square_order,loc1,LSB,complexity,payloadsize1,xvert,yvert,m,S2,S3]=quadtreesquare(ImgFN,watermarkFN,payloadsize,Tcp,Tpst,tdecom)
% Tdecom is a threshold used for decomposing a triangel further. minSize is
% the threshold of triangle size below which a triangel will not be
% decomposed. Tpst is the smoothness threshold. Tcp is the another
% threshold used for embedding
% Read the cover image
w = imread( ImgFN );
w=double(w);
[sx,sy]=size(w);y=w;
% Read the payload
range='A1:RT488';
Qp=xlsread(watermarkFN,1,range); 
originM=reshape(Qp,1,numel(Qp));  
M2=originM(1:payloadsize); % M2 is the payload
[xvert,yvert,pixelvert,predicted_image,complexity,Predicted_Error,locationmap,sortedAC,square_order,S2,S3,m]= Predicted(ImgFN,tdecom);


% Generate prediction error image, smoothness image and overflow/underflow
% map. This function returns overlflow/underflow location map loc1.

[loc1, numelloc]=location_map(w,locationmap,Tcp,Tpst,complexity,Predicted_Error);

%compressing the location map by arithmetic coding
if(numelloc~=0)  
    set=1;
    [L1,count1,count2,encodedLM]=compressedlocationmap(loc1);
    for i=1:length(encodedLM)
    encodedLM1(i) = num2str(encodedLM(i));
    end
    
    %computing auxiliary information
    hbinSeq=dec2bin(set,1);
    hbinSeq = strcat(hbinSeq,dec2bin(L1,19));
    hbinSeq = strcat(hbinSeq,encodedLM1);
    hbinSeq = strcat(hbinSeq,dec2bin(Tcp,5));
    hbinSeq = strcat(hbinSeq,dec2bin(Tpst,5));
else
    % if underflow/overflow does not occur
    set=0;
    hbinSeq=dec2bin(set,1);
    hbinSeq = strcat(hbinSeq,dec2bin(Tcp,5));
    hbinSeq = strcat(hbinSeq,dec2bin(Tpst,5));
    count1=0;
    count2=0;
end

% computing auxiliary information
for i=1:length(hbinSeq)
    BH(i)= str2num(hbinSeq(i));
end

% setting with Auxiliary information by LSB replacement
s=1;
for i=1:sx
    for j=1:sy
        if s>length(BH)
            break;
        end
        if (locationmap(i,j)==0) 
            LSB(s)=mod(w(i,j),2);
            w(i,j)=bitset(w(i,j),1,BH(s));
            s=s+1;
        end
        rownumber=i;
    end
end    
% Concatenating the LSBs with original message and embedding the payload
M=[M2 LSB];
payloadsize1=length(M);
[K1,w]=quadembedding(w,locationmap,payloadsize1,complexity,Tpst,Tcp,M,loc1,Predicted_Error,rownumber+1,square_order,xvert,yvert);
% At this stage, w is the watermarked image

% Compute the psnr between the cover image and watermarked image and bpp
[bpp,PSNR]=psnrn(payloadsize,y,w);
imwrite(uint8(w),'watermarkedimage.tif','tif');
end
            
    