function sinr = channelToSINR(tgax, ofdmInfo, SNR, userConfig)
% release(tgax);
% tgax.ChannelFiltering = true;

% Configure wlanHESUConfig
cfgNDP = wlanHESUConfig;
bwFormat = "CBW%d";
bw = sprintf(bwFormat, userConfig.BW);
cfgNDP.ChannelBandwidth = bw;
cfgNDP.HELTFType = userConfig.LTF_TYPE;
cfgNDP.GuardInterval = userConfig.GI_TYPE;
cfgNDP.NumTransmitAntennas = 1;
cfgNDP.NumSpaceTimeStreams = 1;
cfgNDP.SpatialMapping = 'Direct';
cfgNDP.MCS = 1;
cfgNDP.APEPLength = 100;
cfgNDP.ChannelCoding = userConfig.FEC_TYPE;
% ruInfo
sysInfo = ruInfo(cfgNDP);

fs = wlanSampleRate(cfgNDP);
ind = wlanFieldIndices(cfgNDP);
chanBW = cfgNDP.ChannelBandwidth;

while 1
    % Generate NDP packet
    txWaveform = wlanWaveformGenerator(randi([0 1], getPSDULength(cfgNDP)*8, 1, 'int8'), cfgNDP);

    % Pass the NDP through TGax channel
    rxWaveform = tgax([txWaveform; zeros(15,size(txWaveform,2))]);

    % Pass the NDP through AWGN channel
    packetSNR = convertSNR(SNR,"snrsc","snr",...
        FFTLength=ofdmInfo.FFTLength,...
        NumActiveSubcarriers=sum(sysInfo.RUSizes));
    rxWaveform = awgn(rxWaveform,packetSNR);

    % Receive processing
    % Packet detect and determine coarse packet offset
    coarsePktOffset = wlanPacketDetect(rxWaveform,chanBW,0,0.05);
    if isempty(coarsePktOffset) % If empty no L-STF detected; packet error
        continue; % Go to next loop iteration
    end

    % Extract the non-HT fields and determine fine packet offset
    nonhtfields = rxWaveform(coarsePktOffset+(ind.LSTF(1):ind.LSIG(2)),:);
    finePktOffset = wlanSymbolTimingEstimate(nonhtfields,chanBW);

    % Determine final packet offset
    pktOffset = coarsePktOffset+finePktOffset;
    % If packet detected out with the range of expected delays from
    % the channel modeling; packet error
    if pktOffset>50
        continue; % Go to next loop iteration
    end

    % Extract HE-LTF and HE-Data fields for all RUs
    rxLTF = rxWaveform(pktOffset+(ind.HELTF(1):ind.HELTF(2)),:);
    rxData = rxWaveform(pktOffset+(ind.HEData(1):ind.HEData(2)),:);

    % Demodulate HE-LTF and HE-Data field
    demodHELTF = wlanHEDemodulate(rxLTF, 'HE-LTF',chanBW, cfgNDP.GuardInterval, cfgNDP.HELTFType, [sysInfo.RUSizes(1), sysInfo.RUIndices(1)]);
    demodHEData = wlanHEDemodulate(rxData,'HE-Data',chanBW, cfgNDP.GuardInterval, [sysInfo.RUSizes(1), sysInfo.RUIndices(1)]);

    % Channel estimate
    [chanEst,ssPilotEst] = wlanHELTFChannelEstimate(demodHELTF,cfgNDP);

    % Get indices of data and pilots (without nulls)
    OFDMInfo = wlanHEOFDMInfo('HE-Data',cfgNDP.ChannelBandwidth,cfgNDP.GuardInterval, [sysInfo.RUSizes(1) sysInfo.RUIndices(1)]);

    % Estimate noise power in HE fields
    nVarEst = wlanHEDataNoiseEstimate(demodHEData(OFDMInfo.PilotIndices,:,:),ssPilotEst,cfgNDP, 1);

    % Calculate SINR per subcarrier
    sinr = 10*log10(abs(chanEst(1:242, :, :) ).^2 ./ nVarEst);
    break;
end
end