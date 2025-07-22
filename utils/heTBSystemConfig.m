classdef heTBSystemConfig < comm.internal.ConfigBase
%heTBSystemConfig Create a high efficiency trigger-based(TB) system format configuration object
%   CFG = heTBSystemConfig(AllocationIndex) creates a high efficiency
%   trigger-based (HE TB) system format configuration object. The object
%   sets common and per user transmission properties.
%
%   AllocationIndex specifies the resource unit (RU) allocation. The
%   allocation defines the number and sizes of RUs, and the number of users
%   assigned to each RU. IEEE Std 802.11ax-2021, Table 27-26 defines the
%   assignment index as an 8-bit index for each 20 MHz subchannel. The RU
%   allocation for each assignment index can be viewed in <a href="matlab:doc('wlanHEMUConfig')">the documentation</a>.
%
%   AllocationIndex can be a vector of integers between 0 and 223
%   inclusive, a string array, a character vector, or a cell array of
%   character vectors.
%
%   When AllocationIndex is specified as a vector of integers, each element
%   corresponds to an 8 bit index in Table 27-26. The length of
%   AllocationIndex must be 1, 2, 4, or 8, defining the assignment for each
%   20 MHz subchannel in a 20 MHz, 40 MHz, 80 MHz or 160 MHz channel
%   bandwidth. For a full band allocation with a single RU, AllocationIndex
%   can be specified as a scalar between 192 and 223 inclusive.
%
%   AllocationIndex can also be specified using the corresponding 8-bit
%   binary vector per allocation as specified in Table 27-26. An 8 bit
%   binary sequence can be provided as a character vector or string. A
%   string vector or cell array of character vectors can be used to
%   specify an allocation per 20 MHz subchannel.
%
%   To configure an OFDMA transmission greater than 20 MHz, AllocationIndex
%   consists of an assignment index for each 20 MHz subchannel. For
%   example, to configure an 80 MHz OFDMA transmission, a numeric row
%   vector with 4 allocation indices, or a string array with 4 elements is
%   required. The RU allocation for each assignment index can be viewed in
%   <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a> object. The AllocationIndex 113 signals
%   the corresponding 20 MHz subchannel is punctured, and is only valid for
%   an 80 MHz or 160 MHz transmission. The AllocationIndex 114 or 115
%   signals an empty RU. This AllocationIndex is only valid when configured
%   with other appropriate 484 or 996-tone RU assignment indices for an 80
%   MHz or 160 MHz transmission.
%
%   To configure a full band MU-MIMO transmission the following values of
%   AllocationIndex can be used:
%      20 MHz:  AllocationIndex = 191 + NumUsers
%      40 MHz:  AllocationIndex = 199 + NumUsers
%      80 MHz:  AllocationIndex = 207 + NumUsers
%      160 MHz: AllocationIndex = 215 + NumUsers
%
%   CFG = heTBSystemConfig(...,'LowerCenter26ToneRU',true,'UpperCenter26ToneRU',true)
%   additionally allows the lower and/or upper frequency center 26-tone RUs
%   to be enabled for an 80 MHz or 160 MHz transmission which is not full
%   band. The lower center 26-tone RU can only be used when AllocationIndex
%   specifies an 80 MHz or 160 MHz transmission. The upper center 26-tone
%   RU can only be used when AllocationIndex signifies an 160 MHz
%   transmission. When not specified the center 26-tone RUs are not used.
%
%   The returned configuration object CFG is parameterized according to the
%   assignment index. The RU and User properties are configured as per the
%   assignment.
%
%   CFG = heTBSystemConfig(...,Name,Value) creates a HE TB object, CFG,
%   with the specified property Name set to the specified Value. You can
%   specify additional name-value pair arguments in any order as
%   (Name1,Value1, ...,NameN,ValueN). The ChannelBandwidth, RU, and User
%   properties are derived from the AllocationIndex and therefore cannot be
%   specified using name-value pairs.
%
%   heTBSystemConfig methods:
%
%   getPSDULength       - Number of bytes to be coded in the packet
%   packetFormat        - HE TB packet format
%   ruInfo              - Resource unit allocation information
%   getTRSConfiguration - Create a valid TRS configuration object
%   getUserConfig       - Generate configuration objects of type
%                         wlanHETBConfig for all uplink HE TB users
%
%   heTBSystemConfig properties:
%
%   AllocationIndex         - RU allocation index for each 20 MHz subchannel
%   LowerCenter26ToneRU     - Lower center 26-tone RU allocation signaling
%   UpperCenter26ToneRU     - Upper center 26-tone RU allocation signaling
%   RU                      - RU properties of each assignment index
%   User                    - User properties of each assignment index
%   TriggerMethod           - Method used to trigger an HE TB PPDU
%   PreHEPowerScalingFactor - Power scaling factor for pre-HE TB field
%   STBC                    - Enable space-time block coding
%   GuardInterval           - Guard interval type
%   HELTFType               - HE-LTF compression type
%   SingleStreamPilots      - Indicate HE-LTF single-stream pilots
%   PreFECPaddingFactor     - The pre-FEC padding factor for an HE TB PPDU
%   DefaultPEDuration       - Packet extension duration in microseconds
%   BSSColor                - Basic service set (BSS) color identifier
%   SpatialReuse            - Spatial reuse indication
%   TXOPDuration            - Duration information for TXOP protection
%   HighDoppler             - High Doppler mode indication
%   MidamblePeriodicity     - Midamble periodicity in number of OFDM symbols
%   HESIGAReservedBits      - Reserved bits in HE-SIG-A field
%   ChannelBandwidth        - Channel bandwidth (MHz) of HE TB PPDU
%
%   See also wlanWaveformGenerator, wlanHETBConfig

%   Copyright 2017-2023 The MathWorks, Inc.

