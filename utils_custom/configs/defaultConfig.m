function config = defaultConfig()
% CHANNEL CONFIG
channelConfig = struct();
% Get an HE OFDM configuration: 20MHz channel bandwidth, 3.2 us guard interval
channelConfig.ofdmInfo = wlanHEOFDMInfo('HE-Data', 'CBW20', 3.2);
% Configure common channel parameters
channelConfig.tgaxBase = wlanTGaxChannel;
channelConfig.tgaxBase.ChannelBandwidth = 'CBW20';                                % Channel bandwidth
channelConfig.tgaxBase.SampleRate = 20e6;                                         % Sample rate of the input signal
channelConfig.tgaxBase.ChannelFiltering = true;                                   % Channel filtering. If false, the step function does not accept an input signal. In this case the NumSamples and SampleRate properties determine the duration of the fading process realization
channelConfig.tgaxBase.TransmissionDirection = 'Uplink';                          % Transmission direction
channelConfig.tgaxBase.TransmitReceiveDistance = 10;                              % Distance between transmit antenna elements
channelConfig.tgaxBase.NumTransmitAntennas = 1;                                   % Number of transmit antennas
channelConfig.tgaxBase.NumReceiveAntennas = 1;                                    % Number of receive antennas
channelConfig.tgaxBase.NormalizeChannelOutputs = false;                           % Normalize channel outputs by the number of receive antennas

% SNR CONFIG
snrConfig = struct();
% Set powers of signal of interest, interfering signal and noise.
snrConfig.Psoi = -45;                                                             % Signal of interest received power (dBm)
snrConfig.N0 = -85;                                                               % Noise power (dBm)
snrConfig.SNR = pow2db(db2pow(snrConfig.Psoi-30)/db2pow(snrConfig.N0-30));        % SNR

% MCS CONFIG
mcsConfig = struct();
% Load table SNR_MCS_PDR_1458_LDPC
mcsConfig.table_mcs = readmatrix('SNR_MCS_PDR_1458_LDPC.csv');
% Set target PDR
mcsConfig.target_PDR = 0.95;

% USER CONFIG
% Common parameters (for tx_time)
userConfig = struct();
userConfig.PPDU_TYPE = 'TB PPDU';                                                % = {'TB PPDU', 'SU PPDU', 'MU PPDU', 'ER SU PPDU'}
userConfig.LTF_TYPE = 4;                                                         % = {1,2,4} for 1X, 2X or 4X
userConfig.GI_TYPE = 3.2;                                                        % = {0.8, 1.6, 3.2}
userConfig.SIG_EXTENSION = 0;                                                    % in �s, 0 for 5GHz, 6 for 2.4GHz
userConfig.N_MA = 0;                                                             % Number of midambles
userConfig.N_STS = 1;                                                            % Number of space-time streams
userConfig.BW = 20;                                                              % Bandwidth in MHz
userConfig.SIG_B_MCS = 0;                                                        % 0..5
userConfig.FEC_TYPE = 'LDPC';                                                    % = {LDPC, BCC}

% CONSTANTS CONFIG
constantsConfig = struct();
constantsConfig.PPDULimit = 5484;                                                % PPDU limit in microseconds
constantsConfig.TXOPLimit = 4096;                                                % TXOP limit in microseconds
constantsConfig.SIFS = 16;                                                       % SIFS duration in microseconds
constantsConfig.triggerFrame = 48;                                               % Trigger frame duration in microseconds

config = struct();
config.channelConfig = channelConfig;
config.snrConfig = snrConfig;
config.mcsConfig = mcsConfig;
config.userConfig = userConfig;
config.constantsConfig = constantsConfig;
end