function[Mc,Ph_err,Miters] = SensEncodedAutoPhaseCorrection(Ksp,smaps,iters,method)
%  [Mc,Ph_err] = SensEncodedAutoPhaseCorrection(Ksp,smaps,iters,method)
%
%   Iterative auto phase correction via sensitvity encoded phase
%    addition and cancellation
%   Hai Luo et al. (ISMRM 2020.)
%
%   INPUT:
%     - Ksp         [kx,ky,coil]  : data corrupted k-space
%     - smaps     [x,y,coil]     : Relative coil sensitivity maps
%     - iters                            : iterative num, iters = 5 is enough for most case
%     -method                       :1, phase correction using combined phase error of all channels( recommended)
%                                            2, phase correction using  indivdual coil phase error(better ghost reduction but larger noise amplification)
%   OUTPUT:
%    - Mc               :  images after ghost reduction
%     - Ph_err        : Phase error which had been used for ghost reduction
%     -Miters          : Images for each iteration
%
%
%   Hai Luo  (taihai.luo@qq.com)

if nargin < 3
    iters = 5;
    method = 1;
end
if nargin < 4
    method = 1;
end

coils = size(Ksp,3);

% last_pherr = ones(size(Ksp,1),size(Ksp,2));
% get the initial images
Miter =   ifftshift(ifftshift(ifft(ifft(fftshift(ifftshift(Ksp,1),2),[],1),[],2),1),2);

% produce a magnitude mask to drop low SNR data
Kspmask = sum(abs(Ksp),3);
T = 0.5*mean(Kspmask(:));
Kspmask = Kspmask > T;

Miters = zeros(size(Ksp,1),size(Ksp,2),iters);

% starting iterative phase correction
for iter = 1:iters
    Miters(:,:,iter) = sos(Miter);
    Msynthetic = sum((Miter.*conj(smaps)),3)./sum(abs(smaps).^2,3);
    Msynthetic(isnan(Msynthetic)) = 0; % fix the points which is divided by zero
   
    Msynthetic = repmat(Msynthetic,1,1,coils).*smaps;  % now, Msynthetic is the synthetic images with smaller ghost artifact
    
    % transform to k-space
    Ksynthetic = fftshift(fftshift(fft(fft(fftshift(fftshift(Msynthetic,1),2),[],1),[],2),1),2);
    

    switch(method)
        case 1,
            % get the phase error between orignal k-space & synthetic
            % k-space, and then combine the phase of all channels with
            % magnitude weighted
            pherr = sum(Ksp.*conj(Ksynthetic),3); 
            
            %normalize the magnitude to 1
            pherr = pherr./abs(pherr);  
            pherr(isnan(pherr)) = 0;
            
            
            pherr(~Kspmask) = 0; % no phase correction for the low signal locations, to avoid noise amplification
           
            
            %     pherr = medfilt1(pherr,7);  % filtering to suppress noise
            %     amplification
            
            % subtract the phase error 
            Kiter = Ksp.*conj(repmat(pherr,1,1,coils));
        case 2,
           % get the phase error between orignal k-space & synthetic
            % k-space, no coil combination
            pherr = Ksp.*conj(Ksynthetic);
            
            %normalize the magnitude to 1
            pherr = pherr./abs(pherr);  
            pherr(isnan(pherr)) = 0;
            
            pherr(repmat(~Kspmask,1,1,coils)) = 0; % no phase correction for the low signal locations, to avoid noise amplification
            
          % subtract the phase error 
            Kiter = Ksp.*conj(pherr);
    end
    
    
    %transform to image domain and then start the next iteration
    Miter =  ifftshift(ifftshift(ifft(ifft(fftshift(ifftshift(Kiter,1),2),[],1),[],2),1),2);

end
Ph_err = angle(pherr);
Mc = Miter;
% Mc = sos(Miter);
% as(Mc)



