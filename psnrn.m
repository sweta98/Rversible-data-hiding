function [b,p]=psnrn(plsize,y,w)

% computing the bpp
[sx,sy]=size(w);
b=plsize/(sx*sy);

% computing the psnr
SE = (y - w).^2;
MSE1 = mean( mean( SE ) );
p=10*(log10((255^2)/(MSE1)));
end