properties
    %RU RU properties of each assignment index
    %   Set the transmission properties for each RU in the transmission.
    %   This property is a cell array of <a href="matlab:help('heTBRU')">heTBRU</a> objects. Each element
    %   of the cell array contains properties to configure an RU. This
    %   property is configured when the object is created based on the
    %   defined AllocationIndex.
    RU;
    %User User properties of each assignment index
    %   Set the transmission properties for each User in the transmission.
    %   This property is a cell array of <a href="matlab:help('heTBUser')">heTBUser</a> objects. Each element
    %   of the cell array contains properties to configure a User. This
    %   property is configured when the object is created based on the
    %   defined AllocationIndex.
    User;
    %TriggerMethod Method used to trigger an HE TB PPDU
    %   Indicate the method used to trigger an HE TB PPDU transmission.
    %   Specify this property as 'TriggerFrame' or 'TRS'. The default value
    %   of this property is 'TriggerFrame'.
    TriggerMethod = 'TriggerFrame';
    %PreHEPowerScalingFactor Power scaling factor for pre-HE TB field
    %   Specify the power scaling factor for the pre-HE TB fields in the
    %   range [1/sqrt(2),1]. The default value of this property is 1.
    PreHEPowerScalingFactor (1,1) {mustBeNumeric,mustBeValidValue(PreHEPowerScalingFactor)} = 1;
    %STBC Enable space-time block coding
    %   Set this property to true to enable space-time block coding in the
    %   data field transmission. STBC can only be applied for two
    %   space-time streams. The default value of this property is false.
    STBC (1,1) logical = false;
    %GuardInterval Guard interval type
    %   Specify the guard interval (cyclic prefix) length in microseconds
    %   as one of 0.8, 1.6 or 3.2. The default is 3.2.
    GuardInterval (1,1) {mustBeNumeric,mustBeMember(GuardInterval,[0.8,1.6,3.2])} = 3.2;
    %HELTFType HE-LTF compression type
    %   Specify the HE-LTF compression type as one of 1, 2, or 4,
    %   corresponding to 1xHE-LTF, 2xHE-LTF and 4xHE-LTF type respectively.
    %   The default is 4.
    HELTFType (1,1) {mustBeNumeric,mustBeMember(HELTFType,[1 2 4])} = 4;
    %SingleStreamPilots Indicate HE-LTF single-stream pilots
    %   To indicate that the HE-LTF field uses single-stream pilots, set
    %   this property to true. The default is true.
    SingleStreamPilots (1,1) logical = true;
    %PreFECPaddingFactor Specify the pre-FEC padding factor for an HE TB PPDU
    %   Specify the pre-FEC padding factor for an HE TB PPDU as 1,2,3 or 4.
    %   This property applies only when TriggerMethod property is set to
    %   TRS. The default is 4.
    PreFECPaddingFactor (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(PreFECPaddingFactor,1),mustBeLessThanOrEqual(PreFECPaddingFactor,4)} = 4;
    %DefaultPEDuration Packet extension duration in microseconds
    %   Specify Packet extension duration as 0, 4, 8, 12 or 16. This
    %   property applies only when the TriggerMethod property is set to
    %   TRS. The default is 0.
    DefaultPEDuration (1,1) {mustBeNumeric,mustBeMember(DefaultPEDuration,[0,4,8,12,16])} = 0;
    %BSSColor Basic service set (BSS) color identifier
    %   Specify the BSS color number of a basic service set as an integer
    %   scalar between 0 to 63, inclusive. The default is 0.
    BSSColor (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(BSSColor,0),mustBeLessThanOrEqual(BSSColor,63)} = 0;
    %SpatialReuse Spatial reuse indication
    %   Specify the SpatialReuse as a vector of size 1-by-4, where each
    %   element of the vector is an integer scalar between 0 and 15,
    %   inclusive. The element of the vector represents spatial reuse
    %   1-to-4 in HE-SIG-A field. The default is a row vector of all
    %   fifteens.
    SpatialReuse (1,4) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(SpatialReuse,0),mustBeLessThanOrEqual(SpatialReuse,15)} = [15 15 15 15];
    %TXOPDuration Duration information for TXOP protection
    %   Specify the TXOPDuration signaled in HE-SIG-A as an integer scalar
    %   between 0 and 127, inclusive. The TXOP field in HE-SIG-A is set
    %   directly to TXOPDuration, therefore a duration in microseconds must
    %   be converted before being used as specified in Table 27-21 of IEEE
    %   Std 802.11ax-2021. For more information see the <a href="matlab:doc('wlanHEMUConfig')">documentation</a>
    TXOPDuration (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(TXOPDuration,0),mustBeLessThanOrEqual(TXOPDuration,127)} = 127;
    %HighDoppler High Doppler mode indication
    %   Set this property to true to indicate high doppler in HE-SIG-A. The
    %   default is false.
    HighDoppler (1,1) logical = false;
    %MidamblePeriodicity Midamble periodicity in number of OFDM symbols
    %   Specify the MidamblePeriodicity in number of OFDM symbols in
    %   HE-Data field as one of 10 or 20. This property applies only when
    %   HighDoppler property is set to true. The default is 10.
    MidamblePeriodicity (1,1) {mustBeNumeric,mustBeMember(MidamblePeriodicity,[10 20])} = 10;
    %HESIGAReservedBits Reserved bits in HE-SIG-A field
    %   Specify the reserved field bits in HE-SIG-A2 as a binary column
    %   vector of length 9. The default value of this property is a column
    %   vector of ones.
    HESIGAReservedBits (9,1) {mustBeNumeric,mustBeInteger} = ones(9,1);
end

properties(SetAccess = 'private')
    %ChannelBandwidth Channel bandwidth (MHz) of HE TB PPDU
    %   The channel bandwidth, specified as one of 'CBW20' | 'CBW40' |
    %   'CBW80' | 'CBW160'. This property is set when the object is created
    %   based on the defined AllocationIndex.
    ChannelBandwidth = 'CBW20';
    %AllocationIndex RU allocation index for each 20 MHz subchannel
    %   Specify the RU allocation index when creating the object. Once the
    %   object is created, AllocationIndex is read only. The allocation
    %   index defines the number and sizes of RUs, and the number of users
    %   assigned to each RU. Table 27-26 of IEEE Std 802.11ax-2021 defines
    %   the assignment index as an 8 bit index for each 20 MHz subchannel.
    %
    %   AllocationIndex can be a vector of integers between 0 and 223, a
    %   string array, a character vector, or a cell array of character
    %   vectors.
    %
    %   When AllocationIndex is specified as a vector of integers, each
    %   element corresponds to an 8 bit index in Table 27-26. The length of
    %   AllocationIndex must be 1, 2, 4, or 8, defining the assignment for
    %   each 20 MHz subchannel in an 20 MHz, 40 MHz, 80 MHz or 160 MHz
    %   channel bandwidth, or for a full band allocation with a single RU,
    %   a scalar between 192 and 223.
    %
    %   AllocationIndex can also be specified using the corresponding 8-bit
    %   binary vector per allocation as specified in Table 27-26. An 8 bit
    %   binary sequence can be provided as a character vector or string. A
    %   string vector or cell array of character vectors can be used to
    %   specify an allocation per 20 MHz subchannel.
    %
    %   To configure an OFDMA transmission greater than 20 MHz,
    %   AllocationIndex consists of an assignment index for each 20 MHz
    %   subchannel. For example, to configure an 80 MHz OFDMA transmission,
    %   a numeric row vector with 4 allocation indices, or a string array
    %   with 4 elements is required. The RU allocation for each assignment
    %   index can be viewed in <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a> object. The AllocationIndex
    %   113 signals the corresponding 20 MHz subchannel is punctured, and
    %   is only valid for an 80 MHz or 160 MHz transmission. The
    %   AllocationIndex 114 or 115 signals is only valid when configured
    %   with other appropriate 484 or 996-tone RU assignment indices for an
    %   80 MHz or 160 MHz transmission.
    %
    %   To configure a full band MU-MIMO transmission the following values
    %   of AllocationIndex can be used:
    %      20 MHz:  AllocationIndex = 191 + NumUsers
    %      40 MHz:  AllocationIndex = 199 + NumUsers
    %      80 MHz:  AllocationIndex = 207 + NumUsers
    %      160 MHz: AllocationIndex = 215 + NumUsers
    AllocationIndex = 192;
    %LowerCenter26ToneRU Lower center 26-tone RU allocation signaling
    %   Set this property to true using name-value pairs when the object is
    %   created to enable the lower frequency center 26-tone RU. After the
    %   object is created this property is read only. This property only be
    %   set to true when the channel bandwidth is 80 MHz or 160 MHz and a
    %   full bandwidth allocation is not used. This property is only
    %   visible when the RU allocation is appropriate. The default is
    %   false.
    LowerCenter26ToneRU (1,1) logical = false;
    %UpperCenter26ToneRU Upper center 26-tone RU allocation signaling
    %   Set this property to true using name-value pairs when the object is
    %   created to enable the upper frequency center 26-tone RU. After the
    %   object is created this property is read only. This property only be
    %   set to true when the channel bandwidth is 160 MHz and a full
    %   bandwidth allocation is not used. This property is only visible
    %   when the RU allocation is appropriate. The default is false.
    UpperCenter26ToneRU (1,1) logical = false;
end

properties(Constant, Hidden)
    TriggerMethod_Values = {'TriggerFrame','TRS'};
end

properties(Access=private)
  PrivateUserRUNumber = 1;
end

