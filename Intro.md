
# Introduction to the Golf Putting Analysis Repository

This repository provides a comprehensive workflow for collecting, synchronizing, analyzing, and segmenting golf putting data captured from both GoPro cameras and multiple sensor inputs (IMUs, magnetometry, and EMG). Each script or notebook within this repository corresponds to a major step in the data processing and analysis pipeline—from aligning and trimming raw video feeds to classifying putting accuracy.

The workflow begins by synchronizing GoPro videos (of the golfer and the hole) and integrating them with IMU sensor data. Subsequent steps involve identifying and classifying exact putting events, segmenting videos around these events, and performing accuracy analysis of each putt. By following the recommended script order, researchers and practitioners can seamlessly transition from raw data to high-level analytics of putting techniques and outcomes.

The data of the participants I used with these scripts is highly privacy-sensitive. To ensure ethical handling and compliance with privacy standards, access to the data is restricted. If you are an academic and would like to request access, please contact beorn01@gmail.com

Alternatively you can collect your own data:

For this analysis workflow to function properly, the following data is required:
GoPro Videos:
Videos of the golfer and the hole captured at a high frame rate (60 fps or higher). This ensures temporal precision for synchronization and analysis.

IMU EMG MAGnetometry Data:
Sensor data in .dat or .csv form capturing motion, muscle and magnetometry dynamics during the putting process. MAG sensors positioned beneath the astroturf where the putting takes place enables accurate detection of magnetic field disturbances caused by the putter, thereby classifying putts.

File Organization
The repository scripts assume specific file names for organization, but these can be changed in to accommodate other data collection paradigms. 

