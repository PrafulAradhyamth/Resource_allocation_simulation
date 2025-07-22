classdef heTBRU < comm.internal.ConfigBase
%heTBRU Creates a trigger-based resource unit (RU) configuration object
%   CFGRU = heTBRU(SIZE,INDEX,USERNUMBERS) creates a resource unit (RU)
%   configuration object. This object contains properties to configure an
%   HE RU, including the users associated with it. SIZE is an integer
%   specifying the RU size and must be one of 26, 52, 106, 242, 484, 996,
%   or 2*996. INDEX is an integer between 0 and 74 specifying the RU index.
%   USERNUMBERS is a vector of integers specifying the 1-based index of the
%   users transmitted on this RU. This number is used to index the
%   appropriate User objects within <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a>.
%
%   CFGRU = heTBRU.m(...,Name,Value) creates an object that holds the
%   properties for each RU and the respective users, CFGRU, with the
%   specified property Name set to the specified value. You can specify
%   additional name-value pair arguments in any order as (Name1,Value1,
%   ...,NameN,ValueN).
%
%   heTBRU objects are used to parameterize multiple uplink users for
%   HE TB PPDU transmission.
%
%   heTBRU properties:
%
%   Size                 - Resource unit size
%   Index                - Resource unit index
%   UserNumbers          - Indices of users transmitted on this RU
%
%   See also wlanHETBConfig

%   Copyright 2017-2022 The MathWorks, Inc.

properties (SetAccess=private)
    %Size Resource unit size
    %   Specify the size of the RU. The draft standard defines the RU size
    %   must be one of 26, 52, 106, 242, 484, 996 and 1992 (2x996). The
    %   default value for this property is 242.
    Size (1,1) {mustBeNumeric,mustBeMember(Size,[0 26 52 106 242 484 996 1992])} = 242;
    %Index Resource unit index
    %   Specify the RU index as a non-zero integer. The RU index specifies
    %   the location of the RU within the channel. For example, in an 80
    %   MHz transmission there are four possible 242 tone RUs, one in each
    %   20 MHz subchannel. RU# 242-1 (size 242, index 1) is the RU
    %   occupying the lowest absolute frequency within the 80 MHz, and RU#
    %   242-4 (size 242, index 4) is the RU occupying the highest absolute
    %   frequency. The default value for this property is 1.
    Index (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThanOrEqual(Index,0),mustBeLessThanOrEqual(Index,74)} = 0;
    %UserNumbers Indices of users transmitted on this RU
    %   UserNumbers is the 1-based indices of the users which are
    %   transmitted on this RU. This number is used to index the
    %   appropriate User objects within <a href="matlab:help('heTBSystemConfig')">heTBSystemConfig</a>.
    UserNumbers = 1;
end

methods
    function obj = heTBRU (size,index,userNumbers)
        % Constructor
        obj.Size = size;
        obj.Index = index;
        obj.UserNumbers = userNumbers;
    end
end
end
