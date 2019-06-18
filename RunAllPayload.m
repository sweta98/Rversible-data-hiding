function [Resulth]=RunAllPayload(Img)
Resulth={};  
Tpstlist=[0 1 2 4 8 16];
    for k2=1:length(Tpstlist)
            Tpst=Tpstlist(k2);
            Tcp=0;k1=1;
            for i=13107:13107:13107*18
                while(Tcp<=20)
                   [w,locationmap,count1,count2,bpp,PSNR,M2,BH,K1,M,square_order,loc1,LSB,complexity,payloadsize1,xvert,yvert,m,S2,S3]=quadtreesquare(Img,'wmdata9.xlsx',i,Tcp,Tpst,0.27);
                    %[w,count1,count2,bpp,PSNR,M2,BH,K1,M,loc,loc1,payloadsize1,TR,S2]=BtreeTraingular('Img.tif','wmdata9.xlsx',i,Tcp,Tpst,Tdecom, minSize);%,S2,loc,vertices,count11,G,AC,E,TR);
                    if K1==payloadsize1            
                       % [P,T]=Extraction(w,'wmdata9.xlsx','Img.tif',i,loc,count1,count2,BH,TR,S2);
                        [P,T]=ExtractionQuad(w,'wmdata9.xlsx',Img,i,locationmap,m,count1,count2,BH,square_order,S2,S3);
                        clear BH;
                        clear loc1;
                        clear locationmap;
                        clear w;
                        clear M;
                        clear M2;
                        clear square_order;
                        clear S2;
                        clear S3;
                        break;
                    else
                        Tcp=Tcp+1;
                        T=0; P=0;
                     end
                    clear BH;
                    clear loc1;
                    clear locationmap;
                    clear M;
                    clear M2;
                    clear w;
                    clear square_order;
                    clear S2;
                    clear S3
                end
                if T==1 && P==1
                    Result(k1,1)=bpp;
                    Result(k1,2)=PSNR;
                    Result(k1,3)=Tcp;
                    Result(k1,4)=Tpst;
                    %Result(k1,5)=t_decom;
                    k1=k1+1;
                else
                    Result(k1,1) = 0;
                    break;
                end
              if Tcp>20
                  break;
              end
            end
        Resulth{k2,1}=Result;
        clear Result;
    end
%      ResultFN=strcat(Img, '_Resulth.mat');
%      save(ResultFN, 'Resulth');
end
           