methods
    function obj = heTBSystemConfig(allocationIndexRaw,varargin)
    %heTBSystemConfig Create HE TB system configuration

        narginchk(1,Inf);

        % Determine allocation index given input
        if isstring(allocationIndexRaw) || ischar(allocationIndexRaw) || iscell(allocationIndexRaw)
            if ischar(allocationIndexRaw)
                % Single character array
                coder.internal.errorIf(numel(allocationIndexRaw)~=8,'wlan:wlanHEMUConfig:IncorrectAllocationChar')
                allocationIndex = bin2dec(allocationIndexRaw);
            elseif iscell(allocationIndexRaw)
                % Cell array of character vectors
                n = numel(allocationIndexRaw);
                allocationIndex = zeros(1,n);
                for i = 1:numel(allocationIndexRaw)
                   val = allocationIndexRaw{i};
                   coder.internal.errorIf(~ischar(val) || numel(val)~=8,'wlan:wlanHEMUConfig:IncorrectAllocationChar')
                   allocationIndex(i) = bin2dec(val);
                end
                % String or string array
            elseif isstring(allocationIndexRaw)
                for i = 1:numel(allocationIndexRaw)
                    coder.internal.errorIf(numel(char(allocationIndexRaw(i)))~=8,'wlan:wlanHEMUConfig:IncorrectAllocationChar')
                end
                allocationIndex = bin2dec(allocationIndexRaw);
            end
        else
            % Numeric
            allocationIndex = allocationIndexRaw;
            validateattributes(allocationIndex,{'numeric'},{'integer'})
        end
        validateattributes(allocationIndex,{'numeric'},{'>=',0,'<=',223});
        obj.AllocationIndex = allocationIndex;

        % Process name-value pairs
        if nargin>1
            coder.internal.errorIf((mod(nargin-1,2) ~= 0),'wlan:ConfigBase:InvalidPVPairs');
            for i = 1:2:nargin-1
                obj.(char(varargin{i})) = varargin{i+1};
            end
        end
        obj.AllocationIndex = allocationIndex;
        center26 = [obj.LowerCenter26ToneRU obj.UpperCenter26ToneRU];
        [obj.RU,obj.User,obj.PrivateUserRUNumber] = heRUAllocation(obj.AllocationIndex,center26);

        % Validate preamble puncturing valid
        validatePreamblePuncturing(allocationIndex);

        % Set channel bandwidth based on allocation index
        allocInfo = obj.ruInfo();
        if numel(allocationIndex)==1 && allocInfo.NumRUs==1
            % Allow for a single number, full-band allocation
            switch allocInfo.RUSizes(1)
                case 242
                    obj.ChannelBandwidth = 'CBW20';
                case 484
                    obj.ChannelBandwidth = 'CBW40';
                case 996
                    obj.ChannelBandwidth = 'CBW80';
                case 2*996
                    obj.ChannelBandwidth = 'CBW160';
            end
        else
            switch numel(allocationIndex)
                case 1
                    obj.ChannelBandwidth = 'CBW20';
                case 2
                    obj.ChannelBandwidth = 'CBW40';
                case 4
                    obj.ChannelBandwidth = 'CBW80';
                case 8
                    obj.ChannelBandwidth = 'CBW160';
            end
        end
    end

    function obj = set.TriggerMethod(obj,val)
        val = validateEnumProperties(obj,'TriggerMethod',val);
        obj.TriggerMethod = '';
        obj.TriggerMethod= val;
    end

    function varargout = validateConfig(obj)
    %validateConfig Validate the dependent properties of heTBSystemConfig object
    %   validateConfig(obj) validates the dependent properties for the
    %   specified heTBSystemConfig configuration object.
    %
    %   For INTERNAL use only, subject to future changes

        nargoutchk(0,1);

        % Validate properties when TriggerMethod is set to TRS
        if strcmp(obj.TriggerMethod,'TRS')
            validateTRS(obj)
        end

        % Validate Spatial mapping properties and spatial mapping matrix
        validateSpatialMapping(obj)

        % Validate pre-HE cyclic shift values and NumTransmitAntennas
        validatePreHECyclicShifts(obj);

        % Validate HELTFType and GuardInterval for HE-LTF
        validateHELTFGI(obj);

        % Validate MCS and length
        s = validateMCSLength(obj);

        if nargout == 1
            varargout{1} = s;
        end
    end

    function s = ruInfo(obj)
    %ruInfo Returns information relevant to the resource unit
    %   S = ruInfo(cfgHE) returns a structure, S, containing the resource
    %   unit (RU) allocation information for the heTBSystemConfig object,
    %   cfgHE. The output structure S has the following fields:
    %
    %   NumUsers                 - Total number of users
    %   NumRUs                   - Total number of RUs
    %   RUIndices                - Vector containing the index of each RU
    %   RUSizes                  - Vector containing the size of each RU
    %   NumUsersPerRU            - Vector containing the number of users
    %                              per RU
    %   NumSpaceTimeStreamsPerRU - Vector containing the total number of
    %                              space-time streams per RU
    %   PowerBoostFactorPerRU    - Vector containing the power boost factor
    %                              per RU
    %   RUNumbers                - Vector containing the index of the
    %                              corresponding cfgHE.RU object for
    %                              each active RU.
    %
    %   If an RU is inactive (as the user AID12 is 2046), the inactive RU
    %   information is not returned as part of the allocation information.

        numRUs = numel(obj.RU);
        numUsers = numel(obj.User);
        ruActive = true(1,numRUs);
        for j = 1:numUsers
           if (obj.User{j}.APEPLength==0 || obj.User{j}.AID12==2046)
               ruNum = obj.User{j}.RUNumber;
               if ruNum<=numRUs
                   ruActive(ruNum) = false;
               end
           end
        end
        numActiveRUs = sum(ruActive==true);
        numActiveUsers = numUsers;
        ruIndices = zeros(1,numActiveRUs);
        ruSizes = zeros(1,numActiveRUs);
        ruNumbers = zeros(1,numActiveRUs); 
        numSTS = zeros(1,numActiveRUs);
        numUsersPerRU = zeros(1,numActiveRUs);

        k = 1;
        for i = 1:numRUs
            if ~ruActive(i)
               continue
            end
            for j = 1:numUsers
                ruShared = i==obj.PrivateUserRUNumber(j);
                if ruShared
                    numUsersPerRU(k) = numUsersPerRU(k)+1;
                    numSTS(k) = numSTS(k)+obj.User{j}.NumSpaceTimeStreams;
                end
            end
            ruIndices(k) = obj.RU{i}.Index;
            ruSizes(k) = obj.RU{i}.Size;
            ruNumbers(k) = i;
            k = k+1;
        end

       s = struct;
       s.NumUsers = numActiveUsers;
       s.NumRUs = numActiveRUs;
       s.RUIndices = ruIndices;
       s.RUSizes = ruSizes;
       s.NumUsersPerRU = numUsersPerRU;
       s.NumSpaceTimeStreamsPerRU = numSTS;
       s.PowerBoostFactorPerRU = ones(1,numRUs);
       s.RUNumbers = ruNumbers;
    end

    function psduLength = getPSDULength(obj)
    %getPSDULength Returns PSDU length for the configuration
    %   Returns a row vector with the required PSDU length for each user.
    %   For more information, see IEEE Std 802.11ax-2021, Section 27.4.3

        if strcmp(obj.TriggerMethod,'TRS')
            psduLength = heTRSPLMETxTimePrimative(obj);
        else
            psduLength = wlan.internal.hePLMETxTimePrimative(obj);
        end
    end

    function format = packetFormat(obj) %#ok<MANU>
    %packetFormat Returns the packet format
    %   Returns the packet format as a character vector.

        format = 'HE-TB';
    end

    function y = getUserConfig(obj)
    %getUserConfig Generate an HE TB configuration objects for all users
    %   Y = getUserConfig(obj) returns a cell array Y, containing a
    %   wlanHETBConfig object for all user in the HE TB transmission.

        infoRU = ruInfo(obj); % Get RU information
        if strcmp(obj.TriggerMethod,'TriggerFrame')
            infoSTS = stsInfo(obj); % Get space time sreams information
        end
        y = cell(1,infoRU.NumUsers);

        % Create an HE TB config object and update it with common
        % properties
        cfgRef = wlanHETBConfig;
        cfgRef.TriggerMethod = obj.TriggerMethod;
        cfgRef.ChannelBandwidth = obj.ChannelBandwidth;
        cfgRef.GuardInterval = obj.GuardInterval;
        cfgRef.STBC = obj.STBC;
        cfgRef.HELTFType = obj.HELTFType;
        cfgRef.PreHEPowerScalingFactor = obj.PreHEPowerScalingFactor;
        cfgRef.HighDoppler = obj.HighDoppler;
        if obj.HighDoppler
            cfgRef.MidamblePeriodicity = obj.MidamblePeriodicity;
        end
        cfgRef.BSSColor = obj.BSSColor;
        cfgRef.SingleStreamPilots = obj.SingleStreamPilots;
        cfgRef.NumHELTFSymbols = wlan.internal.numVHTLTFSymbols(max(infoRU.NumSpaceTimeStreamsPerRU));
        cfgRef.SpatialReuse1 = obj.SpatialReuse(1);
        cfgRef.SpatialReuse2 = obj.SpatialReuse(2);
        cfgRef.SpatialReuse3 = obj.SpatialReuse(3);
        cfgRef.SpatialReuse4 = obj.SpatialReuse(4);
        cfgRef.TXOPDuration = obj.TXOPDuration;
        cfgRef.HESIGAReservedBits = obj.HESIGAReservedBits;
        if strcmp(obj.TriggerMethod,'TRS')
            commonParams = heTRSCodingParameters(obj);
            cfgRef.StartingSpaceTimeStream = 1;
            cfgRef.NumDataSymbols = commonParams.NSYM;
            cfgRef.DefaultPEDuration = obj.DefaultPEDuration;
        else % TriggerFrame
            commonParams = wlan.internal.heCodingParameters(obj);
            SignalExtension = 0;
            npp = wlan.internal.heNominalPacketPadding(obj);
            trc = wlan.internal.heTimingRelatedConstants(obj.GuardInterval,obj.HELTFType,commonParams.PreFECPaddingFactor,npp,commonParams.NSYM);
            TPE = trc.TPE;
            TSYM = trc.TSYM;
            s = obj.validateConfig;
            % Calculation in nanoseconds. PEDisambiguity is only needed for TriggerFrame
            cfgRef.PEDisambiguity = (TPE+4*(ceil((s.TxTime-SignalExtension-20)/4)-(s.TxTime-SignalExtension-20)/4))>=TSYM; % IEEE P802.11ax/D4.1, Equation 27-118
            % Set L-SIG length
            cfgRef.LSIGLength = s.LSIGLength;
        end
        cfgRef.PreFECPaddingFactor = commonParams.PreFECPaddingFactor;
        cfgRef.LDPCExtraSymbol = commonParams.LDPCExtraSymbol;

        for nRU = 1:infoRU.NumRUs
            for nUsers = 1:infoRU.NumUsersPerRU(nRU)
                userNum = obj.RU{nRU}.UserNumbers(nUsers);
                % Create an HE TB config object for each user and update
                % user specific properties
                cfg = cfgRef;
                if strcmp(cfg.TriggerMethod,'TriggerFrame')
                    cfg.StartingSpaceTimeStream = infoSTS.StartingSpaceTimeStreamNumber(userNum);
                end
                user = obj.User{userNum};
                cfg.DCM = user.DCM;
                cfg.MCS = user.MCS;
                cfg.NumSpaceTimeStreams = user.NumSpaceTimeStreams;
                cfg.ChannelCoding = user.ChannelCoding;
                cfg.NumTransmitAntennas = user.NumTransmitAntennas;
                cfg.RUSize = infoRU.RUSizes(user.RUNumber);
                cfg.RUIndex = infoRU.RUIndices(user.RUNumber);
                cfg.SpatialMapping = user.SpatialMapping;
                cfg.SpatialMappingMatrix = user.SpatialMappingMatrix;
                y{1,userNum} = cfg;
            end
        end
    end

    function s = stsInfo(obj,varargin)
    %stsInfo Returns information relevant to the space time streams for HE TB users
    %   S = ruInfo(obj) returns a structure, S, containing space time
    %   stream of each user within an RU. The output structure S has the
    %   following fields:
    %
    %   NumUsers                      - Number of users in the RU
    %   StartingSpaceTimeStreamNumber - A vector containing the starting
    %                                   space-time stream index per user
    %   SpaceTimeStreamIndices        - A cell array containing the
    %                                   space-time stream indices for each
    %                                   user

        if nargin == 2
            ruIndex = varargin{1};
            s = ruInfo(obj);
            numUsers = s.NumUsersPerRU(ruIndex);
            user = cell(1,numUsers);
            numSTSPerUser = zeros(1,numUsers);
            for i = 1:numUsers
                user{i} = obj.User{obj.RU{ruIndex}.UserNumbers(i)};
                numSTSPerUser(i) = user{i}.NumSpaceTimeStreams;
            end
            startSTSIdxAll = zeros(1,numUsers);
            startSTSIdxAll(1) = 1;
            for i = 2:numUsers
                startSTSIdxAll(i) = startSTSIdxAll(i-1)+obj.User{i-1}.NumSpaceTimeStreams;
            end
        else
            numUsers = numel(obj.User);
            numSTSPerUser = zeros(1,numUsers);
            user = cell(1,numUsers);
            for i = 1:numUsers
                user{i} = obj.User{i};
                numSTSPerUser(i) = user{i}.NumSpaceTimeStreams;
            end
            s = ruInfo(obj);
            % Calculate start space time stream index per user
            startSTSIdxAll = zeros(1,numUsers);
            for j=1:s.NumRUs
                startSTSIdxAll(obj.RU{j}.UserNumbers(1)) = 1;
                for i = 2:s.NumUsersPerRU(j)
                    user = obj.User{obj.RU{j}.UserNumbers(i-1)};
                    startSTSIdxAll(obj.RU{j}.UserNumbers(i)) = startSTSIdxAll(obj.RU{j}.UserNumbers(i)-1)+user.NumSpaceTimeStreams;
                end
            end
        end

        SpaceTimeStreamIndices = cell(1,numUsers);
        for i = 1:numUsers
            SpaceTimeStreamIndices{i} = startSTSIdxAll(i)-1+(1:numSTSPerUser(i)).';
        end

        s = struct;
        s.NumUsers = numUsers;
        s.StartingSpaceTimeStreamNumber = startSTSIdxAll;
        s.SpaceTimeStreamIndices = SpaceTimeStreamIndices;
    end

    function obj = getTRSConfiguration(obj)
    %getTRSConfiguration Return a valid TRS configuration object
    %   This method takes the current configuration and returns an object
    %   with properties set to those required for an HE TB response to TRS.
    %   The other properties are unchanged.

        allocationInfo = obj.ruInfo;
        obj.TriggerMethod = 'TRS';
        if strcmp(obj.ChannelBandwidth,'CBW20')
            for u=1:allocationInfo.NumUsers
                obj.User{u}.ChannelCoding = 'BCC';
            end
        else
            for u=1:allocationInfo.NumUsers
                if strcmp(obj.User{u}.ChannelCoding,'LDPC')
                    obj.User{u}.LDPCExtraSymbol = 1;
                end
            end
        end

        obj.HighDoppler = false;
        obj.SingleStreamPilots = true;
        obj.STBC = false;
        for u=1:allocationInfo.NumUsers
            obj.User{u}.NumSpaceTimeStreams = 1;
        end
        obj.PreFECPaddingFactor = 4;
        obj.SpatialReuse = [15 15 15 15];
    end
