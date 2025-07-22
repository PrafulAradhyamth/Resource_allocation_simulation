classdef heTBUser < comm.internal.ConfigBase
%heTBUser User properties within each RU
%   CFGUSER = heTBUser(RUNUMBER) creates a trigger-based user configuration
%   object. This object contains the user properties of a user within an HE
%   RU. RUNUMBER is an integer specifying the 1-based index of the resource
%   unit (RU) the user is transmitted on. This number is used to index the
%   appropriate RU object within a <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a>.
%
%   CFGUSER = heTBUser(...,Name,Value) creates an object that holds the
%   properties for the users within an RU, CFGUSER, with the specified
%   property Name set to the specified value. You can specify additional
%   name-value pair arguments in any order as (Name1,Value1,
%   ...,NameN,ValueN).
%
%   heTBUser objects are used to parameterize users within an HE TB
%   transmission and therefore are part of the <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a> object.
%
%   heTBUser properties:
%
%   NumTransmitAntennas  - Number of transmit antennas
%   PreHECyclicShifts    - Cyclic shift values in nanoseconds for antennas greater than 8
%   NumSpaceTimeStreams  - Number of space-time streams
%   SpatialMapping       - Spatial mapping scheme
%   SpatialMappingMatrix - Spatial mapping matrix(ces)
%   MCS                  - Modulation and coding scheme
%   DCM                  - Enable dual carrier modulation for HE data
%   ChannelCoding        - Forward error correction coding type
%   LDPCExtraSymbol      - LDPC extra OFDM symbol indication
%   APEPLength           - APEP length per user
%   AID12                - Station identification
%   RUNumber             - Index of RU used to transmit user
%   NominalPacketPadding - Nominal Packet Padding in micro seconds
%
%   See also wlanHETBConfig

%   Copyright 2017-2022 The MathWorks, Inc.

