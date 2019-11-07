% This is a demo on how to use sCPU(Sensitivities Constrained Phase Update (sCPU) for Ghost Artifacts Reduction) for ghost artifacts reduction.
% Using coil sensitivities as constraints, a synthetic image can be generated in which the ghost is reduced due to phase cancelation. Phase error was first estimated from the raw image and the synthetic image,
% and then was used to update the phase of raw k-space. The simulated ghost images with linear, random phase error or both random magnitude/phase error can be effiecntly corrected after several iterations.
% load data
load 'ismrm_sunrise_cause_sim_data.mat'

% input parameters
sim_groups =3; % 1: linear phase error  2: random phase error 3: random phase error & random magnitude error
iter = 10; % iteration num

%     -method                       :1, phase correction using combined phase error of all channels
%                                            2, phase correction using indivdual coil phase error
method = 1;

% now start to simulated the noise and motion
M = repmat(im1,1,1,8).*smaps;
M = M./max(abs(M(:)));
coils = size(M,3);
for coil = 1:coils
    % added complex Gaussian Noise, with SNR 30;
    M(:,:,coil) = awgn(M(:,:,coil),30);
end

%get the simulated K-space
K = fftshift(fftshift(fft(fft(fftshift(fftshift(M,1),2),[],1),[],2),1),2);



%starting ghost simulation
switch(sim_groups)
    case 1,% linear phase error
        
        ETL = 64;
        segs = floor(size(K,1)/ETL);
        ind = 1:segs:size(K,1);
        Kacq = K;
        phi =1*pi/256;
        ph = exp(-i*ind.*phi).';
        ph =repmat(ph,1,size(K,2),size(K,3));
    case 2, % for random phase error
        ETL = 256;
        segs = floor(size(K,1)/ETL);
        ind = 1:segs:size(K,1);
        Kacq = K;
        ph =exp(-i*rand(ETL,size(K,2))*pi);
        ph =repmat(ph,1,1,size(K,3));
        
    case 3, %random phase error & random magnitude error
        ETL = 256;
        segs = floor(size(K,1)/ETL);
        ind = 1:segs:size(K,1);
        Kacq = K;
        ph =(( rand(ETL,size(K,2))+9)/10).*exp(-i*rand(ETL,size(K,2))*pi);
        ph =repmat(ph,1,1,size(K,3));
        
end
Kacq(ind,:,:) = K(ind,:,:).*ph;


% get the simulated images with ghost artifacts
M_ghost =  ifftshift(ifftshift(ifft(ifft(fftshift(ifftshift(Kacq,1),2),[],1),[],2),1),2);

% Start Iterative auto phase correction
[Mc,Ph_err,Miters] = sCPU(Kacq,smaps,iter,method);

figure;imshow3([sos(M),sos(M_ghost), sos(Mc),abs(sos(M_ghost)-sos(Mc))])
title('Ghost Reduction Results:   Orignal,     Ghost Image,   Corrected   &   Ghost Map     ');

figure;imshow3(Ph_err)
title('Estimated K-space Phase Error ');

Col = floor(iter/2);
figure;imshow3(Miters,[],[2,Col])
title('Image of each iteration ');


err =  abs(Miters - repmat(sos(M),1,1,iter));
err =sqrt( squeeze(mean(mean(err,1),2)));
figure;plot(err);
ylabel('RMSE')
xlabel('Iteration')