end

methods (Access = private)
    function validateHELTFGI(obj)
    %validateHELTFGI Validate the HELTF type and GuardInterval of heTBSystemConfig object
    %   Validated property-subset includes:
    %     HELTFType, GuardInterval, DCM, STBC, HighDoppler

        % Validate GuardInterval and HELTFType
        % Valid modes:
        %   2 x HELTF and 1.6 GI
        %   4 x HELTF and 3.2 GI
        %   1 x HELTF and 1.6 GI is allowed for Non-OFDMA MU-MIMO TB, IEEE Std 802.11ax-2021 Table 27-31
        coder.internal.errorIf(any(obj.HELTFType==[1 2]) && obj.GuardInterval~=1.6,'wlan:shared:InvalidGILTF',sprintf('%1.1f',obj.GuardInterval),'HELTFType',obj.HELTFType);
        coder.internal.errorIf(obj.HELTFType==4 && obj.GuardInterval~=3.2,'wlan:shared:InvalidGILTF',sprintf('%1.1f',obj.GuardInterval),'HELTFType',obj.HELTFType);

        % Validate HighDoppler
        s = obj.ruInfo;
        coder.internal.errorIf(obj.HighDoppler && any(s.NumSpaceTimeStreamsPerRU>4),'wlan:he:InvalidHighDoppler');
    end

    function validateSpatialMapping(obj)
    %validateSpatialMapping Validate the spatial mapping properties
        %   Validated property-subset includes:
        %     ChannelBandwidth, NumTransmitAntennas, NumSpaceTimeStreams,
        %     SpatialMapping, SpatialMappingMatrix

        % Validate SpatialMappingMatrix, SpatialMapping and the number of transmit antennas
        infoRUs = ruInfo(obj);
        for ru = 1:infoRUs.NumRUs                   
            for u=1:infoRUs.NumUsersPerRU(ru)
                uNum = obj.RU{ru}.UserNumbers(u); % User number
                % NumTx and Nsts: numTx cannot be less than sum(Nsts)
                if obj.User{uNum}.NumTransmitAntennas < obj.User{uNum}.NumSpaceTimeStreams
                    error('NumSpaceTimeStreams (%d) for user %d must be no larger than NumTransmitAntennas (%d).',obj.User{uNum}.NumSpaceTimeStreams,uNum,obj.User{uNum}.NumTransmitAntennas);
                end
                if strcmp(obj.User{uNum}.SpatialMapping,'Custom')
                    % Validate spatial mapping matrix
                    SPMtx = obj.User{uNum}.SpatialMappingMatrix;
                    is3DFormat  = (ndims(SPMtx) == 3) || (iscolumn(SPMtx) && ~isscalar(SPMtx));
                    numSTS = size(SPMtx, 1+is3DFormat);
                    numTx = size(SPMtx, 2+is3DFormat);
                    numST = infoRUs.RUSizes(ru);
                    if (is3DFormat && (size(SPMtx, 1) ~= numST)) || (numSTS ~= obj.User{uNum}.NumSpaceTimeStreams) || (numTx ~= obj.User{uNum}.NumTransmitAntennas)
                        error('SpatialMappingMatrix must be of size [Nsts, Nt] or [Nst, Nsts, Nt], where Nsts is the NumSpaceTimeStreams property (%d), Nt is the NumTransmitAntennas property (%d), and Nst is the number of occupied subcarriers (%d) for user %d.', ...
                           obj.User{uNum}.NumSpaceTimeStreams, obj.User{uNum}.NumTransmitAntennas,numST,uNum);
                    end
                else
                    if strcmp(obj.User{uNum}.SpatialMapping,'Direct') && (obj.User{uNum}.NumSpaceTimeStreams ~= obj.User{uNum}.NumTransmitAntennas)
                        error('NumSpaceTimeStreams (%d) for user %d must be equal to NumTransmitAntennas (%d) when SpatialMapping is set to Direct.',obj.User{uNum}.NumSpaceTimeStreams,uNum,obj.User{uNum}.NumTransmitAntennas);
                    end
                end
            end
        end
    end

    function s = validateMCSLength(obj)
    %   validateMCSLength Validate the length properties of heTBSystemConfig object
    %   configuration object
    %   Validated property-subset includes:
    %     ChannelBandwidth, NumUsers, NumSpaceTimeStreams, STBC, MCS,
    %     ChannelCoding, GuardInterval, APEPLength

        % Validate coding related properties
        validateCoding(obj);

        if strcmp(obj.TriggerMethod,'TRS')
            [psduLength,txTime,numDataSym] = heTRSPLMETxTimePrimative(obj); % Includes packet extension
        else
            [psduLength,txTime,commonCodingParams] = wlan.internal.hePLMETxTimePrimative(obj);
            numDataSym = commonCodingParams.NSYM;
        end
        % Calculate LSIGLength. IEEE p802.11ax/D4.1, Equation 27-11
        SiganlExtension = 0;
        m = 2; % For HE TB m=2. IEEE p802.11ax/D4.1, Section 27.3.10.5
        lsigLength = ceil((txTime-SiganlExtension-20e3)/4e3)*3-3-m;
 
        % Set output structure
        s = struct(...
            'TxTime', txTime/1000, ...
            'PSDULength', psduLength, ...
            'LSIGLength', lsigLength, ...
            'NumDataSymbols', numDataSym);

        % Validate TxTime (max 5.484ms for VHT format)
        coder.internal.errorIf(s.TxTime>5484,'wlan:shared:InvalidPPDUDuration',round(s.TxTime),5484);
    end

    function validateCoding(obj)
    %   validateCoding Coding properties of heTBSystemConfig object
    %   Validated property-subset includes:
    %     ChannelBandwidth, NumUsers, NumSpaceTimeStreams, STBC, MCS,
    %     ChannelCoding, RU Size, AID12

        % Validate ChannelCoding, DCM and STBC, and the number of
        % space-time streams for all users
        infoRUs = ruInfo(obj);
        for u = 1:numel(obj.User)
            if strcmp(obj.User{u}.ChannelCoding,'BCC')
                coder.internal.errorIf(obj.RU{obj.User{u}.RUNumber}.Size>242,'wlan:shared:InvalidBCCRUSize');
                coder.internal.errorIf(obj.User{u}.NumSpaceTimeStreams>4,'wlan:shared:InvalidNSTS');
                coder.internal.errorIf(any(obj.User{u}.MCS==[10 11]),'wlan:he:InvalidMCS');
            end

            % Validate MCS, DCM and STBC
            coder.internal.errorIf(obj.User{u}.DCM && (numel(obj.RU{obj.User{u}.RUNumber}.UserNumbers)>1 || ~any(obj.User{u}.MCS == [0 1 3 4]) || obj.STBC || obj.User{u}.NumSpaceTimeStreams>2),'wlan:he:InvalidDCM');

            % Validate STBC and NumSpaceTimeStreams
            coder.internal.errorIf(obj.STBC && (obj.User{u}.NumSpaceTimeStreams~=2 || any(infoRUs.NumUsersPerRU>1)),'wlan:he:MUNumSTSWithSTBC');

            % Validate user properties. Throw a warning for the properties not relevant to TriggerFrame
            if strcmp(obj.TriggerMethod,'TriggerFrame') && obj.User{u}.LDPCExtraSymbol~=1
                warning('The LDPCExtraSymbol property is not used when TriggerMethod is set to TriggerFrame');
            end
        end

        validateAID12(obj);
    end

    function validateAID12(obj)
    %   validateAID12 Validate at least one user is active
    %
    %   Validated property: AID12

        % Validate AID12 is not 2046 for all users
        userActive = true(1,numel(obj.User)); % Vector indicating if a user object is active
        for u = 1:numel(obj.User)
            if obj.User{u}.AID12==2046
                % If AID12 is 2046 in a MU-MIMO RU, then error
                coder.internal.errorIf(numel(obj.RU{obj.User{u}.RUNumber}.UserNumbers)>1,'wlan:shared:InactiveUserInMU');

                % If AID12 is 2046, then RU carries no data, and user is inactive.
                userActive(u) = false;
            end
        end

        % Make sure at least one of the users is active
        numActiveUsers = sum(userActive==true);
        coder.internal.errorIf(numActiveUsers==0,'wlan:shared:NoActiveUsers');
    end

    function validatePreHECyclicShifts(obj)
    %validatePreHECyclicShifts Validate PreHECyclicShifts values against
    %   NumTransmitAntennas
    %   Validated property-subset includes:
    %     PreHECyclicShifts, NumTransmitAntennas

        rInfo = ruInfo(obj);
        for u=1:rInfo.NumUsers
            numTx = obj.User{u}.NumTransmitAntennas;
            csh = obj.User{u}.PreHECyclicShifts;
            if numTx>8
                coder.internal.errorIf(~(numel(csh)>=numTx-8),'wlan:shared:InvalidCyclicShift','PreHECyclicShifts',numTx-8);
            end
        end
    end

    function validateTRS(obj)
    %validateTRS Validate properties for TriggerMethod, TRS
    %   Validated property-subset includes:
    %     HighDoppler, STBC, SingleStreamPilots, PreFECPaddingFactor,
    %     SpatialReuse, HESIGAReservedBits, ChannelCoding,
    %     NumSpaceTimeStreams, LDPCExtraSymbol

        % IEEE Std 802.11ax-2021, Section 26.5.2.3.4
        % Validate common properties
        coder.internal.errorIf(obj.HighDoppler==1,'wlan:wlanHETBConfig:InvalidTRSHighDoppler');
        coder.internal.errorIf(obj.STBC,'wlan:wlanHETBConfig:InvalidTRSSTBC');
        coder.internal.errorIf(~obj.SingleStreamPilots,'wlan:wlanHETBConfig:InvalidTRSSingleStreamPilots');
        coder.internal.errorIf(obj.PreFECPaddingFactor~=4,'wlan:wlanHETBConfig:InvalidTRSPreFECPaddingFactor');
        coder.internal.errorIf(obj.SpatialReuse(1)~=15,'wlan:wlanHETBConfig:InvalidTRSSpatialReuse1');
        coder.internal.errorIf(obj.SpatialReuse(2)~=15,'wlan:wlanHETBConfig:InvalidTRSSpatialReuse2');
        coder.internal.errorIf(obj.SpatialReuse(3)~=15,'wlan:wlanHETBConfig:InvalidTRSSpatialReuse3');
        coder.internal.errorIf(obj.SpatialReuse(4)~=15,'wlan:wlanHETBConfig:InvalidTRSSpatialReuse4');
        coder.internal.errorIf(any(obj.HESIGAReservedBits~=1),'wlan:wlanHETBConfig:InvalidTRSHESIGAReservedBits');
        % Validate user properties. Throw a warning for the properties not relevant to TRS.
        rInfo = ruInfo(obj);
        for u=1:rInfo.NumUsers
            % For TRS, LDPC is not allowed for RUSize<484
            coder.internal.errorIf(strcmp(obj.User{u}.ChannelCoding,'LDPC') && (rInfo.RUSizes(obj.User{u}.RUNumber)<484),'wlan:wlanHETBConfig:InvalidTRSRUSizeCoding');
            coder.internal.errorIf((strcmp(obj.User{u}.ChannelCoding,'LDPC') && obj.User{u}.LDPCExtraSymbol==0),'wlan:wlanHETBConfig:InvalidTRSLDPCExtraSymbol');
            coder.internal.errorIf(obj.User{u}.NumSpaceTimeStreams>1,'wlan:wlanHETBConfig:InvalidTRSNumSpaceTimeStreams');
            if obj.User{u}.NominalPacketPadding~=0
                warning('The NominalPacketPadding property is not used when TriggerMethod is set to TRS');
            end
        end
    end
