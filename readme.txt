This folder contains the modified implementation of the multi TXOP simulator for latency analysis. The goal of this simulator is to enable the analysis of performance of different schedulers (AA and RR) in a setting with multiple TXOPs. It models a simplified communication system (in the uplink direction) comprised of one access point (AP) and a few stations. 
-------------
| File tree |
-------------
├── classes/
│   ├── AccessPoint.asv
│   ├── AccessPoint.m
│   ├── Counts.m -> Helper class for counting frame types
│   ├── Frame.m
│   ├── Queue.m
│   ├── Station.m
├── functions/
│   ├── coinFlip.m
│   ├── generateFrame.m
│   ├── getStationInformation.m
│   ├── getTypeCountsFromTable.m
├── queueEvolutionExample.mlx --> queue evolution example notebook
├── results/ [excluded]
├── schedulers/
│   ├── assignmentAlgorithmLatencyMultiTXOP.m --> AA (modified for multi TXOP and latency analysis)
│   ├── roundRobinLatencyMultiTXOP.m --> RR (modified for multi TXOP and latency analysis)
├── simulation.mlx --> simulation notebook
├── tables/
│   ├── SNR_MCS_PDR_1458_LDPC.csv
├── utils/ --> utils (MATLAB)
│   ├── calculateSINR.m
│   ├── heRUAllocationTable.m
│   ├── heSuccessiveEqualize.m
│   ├── heTBRU.m
│   ├── heTBSystemConfig.m
│   ├── heTBUser.m
│   ├── tgaxLinkPerformanceModel.m
│   ├── tgaxMMSEFilter.m
├── utils_custom/ --> utils (custom)
│   ├── assignmentMtxToSTASchedule.m
│   ├── channelToSINR.m
│   ├── configs/
│   │   ├── customConfig1.m
│   │   ├── customConfig2.m
│   │   ├── defaultConfig.m
│   ├── getMaxMCS.m
│   ├── getSNRsPerRU.m
│   ├── getTxTime.m
│   ├── optimProbSinglePPDU.m
│   ├── PPDUTxTimeAssignmentAlgorithm.m
│   ├── PPDUTxTimeRoundRobin.m
