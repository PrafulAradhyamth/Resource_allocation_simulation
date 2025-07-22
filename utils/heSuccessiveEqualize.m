function [y,csi] = heSuccessiveEqualize(x,chanEst,nVar,cfg,ruIdx)
%heSuccessiveEqualize HE MIMO frequency domain channel equalization
%
%   [Y,CSI] = heSuccessiveEqualize(X,CHANEST,NOISEVAR,CFG,RUIDX) performs
%   minimum-mean-square-error (MMSE) frequency domain equalization with
%   ordered successive interference cancellation on each space-time stream.
%
%   Y is an estimate of the transmitted frequency domain signal and is of
%   size Nsd-by-Nsym-by-Nsts, where Nsd represents the number of data
%   subcarriers (frequency domain), Nsym represents the number of symbols
%   (time domain), and Nsts represents the number of space-time streams
%   (spatial domain). It is complex when either X or CHANEST is complex, or
%   is real otherwise.
%
%   CSI is a real matrix of size Nsd-by-Nsts containing the soft channel
%   state information.
%
%   X is a real or complex array containing the frequency domain signal to
%   equalize. It is of size Nsd-by-Nsym-by-Nr, where Nr represents the
%   number of receive antennas.
%
%   CHANEST is a real or complex array containing the channel estimates for
%   each carrier and symbol. It is of size Nsd-by-Nsts-by-Nr.
%
%   NVAR is a nonnegative scalar representing the noise variance.
%
%   CFG is the format configuration object of type <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a> or 
%   <a href="matlab:help('ehtTBSystemConfig')">ehtTBSystemConfig</a>, which specifies the parameters for high efficiency
%   and extremely high efficiency trigger-based system format configuration
%   object.
%
%   RUIDX is the RU (resource unit) index.
%
%   Copyright 2019-2022 The MathWorks, Inc.

%#codegen

% Input validation
validateattributes(cfg,{'heTBSystemConfig','ehtTBSystemConfig'},{'scalar'},mfilename,'format configuration object');
validateattributes(x,{'double'},{'3d','finite','nonempty'},mfilename,'input signal');
validateattributes(chanEst,{'double'},{'3d','finite','nonempty'},mfilename,'channel estimation input');
validateattributes(nVar,{'double'},{'scalar','finite','nonnegative'},mfilename,'noise variance input');
validateattributes(ruIdx,{'numeric'},{'scalar','positive','integer'},mfilename,'resource unit index');
assert(size(x,1) == size(chanEst,1),'The first dimension of the signal and channel estimation inputs must be equal.');
assert(size(x,3) == size(chanEst,3),'The third dimension of the signal and channel estimation inputs must be equal.');

% Perform equalization
numSym = size(x,2);
[numSC,numSTS,numRx] = size(chanEst);

% Extract space-time streams information
if isa(cfg,'heTBSystemConfig')
    assert(cfg.STBC == false,'STBC is not supported for successive interference cancellation equalization.');
    [~,userParams] = wlan.internal.heCodingParameters(cfg);
else
    [~,userParams] = wlan.internal.ehtCodingParameters(cfg);
end
userIdxRU = cfg.RU{ruIdx}.UserNumbers;
userParamsRU = userParams(userIdxRU);
startingSpaceTimeStreamNumberRU = cfg.stsInfo.StartingSpaceTimeStreamNumber(userIdxRU);

% Initialization
eqUpdate = coder.nullcopy(complex(zeros(numRx,numSTS,numSC)));
nVarI = nVar*eye(numSTS);

chanEstPerm = permute(chanEst,[2,3,1]);
chanEstUpdate = chanEstPerm;
if abs(nVar) < 1e-10 % ZF method, to avoid singular matrix
    csi = sum(real(chanEst.*conj(chanEst)),3);
    for idxSC = 1:numSC
        H = chanEstPerm(:,:,idxSC);
        eqUpdate(:,:,idxSC) = pinv(H);
    end
else % MMSE method
    csi = coder.nullcopy(zeros(numSC,numSTS));
    for idxSC = 1:numSC
        H = chanEstPerm(:,:,idxSC);
        invH = inv(H*H'+nVarI);
        csi(idxSC,:) = 1./real(diag(invH));
        eqUpdate(:,:,idxSC) = H'*invH; %#ok<*MINV>
    end
end
% Order space-time streams based on CSI
[~,stsIdxUpdate] = sort(csi,2,'descend');

% Successive interference cancellation
y = coder.nullcopy(complex(zeros(numSC,numSym,numSTS)));
xRes = permute(x,[2,3,1]); % Residual received signal vector for interference subtraction

for stsCount = 1:numSTS
    eqSts = coder.nullcopy(complex(zeros(numSC,numSym)));
    for idxSC = 1:numSC
        stsIdx = stsIdxUpdate(idxSC,1); % The space-time stream with the highest CSI
        % Equalize the current space-time stream
        y(idxSC,:,stsIdx) = xRes(:,:,idxSC)*eqUpdate(:,stsIdx,idxSC);
        eqSts(idxSC,:) = y(idxSC,:,stsIdx).';
    end
    
    % Reconstruct the transmitted space-time stream
    remapSts = coder.nullcopy(complex(zeros(numSC,numSym)));
    for stsIdx = 1:numSTS
        % Process subcarriers associated with the current space-time stream
        stsSC = logical(stsIdxUpdate(:,1) == stsIdx);
        % Identify the user for the current space-time stream
        userIdx = find(stsIdx >= startingSpaceTimeStreamNumberRU,1,'last');
        userIdx = userIdx(1); % Index for codegen
        demapSts = wlanConstellationDemap(eqSts(stsSC,:),nVar,userParamsRU(userIdx).NBPSCS,'hard');
        remapSts(stsSC,:) = wlanConstellationMap(demapSts,userParamsRU(userIdx).NBPSCS);
    end
    
    % Reconstruct the received space-time stream
    recSts = coder.nullcopy(complex(zeros(numSym,numRx,numSC)));
    for idxSC = 1:numSC
        recSts(:,:,idxSC) = remapSts(idxSC,:).'*chanEstPerm(stsIdxUpdate(idxSC,1),:,idxSC);
    end
    
    % Subtract the current stream from the received signal
    xRes = xRes-recSts;
    
    % Remove the contribution of the current stream
    if stsCount < numSTS
        if abs(nVar) < 1e-10 % ZF method
            for idxSC = 1:numSC
                % Update channel matrix by zeroing the channels of current stream
                chanEstUpdate(stsIdxUpdate(idxSC,1),:,idxSC) = zeros(1,numRx);
                % Update order of remaining streams
                H = chanEstUpdate(:,:,idxSC);
                csiTemp = sum(real(H.*conj(H)),2);
                [~,stsIdxUpdate(idxSC,:)] = sort(csiTemp,'descend');
                % Update equalizer
                eqUpdate(:,:,idxSC) = pinv(H);
            end
        else % MMSE method
            for idxSC = 1:numSC
                % Update channel matrix by zeroing the channels of current stream
                chanEstUpdate(stsIdxUpdate(idxSC,1),:,idxSC) = zeros(1,numRx);
                % Update order of remaining streams
                H = chanEstUpdate(:,:,idxSC);
                invH = inv(H*H'+nVarI);
                [~,stsIdxUpdate(idxSC,:)] = sort(1./real(diag(invH)),'descend');
                % Update equalizer
                eqUpdate(:,:,idxSC) = H'*invH;
            end
        end
    end
end