end

methods (Access = protected)
    function flag = isInactiveProperty(obj, prop)
        flag = false;
        if strcmp(prop,'LowerCenter26ToneRU')
            % Hide LowerCenter26ToneRU
            flag = ~lowerCenter26ToneRUActive(obj.AllocationIndex);
        elseif strcmp(prop,'UpperCenter26ToneRU')
            % Hide LowerCenter26ToneRU
            flag = ~upperCenter26ToneRUActive(obj.AllocationIndex);
        elseif strcmp(prop,'MidamblePeriodicity')
            flag = obj.HighDoppler == 0;
        elseif strcmp(prop,'PreHECyclicShifts')
            % Hide PreHECyclicShifts when NumTransmitAntennas <=8
            flag = obj.NumTransmitAntennas<=8;
        elseif strcmp(prop,'DefaultPEDuration') || strcmp(prop,'PEDisambiguity') || strcmp(prop,'PreFECPaddingFactor')
            % Hide DefaultPEDuration and NumDataSymbols when TriggerMethod is TriggerFrame
            flag = ~strcmp(obj.TriggerMethod,'TRS');
        end
    end
end
end

function [ru,user,userRUNumber] = heRUAllocation(allocationIndex,varargin)
    s = wlan.internal.heAllocationInfo(allocationIndex,varargin{:});
    numRUs = s.NumRUs;
    numUsers = s.NumUsers;

    Usertmp = cell(1,numUsers);
    RUtmp = cell(1,numRUs);
    u = 1;
    userRUNumber = zeros(1,numUsers);
    for i = 1:numRUs
        ruUserNumber = zeros(1,s.NumUsersPerRU(i));
        for j = 1:s.NumUsersPerRU(i)
            userRUNumber(u) = i;
            ruUserNumber(j) = u;
            u = u+1;
        end

        % Use round to deal with invalid combos which can give a
        % non-integer RUindices.
        RUtmp{i} = heTBRU(s.RUSizes(i),round(s.RUIndices(i)),ruUserNumber);
    end

    for u = 1:numUsers
        Usertmp{u} = heTBUser(userRUNumber(u));
    end

    user = Usertmp;
    ru = RUtmp;