properties
    %NumTransmitAntennas Number of transmit antennas
    %   Specify the number of transmit antennas as a numeric, positive
    %   integer scalar. The default is 1.
    NumTransmitAntennas (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(NumTransmitAntennas,1)} = 1;
    %PreHECyclicShifts Cyclic shift values in nanoseconds for antennas greater than 8
    %   Specify the cyclic shift values in nanoseconds as a row vector of
    %   length L = NumTransmitAntennas-8. The cyclic shift values should be
    %   between -200 and 0 inclusive. The first 8 antennas use the cyclic
    %   shift values defined in Table 21-10 of IEEE Std 802.11-2016. The
    %   remaining antennas use the cyclic shift value you define in this
    %   property. If you specify the length of this row vector as a value
    %   greater than L, the object only uses the first L PreHECyclicShifts
    %   values. For example, if you specify the NumTransmitAntennas
    %   property as 18 and this property as a row vector of length N>L, the
    %   object only uses the first L = 18-8 = 10 entries. This property
    %   applies only when you set the NumTransmitAntennas property to a
    %   value greater than 8. The default value of this property is -75
    %   nanoseconds.
    PreHECyclicShifts {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(PreHECyclicShifts,-200),mustBeLessThanOrEqual(PreHECyclicShifts,0)} = -75;
    %NumSpaceTimeStreams  Number of space-time streams per user
    %   Specify the number of space-time streams as integer scalar between
    %   1 and 8, inclusive. The maximum number of space-time streams for
    %   each user within a MU-MIMO RU is between 1 and 4 (inclusive) and
    %   depends on the user number, total number of users and total number
    %   of space-time streams as per Table 28-28 of IEEE P802.11ax/D4.1.
    %   The default value of this property is 1.
    NumSpaceTimeStreams (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(NumSpaceTimeStreams,1),mustBeLessThanOrEqual(NumSpaceTimeStreams,8)} = 1;
    %SpatialMapping Spatial mapping scheme
    %   Specify the spatial mapping scheme as one of 'Direct' | 'Hadamard'|
    %   'Fourier' | 'Custom'. The default value of this property is
    %   'Direct', which applies NumSpaceTimeStreams is equal to
    %   NumTransmitAntennas.
    SpatialMapping = 'Direct';
    %SpatialMappingMatrix Spatial mapping matrix(ces)
    %   Specify the spatial mapping matrix(ces) as a real or complex, 2D
    %   matrix or 3D array. This property applies when you set the
    %   SpatialMapping property to 'Custom'. It can be of size Nsts-by-Nt,
    %   where Nsts is the number of NumSpaceTimeStreams property and Nt is
    %   the NumTransmitAntennas property. In this case, the spatial mapping
    %   matrix applies to all the subcarriers. Alternatively, it can be of
    %   size Nst-by-Nsts-Nt, where Nst is the number of occupied
    %   subcarriers determined by the RU size. Specifically, Nst is 26, 52,
    %   106, 242, 484, 996 and 2x996. In this case, each occupied
    %   subcarrier can have its own spatial mapping matrix. In either 2D or
    %   3D case, the spatial mapping matrix for each subcarrier is
    %   normalized. The default value of this property is 1.
    SpatialMappingMatrix {wlan.internal.heValidateSpatialMappingMatrix} = complex(1);
    %MCS Modulation and coding scheme per user
    %   Specify the modulation and coding scheme as an integer scalar
    %   between 0 and 11, inclusive. The default value of this property is
    %   0.
    MCS (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(MCS,0),mustBeLessThanOrEqual(MCS,11)} = 0;
    %DCM Enable dual carrier modulation for HE data
    %   Set this property to true to indicate that dual carrier modulation
    %   (DCM) is used for the HE-Data field. DCM can only be used with up
    %   to two space-time streams, and in a single-user RU. The default
    %   value of this property is false.
    DCM (1,1) logical = false;
    %ChannelCoding Forward error correction coding type
    %   Specify the channel coding as one of 'BCC' or 'LDPC' to indicate
    %   binary convolution coding (BCC) or low-density-parity-check (LDPC)
    %   coding. The default is 'LDPC'.
    ChannelCoding = 'LDPC';
    %LDPCExtraSymbol LDPC extra OFDM symbol indication
    %   To indicate the presence of an extra OFDM symbol for LDPC encoding,
    %   set this property to true. This property is only visible when
    %   ChannelCoding is LDPC. The default value of this property is true.
    LDPCExtraSymbol (1,1) logical = true;
    %APEPLength APEP length per user
    %   Specify the APEP length in bytes as an integer scalar between 1 and
    %   6500531, inclusive. The default value of this property is 100.
    APEPLength (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(APEPLength,1),mustBeLessThanOrEqual(APEPLength,6500531)} = 100;
    % AID12 Station identification
    %   The AID12 refer to the association identifier (AID12) field as
    %   defined in IEEE P802.11ax/D4.1, Section 9.3.1.22. The 12 LSBs of
    %   the AID field are used to indicate the User Info field of the STA
    %   in the soliciting trigger frame. Set AID12 as an integer scalar
    %   between 0 and 4095, inclusive. The default is 0.
    AID12 (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(AID12,0),mustBeLessThanOrEqual(AID12,4095)} = 0;
    %NominalPacketPadding Nominal packet padding in micro seconds
    %   Specify nominal packet padding as 0, 8 or 16. The nominal packet
    %   padding and the pre-FEC padding factor are used to calculate the
    %   duration of packet extension field as defined in Table 27.44 of
    %   IEEE P802.11ax/D4.1. The default is 0.
    NominalPacketPadding (1,1) {mustBeNumeric,mustBeMember(NominalPacketPadding,[0 8 16])} = 0;
end

properties (SetAccess=private)
    % RUNumber Index of RU used to transmit user
    %   RUNumber is the 1-based index of the RU which the user is
    %   transmitted on. This number is used to index the appropriate RU
    %   objects within <a href="matlab:help('heTBRU')">heTBRU</a>.
    RUNumber = 1;
end

properties(Constant, Hidden)
    ChannelCoding_Values = {'BCC','LDPC'};
    SpatialMapping_Values = {'Direct','Hadamard','Fourier','Custom'};
end

methods
    function obj = heTBUser(ruNumber,varargin)
    % Constructor
       obj = setProperties(obj,varargin{:}); % Supperclass method for NV pair parsing
       obj.RUNumber = ruNumber;
    end

    function obj = set.SpatialMapping(obj,val)
        val = validateEnumProperties(obj,'SpatialMapping',val);
        obj.SpatialMapping = val;
    end

    function obj = set.ChannelCoding(obj,val)
        val = validateEnumProperties(obj,'ChannelCoding',val);
        obj.ChannelCoding = val;
    end
end

methods (Access = protected)
    function flag = isInactiveProperty(obj, prop)
        flag = false;
        if strcmp(prop,'PreHECyclicShifts')
            % Hide PreHECyclicShifts when NumTransmitAntennas <=8
            flag = obj.NumTransmitAntennas<=8;
        elseif strcmp(prop,'LDPCExtraSymbol')
            flag = strcmp(obj.ChannelCoding,'BCC');
        elseif strcmp(prop,'SpatialMappingMatrix')
            % Hide SpatialMappingMatrix when SpatialMapping is not Custom
            flag = ~strcmp(obj.SpatialMapping,'Custom');
        end
     end
end
end