# Multi-TXOP Simulator for Latency Analysis

This repository provides a MATLAB-based simulator tailored for evaluating latency in multi-TXOP (Transmit Opportunity) scenarios. The framework supports the analysis of two key scheduling strategies:

- **Assignment Algorithm (AA)**
- **Round Robin (RR)**

The simulation models an uplink communication scenario involving a single Access Point (AP) and multiple Stations (STAs), focusing on how scheduling affects latency and queue dynamics.

---

## File Structure Overview

```plaintext
├── classes/                      # Core object-oriented components
│   ├── AccessPoint.m             # AP behavior and logic
│   ├── AccessPoint.asv           # Auto-saved version of AccessPoint.m
│   ├── Counts.m                  # Tracks the types of frames processed
│   ├── Frame.m                   # Frame representation
│   ├── Queue.m                   # Queue behavior and status
│   ├── Station.m                 # STA behavior and queue handling
│
├── functions/                    # Basic helper functions
│   ├── coinFlip.m                # Simulates probabilistic outcomes
│   ├── generateFrame.m           # Generates data/control frames
│   ├── getStationInformation.m   # Collects station states/statistics
│   ├── getTypeCountsFromTable.m  # Analyzes frame type distributions
│
├── queueEvolutionExample.mlx     # Demonstrates queue dynamics over time
│
├── results/                      # Stores simulation results (excluded from version control)
│
├── schedulers/                   # Scheduler logic
│   ├── assignmentAlgorithmLatencyMultiTXOP.m   # AA Scheduler for latency in multi-TXOP
│   ├── roundRobinLatencyMultiTXOP.m            # RR Scheduler for latency in multi-TXOP
│
├── simulation.mlx                # Main script to run simulations and visualize results
│
├── tables/
│   ├── SNR_MCS_PDR_1458_LDPC.csv # Lookup table mapping SNR to MCS and PDR
│
├── utils/                        # General PHY/MAC utility functions
│   ├── calculateSINR.m
│   ├── heRUAllocationTable.m
│   ├── heSuccessiveEqualize.m
│   ├── heTBRU.m
│   ├── heTBSystemConfig.m
│   ├── heTBUser.m
│   ├── tgaxLinkPerformanceModel.m
│   ├── tgaxMMSEFilter.m
│
├── utils_custom/                 # Custom configurations and analysis tools
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
