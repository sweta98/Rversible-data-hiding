function [xvert,yvert,pixelvert,predicted_image,complexity,Predicted_Error,locationmap,sortedAC,square_order,S2,S3,m]= Predicted(ImFN,tdecom)
I=imread(ImFN);
I=double(I);
S=qtdecomp(I,tdecom,4); 
[r,c,p]=find(S); 
m= length(r);
for i=1:m
    % x-coordinates of the corners of the square
    xvert(1,i)=r(i);
    xvert(2,i)=r(i);
    xvert(3,i)=r(i)+p(i)-1;
    xvert(4,i)=r(i)+p(i)-1;
    %order of the x-coordinates of the square
    S2(1,i)=xvert(1,i);
    S2(2,i)=xvert(2,i);
    S2(3,i)=xvert(3,i);
    S2(4,i)=xvert(4,i);
    % y-coordinates of the corners of the square
    yvert(1,i)=c(i);
    yvert(2,i)=c(i)+p(i)-1;
    yvert(3,i)=c(i)+p(i)-1;
    yvert(4,i)=c(i);
    %order of the y-coordinates of the square
    S3(1,i)=yvert(1,i);
    S3(2,i)=yvert(2,i);
    S3(3,i)=yvert(3,i);
    S3(4,i)=yvert(4,i);
    % pixel values of the corners of the square
    pixelvert(1,i)=I(xvert(1,i),yvert(1,i));
    pixelvert(2,i)=I(xvert(2,i),yvert(2,i));
    pixelvert(3,i)=I(xvert(3,i),yvert(3,i));
    pixelvert(4,i)=I(xvert(4,i),yvert(4,i));
end
complexity=[];
locationmap=zeros(512,512);
predicted_image = I;
for i=1:m
    locationmap(xvert(1,i),yvert(1,i))=1;
    locationmap(xvert(2,i),yvert(3,i))=1;
    locationmap(xvert(3,i),yvert(3,i))=1;
    locationmap(xvert(4,i),yvert(4,i))=1;
    A = [pixelvert(1,i) pixelvert(2,i) pixelvert(3,i) pixelvert(4,i)];
    vari(i)=var(A);   %storing variance values for LC 
    P=[xvert(1,i) xvert(2,i) xvert(3,i) xvert(4,i)];
    Q=[yvert(1,i) yvert(2,i) yvert(3,i) yvert(4,i)];
    s2= max(P);
    s1= min(P);
    s3=min(Q);
    s4=max(Q);
    for k=s1:s2
        for n=s3:s4
            dummy1=round(((s2-k)/(s2-s1))*pixelvert(4,i) +((k-s1)/(s2-s1))*pixelvert(3,i));
            dummy2=round(((s2-k)/(s2-s1))*pixelvert(1,i)+((k-s1)/(s2-s1))*pixelvert(2,i));
           predicted_image(k,n)=round(((s4-n)/(s4-s3))*dummy1 + ((n-s3)/(s4-s3))*dummy2);
           complexity(k,n)=vari(i);%Local complexity
           Predicted_Error(k,n)=I(k,n)-predicted_image(k,n); %prediction error
        end
    end
end
     [sortedAC, square_order] =sort(vari);    %sorted order(ascending) of squares according to variance        