```
# Multi-TXOP Simulator for Latency Analysis

This directory contains a customized implementation of the multi-TXOP simulator designed for latency evaluation. The simulator supports performance analysis of various scheduling strategies, specifically the Assignment Algorithm (AA) and Round Robin (RR), within a multi-TXOP context. It simulates a simplified uplink communication scenario involving a single access point (AP) and several stations.

---

## File Structure

```

├── classes/
│   ├── AccessPoint.asv
│   ├── AccessPoint.m
│   ├── Counts.m                  # Helper class for tracking frame types
│   ├── Frame.m
│   ├── Queue.m
│   ├── Station.m
│
├── functions/
│   ├── coinFlip.m
│   ├── generateFrame.m
│   ├── getStationInformation.m
│   ├── getTypeCountsFromTable.m
│
├── queueEvolutionExample.mlx     # Notebook demonstrating queue evolution
├── results/                      # Output directory (excluded)
│
├── schedulers/
│   ├── assignmentAlgorithmLatencyMultiTXOP.m    # AA scheduler (adapted for multi-TXOP and latency)
│   ├── roundRobinLatencyMultiTXOP.m             # RR scheduler (adapted for multi-TXOP and latency)
│
├── simulation.mlx                # Main simulation notebook
│
├── tables/
│   ├── SNR\_MCS\_PDR\_1458\_LDPC.csv
│
├── utils/                        # General MATLAB utility functions
│   ├── calculateSINR.m
│   ├── heRUAllocationTable.m
│   ├── heSuccessiveEqualize.m
│   ├── heTBRU.m
│   ├── heTBSystemConfig.m
│   ├── heTBUser.m
│   ├── tgaxLinkPerformanceModel.m
│   ├── tgaxMMSEFilter.m
│
├── utils\_custom/                 # Custom utility functions
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

```