end

function isactive = lowerCenter26ToneRUActive(allocationIndex)
    isactive = true;
    if numel(allocationIndex)<4
        isactive = false;
    else
        % Test the center-26 tone RU is valid for the allocation index
        s = wlan.internal.heAllocationInfo(allocationIndex);
        if numel(allocationIndex)==4
            if any(s.RUSizes>484)
                % If any 996-tone RUs, then center not applicable
                isactive = false;
            end
        else % allocationIndex == 8
            if any(s.RUSizes>996) || (s.RUSizes(1)==996 && s.RUIndices(1)==1)
                % If a 2*996-tone RU, or 996 RU in lower half, then center not applicable
                isactive = false;
            end
        end
    end
end

function isactive = upperCenter26ToneRUActive(allocationIndex)
    isactive = true;
    if numel(allocationIndex)<8
        isactive = false;
    else
        % Test the center-26 tone RU is valid for the allocation index
        s = wlan.internal.heAllocationInfo(allocationIndex);
        if any(s.RUSizes>996)
            % If a 2*996-tone RU, then center not applicable
            isactive = false;
        else
            rui = find(s.RUSizes==996);
            if ~isempty(rui) && any(s.RUIndices(rui)==2)
                % If 996 RU in upper half, then center not applicable
                isactive = false;
            end
        end
    end
end

function validatePreamblePuncturing(allocationIndex)
    % Validate AllocationIndex and Preamble puncturing
    if numel(allocationIndex) >= 4 % Preamble puncturing is only applicable to 80MHz or 160MHz
        switch numel(allocationIndex)
            case 4 % 80MHz
                [~,puncturedIndex] = find(allocationIndex==113);
                coder.internal.errorIf((any(puncturedIndex==1) || numel(puncturedIndex)>1),'wlan:wlanHEMUConfig:IncorrectPuncturing80MHz');
            otherwise % 160MHz
                [~,puncturedIndex] = find(allocationIndex==113);
                if ~isempty(puncturedIndex)
                    if numel(puncturedIndex)==1
                        coder.internal.errorIf(~any(puncturedIndex == [2 3 4]),'wlan:wlanHEMUConfig:IncorrectPuncturing160MHz');
                    elseif numel(puncturedIndex)==2
                        coder.internal.errorIf(~all(puncturedIndex == [3 4]),'wlan:wlanHEMUConfig:IncorrectPuncturing160MHz');
                    else
                        coder.internal.error('wlan:wlanHEMUConfig:IncorrectPuncturing160MHz');
                    end
                end
        end
    end
end

function mustBeValidValue(PreHEPowerScalingFactor)
%mustBeValidValue Validate Pre-HE power scaling factor
    coder.internal.errorIf((PreHEPowerScalingFactor<1/sqrt(2) || PreHEPowerScalingFactor>1),'wlan:wlanHETBConfig:InvalidPreHEPowerScalingFactor');
end

function [commonParams,userParams] = heTRSCodingParameters(cfg)
%heTRSCodingParameters Coding parameters for trigger frame of type TRS
%
%   [COMMONPARAMS,USERPARAMS] = heTRSCodingParameters(CFG) returns a structure
%   COMMONPARAMS, containing the coding parameters common to all users, and
%   an array of structures, USERPARAMS, containing the coding parameters
%   for each user.
%
%   CFG is a format configuration object of type <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a>.

% Form a vector of parameters, were each element is the parameter for a user
numUsers = numel(cfg.User);

% Determine which user objects are active - the AID12 is not 2046
userActive = true(1,numUsers); % Vector indicating if a user object is active
for i = 1:numUsers
    if cfg.User{i}.AID12==2046
        % If AID12 is 2046, then RU carries no data, and user is not
        % active. Therefore do not take user into account when
        % calculating coding parameters.
        userActive(i) = false;
    end
end

% Get a vector of the user object numbers which are active (AID12 is not 2046)
numActiveUsers = sum(userActive==true);
activeUserNumbers = zeros(1,numActiveUsers);
userIdx = 1;
for i = 1:numel(userActive)
    if userActive(i)
        % If user active then store active user number
        activeUserNumbers(userIdx) = i;
        userIdx = userIdx+1;
    end
