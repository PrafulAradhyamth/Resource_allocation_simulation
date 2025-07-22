# Multi-TXOP Simulator for Latency Analysis

This folder contains a modified implementation of a multi-TXOP simulator designed for analyzing latency. Its primary goal is to evaluate the performance of different schedulers, specifically **Assignment Algorithm (AA)** and **Round Robin (RR)**, in a multi-TXOP environment. The simulator models a simplified uplink communication system consisting of one **Access Point (AP)** and several **Stations (STAs)**.

---

## File Tree

* **`classes/`**
    * `AccessPoint.asv`
    * `AccessPoint.m`
    * `Counts.m` (Helper class for counting frame types)
    * `Frame.m`
    * `Queue.m`
    * `Station.m`
* **`functions/`**
    * `coinFlip.m`
    * `generateFrame.m`
    * `getStationInformation.m`
    * `getTypeCountsFromTable.m`
* **`queueEvolutionExample.mlx`** (Queue evolution example notebook)
* **`results/`** (Excluded from this listing)
* **`schedulers/`**
    * `assignmentAlgorithmLatencyMultiTXOP.m` (AA scheduler modified for multi-TXOP and latency analysis)
    * `roundRobinLatencyMultiTXOP.m` (RR scheduler modified for multi-TXOP and latency analysis)
* **`simulation.mlx`** (Simulation notebook)
* **`tables/`**
    * `SNR_MCS_PDR_1458_LDPC.csv`
* **`utils/`** (MATLAB utilities)
    * `calculateSINR.m`
    * `heRUAllocationTable.m`
    * `heSuccessiveEqualize.m`
    * `heTBRU.m`
    * `heTBSystemConfig.m`
    * `heTBUser.m`
    * `tgaxLinkPerformanceModel.m`
    * `tgaxMMSEFilter.m`
* **`utils_custom/`** (Custom utilities)
    * `assignmentMtxToSTASchedule.m`
    * `channelToSINR.m`
    * **`configs/`**
        * `customConfig1.m`
        * `customConfig2.m`
        * `defaultConfig.m`
    * `getMaxMCS.m`
    * `getSNRsPerRU.m`
    * `getTxTime.m`
    * `optimProbSinglePPDU.m`
    * `PPDUTxTimeAssignmentAlgorithm.m`
    * `PPDUTxTimeRoundRobin.m`
