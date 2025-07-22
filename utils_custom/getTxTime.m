function txtime = getTxTime(params, tones_per_user, apep_length, he_mcs)
    % CUSTOM FUNCTION 
    % Returns transmission time. Takes as arguments:
    % - common parameters
    % - RU Size (or number of tones/subcarriers per user)
    % - APEP length (in Bytes)
    % - MCS 
    
    % Common parameters
    PPDU_TYPE = params.PPDU_TYPE;           % = {'TB PPDU', 'SU PPDU', 'MU PPDU', 'ER SU PPDU'}
    LTF_TYPE = params.LTF_TYPE;             % = {1,2,4} for 1X, 2X or 4X
    GI_TYPE = params.GI_TYPE;               % = {0.8, 1.6, 3.2}
    SIG_EXTENSION = params.SIG_EXTENSION;   % in �s, 0 for 5GHz, 6 for 2.4GHz
    N_MA = params.N_MA;                     % number of midambles
    N_STS = params.N_STS;                   % number of space-time streams
    BW = params.BW;                         % bandwidth in MHz
    SIG_B_MCS = params.SIG_B_MCS;           % 0..5
    FEC_TYPE = params.FEC_TYPE;             % = {LDPC, BCC}
    % User specific parameters
    TONES_PER_USER = tones_per_user;        % number of tones per user whose transmit time is to be analyszed (for TB PPDU only)
    APEP_LENGTH = apep_length;              % in byte 0..~6 500 000
    HE_MCS = he_mcs;                        % 0..11

    % MU settings
    NUM_USER_MU = 9; % number of users in MU
    APEP_LENGTH_MU = 4.*ones(NUM_USER_MU, 1);
    TONE_CONFIG_MU = 26.*ones(NUM_USER_MU, 1);
    MCS_CONFIG_MU = 0.*ones(NUM_USER_MU, 1);
    
    if strcmp(PPDU_TYPE,'SU PPDU')
        NUM_USER_MU = 1;
        MCS_CONFIG_MU = HE_MCS;
    end
        
    
    % CONSTANTS
    T_PE = 0; % ={0, 4, 8, 12, 16}�s
    T_RLSIG = 4; % in �s
    T_HESIGA = 8;
    T_HESIGAR = 16;
    T_HESIGB = 4;
    T_HESTFT = 8;
    T_HESTFNT = 4;
    switch LTF_TYPE
        case 1
            T_HELTF = 3.2;
        case 2
            T_HELTF = 6.4;
        case 4
            T_HELTF = 12.8;
        otherwise
            error('');
    end
    
    switch GI_TYPE
        case 0.8
            T_GIHELTF = 0.8;
            T_SYM = 13.6;
        case 1.6
            T_GIHELTF = 1.6;
            T_SYM = 14.4;
        case 3.2
            T_GIHELTF = 3.2;
            T_SYM = 16;
        otherwise
            error('');
    end
    
    T_HELTFSYM = T_HELTF + T_GIHELTF; 
    
    if (N_STS == 1)
        N_HELTF = 1;
    else
        N_HELTF = ceil(N_STS./2)*2;
    end
    
    
    % data length of SIG-B field
    if ((BW==20) || (BW==40))
        sigB_length = 8+11 + 52.*ceil(NUM_USER_MU./2);
        switch SIG_B_MCS
            case 0
                N_DBPS = 26;
            case 1
                N_DBPS = 52;
            case 2 
                N_DBPS = 78;
            case 3
                N_DBPS = 104;
            case 4
                N_DBPS = 156;
            case 5
                N_DBPS = 208;
            otherwise
                error('SIG_B_MCS out of range');
        end
        
        N_HESIGB = ceil(sigB_length./N_DBPS); % in �s
    end
    
    switch FEC_TYPE
        case 'LDPC'
            N_tail = 0;
        case 'BCC'
            N_tail = 6;
        otherwise
            error('FEC TYPE unknown');
    end
    
    if ~strcmp(PPDU_TYPE,'MU PPDU')
        NUM_USER_MU = 1;
    end
    
    N_DBPS_MU = zeros(NUM_USER_MU,1);
    
    for c = 1:NUM_USER_MU
        
        if strcmp(PPDU_TYPE,'MU PPDU')
            TONES_PER_USER = TONE_CONFIG_MU(c);
            HE_MCS = MCS_CONFIG_MU(c);
        end
        
        switch PPDU_TYPE
            case 'SU PPDU'
                switch BW
                    case {20, 40}
                        % assumes no DCM
                        switch HE_MCS
                            case 0
                                N_DBPS = 117*BW/20;
                            case 1
                                N_DBPS = 234*BW/20;
                            case 2
                                N_DBPS = 351*BW/20;
                            case 3
                                N_DBPS = 468*BW/20;
                            case 4
                                N_DBPS = 702*BW/20;
                            case 5
                                N_DBPS = 936*BW/20;
                            case 6
                                N_DBPS = 1053*BW/20;
                            case 7
                                N_DBPS = 1170*BW/20;
                            case 8
                                N_DBPS = 1404*BW/20;
                            case 9
                                N_DBPS = 1560*BW/20;
                            case 10
                                N_DBPS = 1755*BW/20;
                            case 11
                                N_DBPS = 1950*BW/20;
                        end
                    case 80
                        % assumes no DCM
                        switch HE_MCS
                            case 0
                                N_DBPS = 490;
                            case 1
                                N_DBPS = 980;
                            case 2
                                N_DBPS = 1470;
                            case 3
                                N_DBPS = 1960;
                            case 4
                                N_DBPS = 2940;
                            case 5
                                N_DBPS = 3920;
                            case 6
                                N_DBPS = 4410;
                            case 7
                                N_DBPS = 4900;
                            case 8
                                N_DBPS = 5880;
                            case 9
                                N_DBPS = 6533;
                            case 10
                                N_DBPS = 7350;
                            case 11
                                N_DBPS = 8166;
                        end
                    otherwise
                        error('Bandwidth not implemented yet');
                end
            case {'TB PPDU','MU PPDU'}
                switch TONES_PER_USER % see section 28.5.1 of 11ax D3.0 (p589) for more
                    case {26, 52}
                        % assumes no DCM
                        switch HE_MCS
                            case 0
                                N_DBPS = 12*TONES_PER_USER/26;
                            case 1
                                N_DBPS = 24*TONES_PER_USER/26;
                            case 2
                                N_DBPS = 36*TONES_PER_USER/26;
                            case 3
                                N_DBPS = 48*TONES_PER_USER/26;
                            case 4
                                N_DBPS = 72*TONES_PER_USER/26;
                            case 5
                                N_DBPS = 96*TONES_PER_USER/26;
                            case 6
                                N_DBPS = 108*TONES_PER_USER/26;
                            case 7
                                N_DBPS = 120*TONES_PER_USER/26;
                            case 8
                                N_DBPS = 144*TONES_PER_USER/26;
                            case 9
                                N_DBPS = 160*TONES_PER_USER/26;
                            case 10
                                N_DBPS = 180*TONES_PER_USER/26;
                            case 11
                                N_DBPS = 200*TONES_PER_USER/26;
                        end
                    case 106
                        % assumes no DCM
                        switch HE_MCS
                            case 0
                                N_DBPS = 51;
                            case 1
                                N_DBPS = 102;
                            case 2
                                N_DBPS = 153;
                            case 3
                                N_DBPS = 204;
                            case 4
                                N_DBPS = 306;
                            case 5
                                N_DBPS = 408;
                            case 6
                                N_DBPS = 459;
                            case 7
                                N_DBPS = 510;
                            case 8
                                N_DBPS = 612;
                            case 9
                                N_DBPS = 680;
                            case 10
                                N_DBPS = 765;
                            case 11
                                N_DBPS = 850;
                        end
                    case {242,484}
                        % assumes no DCM
                        switch HE_MCS
                            case 0
                                N_DBPS = 117*TONES_PER_USER/242;
                            case 1
                                N_DBPS = 234*TONES_PER_USER/242;
                            case 2
                                N_DBPS = 351*TONES_PER_USER/242;
                            case 3
                                N_DBPS = 468*TONES_PER_USER/242;
                            case 4
                                N_DBPS = 702*TONES_PER_USER/242;
                            case 5
                                N_DBPS = 936*TONES_PER_USER/242;
                            case 6
                                N_DBPS = 1053*TONES_PER_USER/242;
                            case 7
                                N_DBPS = 1170*TONES_PER_USER/242;
                            case 8
                                N_DBPS = 1404*TONES_PER_USER/242;
                            case 9
                                N_DBPS = 1560*TONES_PER_USER/242;
                            case 10
                                N_DBPS = 1755*TONES_PER_USER/242;
                            case 11
                                N_DBPS = 1950*TONES_PER_USER/242;
                        end
                    otherwise
                        error('Number of tones not implemented yet');
                end
            otherwise
                error('PPDU type not yet implemented')
        end
        
        N_DBPS_MU(c) = N_DBPS;
    end
            
            
    
    
    switch PPDU_TYPE
        case 'TB PPDU'
            T_HEPREAMBLE = T_RLSIG + T_HESIGA + T_HESTFT + N_HELTF*T_HELTFSYM;
            % assumes no STBC and no LDPC extra symbol segment
            N_SYM = ceil((8*APEP_LENGTH + N_tail + 16)./N_DBPS);        
        case 'SU PPDU'
            T_HEPREAMBLE = T_RLSIG + T_HESIGA + T_HESTFNT + N_HELTF*T_HELTFSYM;
            N_DBPS=N_DBPS*N_STS;       
            % assumes no STBC
            N_SYMinit = ceil((8*APEP_LENGTH + N_tail + 16)./N_DBPS);
            NExcess = mod(8*APEP_LENGTH + N_tail + 16, N_DBPS);
            if (NExcess==0)
                N_SYM = N_SYMinit + 1;            
            else
                N_SYM = N_SYMinit;
            end
            
        case 'MU PPDU'
            T_HEPREAMBLE = T_RLSIG + T_HESIGA + T_HESTFNT + N_HELTF*T_HELTFSYM + N_HESIGB*T_HESIGB;
            % did some simplifications in N_SYM computation
            
            for c = 1:NUM_USER_MU
                N_SYMinit(c) = ceil((8*APEP_LENGTH_MU(c) + N_tail + 16)./N_DBPS_MU(c));
                NExcess = mod(8*APEP_LENGTH_MU(c) + N_tail + 16, N_DBPS_MU(c));
                if (NExcess==0)
                    N_SYMinit(c) = N_SYMinit(c) + 1;
                else
                    N_SYMinit(c) = N_SYMinit(c);
                end
            end
            N_SYM = max(N_SYMinit);
            
        case 'ER SU PPDU'
            T_HEPREAMBLE = T_RLSIG + T_HESIGAR + T_HESTFNT + N_HELTF*T_HELTFSYM;
        otherwise
            error('PPDU TYPE unknown')
    end
    
    
    

    % assumption: no packet extension
    % txtime = 20 + T_HEPREAMBLE + N_SYM*T_SYM + N_MA*N_HELTF*T_HELTFSYM + T_PE + SIG_EXTENSION;
    txtime = 20 + T_HEPREAMBLE + N_SYM*T_SYM + N_MA*N_HELTF*T_HELTFSYM + SIG_EXTENSION;
end