end

ruSize = zeros(numUsers,1);
mcs = zeros(numUsers,1);
numSTS = zeros(numUsers,1);
apepLength = zeros(numUsers,1);
channelCoding = repmat({'LDPC'},numUsers,1);
dcm = false(numUsers,1);

for userIdx = 1:numUsers
    ruSize(userIdx) = cfg.RU{cfg.User{userIdx}.RUNumber}.Size;
    mcs(userIdx) = cfg.User{userIdx}.MCS;
    numSTS(userIdx) = cfg.User{userIdx}.NumSpaceTimeStreams;
    AID12 = cfg.User{userIdx}.AID12;
    if AID12==2046
        % If AID12 is 2046, then RU carries no data, therefore do not
        % include user in coding calculations by setting the APEPLength
        % to 0
        apepLength(userIdx) = 0;
    else
        apepLength(userIdx) = cfg.User{userIdx}.APEPLength;
    end
    channelCoding{userIdx} = cfg.User{userIdx}.ChannelCoding;
    dcm(userIdx) = cfg.User{userIdx}.DCM;
end

stbc = cfg.STBC;
if stbc % P802.11ax/D4.1, Section 27.4.3, Equation 27-136
    nss = numSTS/2;
    mSTBC = 2;
else
    nss = numSTS;
    mSTBC = 1;
end

Nservice = 16; % IEEE Std 802.11ax-2021, Table 27-12

%%
% First calculation: the initial common number of symbols and pre-FEC
% padding factor. Calculate values for all users and take the maximum. Also
% calculate NCBPSSHORT, NDPBSSHORT, and the rate dependent parameters per
% user as part of this.

NSYMinit = zeros(numUsers,1);   % Number of symbols (initial)
ainit = zeros(numUsers,1);      % Pre-FEC padding factor (initial)
NCBPSSHORT = zeros(numUsers,1); % Number of coded bits per symbol (short)
NDBPSSHORT = zeros(numUsers,1); % Number of data bits per symbol (short)
Ntail = zeros(numUsers,1);      % Number of tail bits
R = zeros(numUsers,1);          % Rate
NSS = zeros(numUsers,1);        % Number of spatial streams
NBPSCS = zeros(numUsers,1);     % Number of bits per subcarrier
NDBPS = zeros(numUsers,1);      % Number of data bits per symbol
NCBPS = zeros(numUsers,1);      % Number of coded bits per symbols
NSD = zeros(numUsers,1);        % Number of data carrying subcarriers

for u = 1:numUsers
    switch channelCoding{u}
        case 'BCC'
            Ntail(u) = 6;
        case 'LDPC'
            Ntail(u) = 0;
    end

    % Get rate dependent parameters for all users
    params = wlan.internal.heRateDependentParameters(ruSize(u),mcs(u),nss(u),dcm(u));
    R(u) = params.Rate;
    NSS(u) = params.NSS;
    NBPSCS(u) = params.NBPSCS;
    NDBPS(u) = params.NDBPS;
    NCBPS(u) = params.NCBPS;
    NSD(u) = params.NSD;

    % NSD,SHORT values. IEEE Std 802.11ax-2021, Table 27-33
    NSDSHORT = wlan.internal.heNSDShort(ruSize(u),dcm(u));

    % Initial number of symbol segments in the last OFDM symbol(s). IEEE
    % Std 802.11ax-2021, Equation 27-61
    NCBPSSHORT(u) = NSDSHORT*NSS(u)*NBPSCS(u);
    NDBPSSHORT(u) = NCBPSSHORT(u)*R(u);
    if strcmp(channelCoding{u},'BCC')
        % The ainit=a for TriggerMethod, TRS and ChannelCoding, BCC.
        % The PreFECPaddingFactor(a) is fixed to 4 for TRS. IEEE
        % Std 802.11ax-2021, Section 27.3.12.5.5
        ainit(u) = 4;
    else
        % The ainit=a-1 for TriggerMethod, TRS and ChannelCoding, LDPC.
        % The PreFECPaddingFactor(a) is fixed to 4 for TRS. IEEE
        % Std 802.11ax-2021, Section 27.3.12.5.5
        ainit(u) = 3; % ainit = a-1, where a=4
    end
    % BCC
    NSYMinit(u) = mSTBC*ceil((8*apepLength(u)+Ntail(u)+Nservice)/(mSTBC*NDBPS(u))); % IEEE Std 802.11ax-2021, Equation 27-66
end

% Derive user index with longest encoded packet duration, IEEE Std 802.11ax-2021, Equation 27-75
% Only user active users
[~,umax] = max(NSYMinit(userActive)-mSTBC+mSTBC.*ainit(userActive)/4);

% Use values from max for all users, % IEEE Std 802.11ax-2021, Equation 27-76
NSYMinitCommon = NSYMinit(activeUserNumbers(umax));
ainitCommon = ainit(activeUserNumbers(umax));

%%
% Now we know the common pre-FEC padding factor and number of symbols,
% update each users number of coded bits in the last symbol

NDBPSLASTinit = zeros(numUsers,1);
NCBPSLASTinit = zeros(numUsers,1);
for u = 1:numUsers
    % Update each user's initial number of coded bits in its last
    % symbol, IEEE Std 802.11ax-2021, Equation 27-77
    if ainitCommon<4
        NDBPSLASTinit(u) = ainitCommon*NDBPSSHORT(u);
        NCBPSLASTinit(u) = ainitCommon*NCBPSSHORT(u);
    else
        NDBPSLASTinit(u) = NDBPS(u);
        NCBPSLASTinit(u) = NCBPS(u);
    end
end

%%
% For each user which uses LDPC calculate the number of pre FEC padding
% bits and if an LDPC extra symbol is required.

NPADPreFEC = zeros(numUsers,1);
ldpcExtraSymbol = false(numUsers,1);
for u = 1:numUsers
    if strcmp(channelCoding{u},'LDPC')
        % IEEE Std 802.11ax-2021, Equation 27-78
        NPADPreFEC(u) = (NSYMinitCommon-mSTBC)*NDBPS(u)+mSTBC*NDBPSLASTinit(u)-8*apepLength(u)-Nservice; 
        % The LDPCExtraSymbol is always true for TriggerMethod, TRS. IEEE
        % P802.11ax/D4.1, Section 27.3.12.5.5. Over writing the
        % LDPCExtraSymbol to true.
        ldpcExtraSymbol(u) = true;
    end
end

%% 
% Update NSYM, the pre-FEC padding factor, NDBPSLast, and NCBPSLast for all
% users now we know if an LDPC extra symbol is required. We can also
% calculate the Pre FEC padding factor for BCC users.

commonLDPCExtraSymbol = any(ldpcExtraSymbol(userActive));
if commonLDPCExtraSymbol
    % IEEE Std 802.11ax-2021, Equation 27-83
    if ainitCommon==4
        NSYM = NSYMinitCommon+mSTBC;
        a = 1;
    else
        NSYM = NSYMinitCommon;
        a = ainitCommon+1;
    end
else
    % IEEE Std 802.11ax-2021, Equation 27-84
    NSYM = NSYMinitCommon;
    a = ainitCommon;
end

NDBPSLAST = zeros(numUsers,1);
NCBPSLAST = zeros(numUsers,1);
NPADPreFECMAC = zeros(numUsers,1);
NPADPreFECPHY = zeros(numUsers,1);
NPADPostFEC = zeros(numUsers,1);
for u = 1:numUsers
    % Part of IEEE Std 802.11ax-2021, Equation 27-85
    if a<4
        NCBPSLAST(u) = a*NCBPSSHORT(u);
    else
        NCBPSLAST(u) = NCBPS(u);
    end

    switch channelCoding{u}
        case 'LDPC'
            % Part of IEEE Std 802.11ax-2021, Equation 27-85
            NDBPSLAST(u) = NDBPSLASTinit(u);
        case 'BCC'
            % Part of IEEE Std 802.11ax-2021, Equation 27-85
            if a<4
                NDBPSLAST(u) = a*NDBPSSHORT(u);
            else
                NDBPSLAST(u) = NDBPS(u);
            end

            % IEEE Std 802.11ax-2021, Equation 27-86
            NPADPreFEC(u) = (NSYM-mSTBC)*NDBPS(u)+mSTBC*NDBPSLAST(u)-8*apepLength(u)-Ntail(u)-Nservice;
    end

    NPADPostFEC(u) = NCBPS(u)-NCBPSLAST(u); % IEEE Std 802.11ax-2021, Equation 27-87
    
    NPADPreFECMAC(u) = floor(NPADPreFEC(u)/8)*8; % IEEE Std 802.11ax-2021, Equation 27-88
    NPADPreFECPHY(u) = mod(NPADPreFEC(u),8); % IEEE Std 802.11ax-2021, Equation 27-89
end

if all(apepLength==0)
    % For NDP set all parameters to 0 so no data symbols transmitted
    NSYM = 0;
    NSYMinitCommon = 0;
    mSTBC = 0;
    NCBPSSHORT = zeros(numUsers,1);
    NDBPSSHORT = zeros(numUsers,1);
    NCBPSLAST = zeros(numUsers,1);
    NCBPSLASTinit = zeros(numUsers,1);
    NDBPSLAST = zeros(numUsers,1);
    NDBPSLASTinit = zeros(numUsers,1);
    NPADPreFECMAC = zeros(numUsers,1);
    NPADPreFECPHY = zeros(numUsers,1);
    NPADPostFEC = zeros(numUsers,1);
    a = 4;
    ainitCommon = 4;
    commonLDPCExtraSymbol = false;
end

% Parameters common to all users
commonParams = struct;
commonParams.NSYM = NSYM;
commonParams.NSYMInit = NSYMinitCommon;
commonParams.mSTBC = mSTBC;
commonParams.PreFECPaddingFactor = a;
commonParams.PreFECPaddingFactorInit = ainitCommon;
commonParams.LDPCExtraSymbol = commonLDPCExtraSymbol;

% Initialize structure
p = struct;
p.NSYM = 0;
p.NSYMInit = 0;
p.mSTBC = 0;
p.Rate = 0;
p.NBPSCS = 0;
p.NSD = 0;
p.NCBPS = 0;
p.NDBPS = 0;
p.NSS = 0;
p.DCM = false;
p.ChannelCoding = 'LDPC';
p.NCBPSSHORT = 0;
p.NDBPSSHORT = 0;
p.NCBPSLAST = 0;
p.NCBPSLASTInit = 0;
p.NDBPSLAST = 0;
p.NDBPSLASTInit = 0;
p.NPADPreFECMAC = 0;
p.NPADPreFECPHY = 0;
p.NPADPostFEC = 0;
p.PreFECPaddingFactor = 0;
p.PreFECPaddingFactorInit = 0;
p.LDPCExtraSymbol = false;       

% Replicate for all users and populate
if coder.target('MATLAB')
    if numUsers==1
        userParams = struct;
    else
        userParams = repmat(p,numUsers,1);
    end
else
    userParams = repmat(p,numUsers,1);
    coder.varsize('userParams(:).ChannelCoding');
end

for u = 1:numUsers
    userParams(u).NSYM = NSYM;
    userParams(u).NSYMInit = NSYMinitCommon;
    userParams(u).mSTBC = mSTBC;
    userParams(u).Rate = R(u);
    userParams(u).NBPSCS = NBPSCS(u);
    userParams(u).NSD = NSD(u);
    userParams(u).NCBPS = NCBPS(u);
    userParams(u).NDBPS = NDBPS(u);
    userParams(u).NSS = NSS(u);
    userParams(u).DCM = dcm(u);
    userParams(u).ChannelCoding = channelCoding{u};
    userParams(u).NCBPSSHORT = NCBPSSHORT(u);
    userParams(u).NDBPSSHORT = NDBPSSHORT(u);
    userParams(u).NCBPSLAST = NCBPSLAST(u);
    userParams(u).NCBPSLASTInit = NCBPSLASTinit(u);
    userParams(u).NDBPSLAST = NDBPSLAST(u);
    userParams(u).NDBPSLASTInit = NDBPSLASTinit(u);
    userParams(u).NPADPreFECMAC = NPADPreFECMAC(u);
    userParams(u).NPADPreFECPHY = NPADPreFECPHY(u);
    userParams(u).NPADPostFEC = NPADPostFEC(u);
    userParams(u).PreFECPaddingFactor = a;
    userParams(u).PreFECPaddingFactorInit = ainitCommon;
    userParams(u).LDPCExtraSymbol = commonLDPCExtraSymbol;
end

end

function [PSDU_LENGTH,TXTIME,NSYM] = heTRSPLMETxTimePrimative(cfg)
%heTRSPLMETxTimePrimative PSDULength, TXTIME and NSYM from PLME TXTIME
%primitive for the trigger method of type TRS
%
%   [PSDU_LENGTH,TXTIME,NSYM] = heTRSPLMETxTimePrimative(CFG) returns the
%   PSDU length per user, TX time and NSYM as per as per IEEE Std
%   802.11ax-2021 Section 27.4.3.
%
%   CFG is a format configuration object of type <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a>.

allocationInfo = ruInfo(cfg);
numUsers = allocationInfo.NumUsers;
% Get the APEPLength and channel coding per user
apepLength = zeros(numUsers,1);
channelCoding = cell(numUsers,1);

% Get AID12 for all users
for userIdx = 1:numUsers
    if cfg.User{userIdx}.AID12==2046
        % If AID12 is 2046, then RU carries no data, therefore do not
        % include user in coding calculations by setting the APEPLength
        % to 0
        apepLength(userIdx) = 0;
    else
        apepLength(userIdx) = cfg.User{userIdx}.APEPLength;
    end
    channelCoding{userIdx} = cfg.User{userIdx}.ChannelCoding;
end

NHELTF = wlan.internal.numVHTLTFSymbols(max(allocationInfo.NumSpaceTimeStreamsPerRU));

% Calculate TXTIME
SignalExtension = 0; % in ns, 0 for 5 GHz or 6000 for 2.4 GHz

[commonCodingParams,userCodingParams] = heTRSCodingParameters(cfg);

NSYM = commonCodingParams.NSYM;
Nma = 0; % No midamble periodicity for TriggerMethod of type TRS

% Update trc.TPE for HE TB format
sf = 1e3; % Scaling factor to convert time in us into ns
trc = wlan.internal.heTimingRelatedConstants(cfg.GuardInterval,cfg.HELTFType,0);
trc.TPE = cfg.DefaultPEDuration*sf; % Update PE duration for TRS

% Part of IEEE Std 802.11ax-2021, Equation 27-121
THE_PREAMBLE = trc.TRLSIG+trc.THESIGA+trc.THESTFT+NHELTF*trc.THELTFSYM;

% IEEE IEEE Std 802.11ax-2021, Section 27.4.3, Equation 27-135
TXTIME = 20*sf+THE_PREAMBLE+NSYM*trc.TSYM+Nma*NHELTF*trc.THELTFSYM+trc.TPE+SignalExtension; % TXTIME in ns

% Calculate PSDU_LENGTH per user
Nservice = 16; % Number of service bits
PSDU_LENGTH = zeros(1,numUsers);

for u = 1:numUsers
    % IEEE Std 802.11ax-2021, Table 27-12
    if strcmp(channelCoding{u},'BCC')
        Ntail = 6;
    else % 'LDPC'
        Ntail = 0;
    end

    % IEEE Std 802.11ax-2021, Section 27.4.3
    if strcmp(channelCoding{u},'BCC') % IEEE Std 802.11ax-2021, Section 27.4.3, Equation 27-136, Equation 27-137
        PSDU_LENGTH(u) = floor(((commonCodingParams.NSYM-commonCodingParams.mSTBC)*userCodingParams(u).NDBPS+commonCodingParams.mSTBC*userCodingParams(u).NDBPSLAST-Nservice-Ntail)/8);
    else % IEEE Std 802.11ax-2021, Section 27.4.3, Equation 27-136, Equation 27-138
        PSDU_LENGTH(u) = floor(((commonCodingParams.NSYMInit-commonCodingParams.mSTBC)*userCodingParams(u).NDBPS+commonCodingParams.mSTBC*userCodingParams(u).NDBPSLASTInit-Nservice-Ntail)/8);
    end
end

end