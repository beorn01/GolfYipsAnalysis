# README

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



## 1. One_Video_Syncing_GoPro_Cameras.ipynb

### Purpose
Synchronizes two GoPro cameras based on timestamps, ensuring all video feeds are aligned for downstream analysis.

- **Setup**: One camera points at the golfer, and the other at the hole from a vertical position to measure putting accuracy.

### Input
- Raw video files from two GoPro cameras.
- Metadata from both cameras for synchronization based on timestamp.

### Output
- Synchronized video files with matching start/end times and identical frame counts.

### Interaction
Prepares synchronized video data for further analysis, such as IMU integration (script Two_Syncing_GoPro_Cameras_with_IMUs.ipynb).

---

## 2. Two_Syncing_GoPro_Cameras_with_IMUs.ipynb

### Purpose
Syncs GoPro camera video feeds with IMU data, aligning motion data with video recordings.

- **Highlight**: Utilizes the moment of ball contact as a key synchronization marker.

### Input
- Raw IMU data files.
- Synchronized videos from One_Video_Syncing_GoPro_Cameras.ipynb.

### Output
- Combined data files with synchronized video and IMU data.
- A "Time Axis Alignment" file mapping video frames to kinematic data.

### Interaction
Produces datasets essential for motion analysis and video segmentation.

---

## 3. Three_Putt_Classification.m

### Purpose
Classifies putts based on magnetometry data, calculating rest periods between putting sessions to define conditions.

### Input
- IMU data (magnetometry, EMG, kinematics).

### Output
- Exact moments of putts in kinematic/EMG data.
- Classification of conditions (e.g., hands used, ball/no ball).

### Interaction
Links putting events in kinematic data to video frames using the Time Axis Alignment file.

---

## 4. Four_Putt_Accuracy_Classification.m

### Purpose
Classifies putts by accuracy metrics (distance, direction, success).

### Input
- Videos from the camera pointing at the hole.

### Output
- Accuracy results: ball/hole coordinates, distances, and classifications (e.g., success/failure).

### Interaction
Syncs accuracy metrics with kinematic and EMG data via the Time Axis Alignment file.

---

## 5. Five_Cutting_and_Creating_GoPro_Videos.ipynb

### Purpose
Cuts synchronized GoPro videos into segments based on identified putting moments.

### Input
- Synchronized videos from One_Video_Syncing_GoPro_Cameras.ipynb.
- Time Axis Alignment file from Two_Syncing_GoPro_Cameras_with_IMUs.ipynb.
- Classified putts from Three_Putt_Classification.m.

### Output
- Video clips focused on putting events, labeled with corresponding kinematic indices.

### Interaction
Prepares video segments for manual review or automated analysis.

---

## 6. Six_Hole_Location_Injection.m

### Purpose
Corrects and ensures hole locations are properly integrated into accuracy analysis files.

### Input
- Videos focused on putting accuracy.

### Output
- Updated accuracy files with hole location metadata.

---

## Workflow Summary

### Video Synchronization and IMU Integration
1. **One_Video_Syncing_GoPro_Cameras.ipynb**: Aligns GoPro cameras and synchronizes videos.
2. **Two_Syncing_GoPro_Cameras_with_IMUs.ipynb**: Integrates IMU data, creating a Time Axis Alignment file.

### Defining and Segmenting Putting Events
3. **Three_Putt_Classification.m**: Identifies putting moments and conditions.
4. **Five_Cutting_and_Creating_GoPro_Videos.ipynb**: Cuts videos into segments based on identified putts.

### Accuracy Analysis and Metadata Injection
5. **Four_Putt_Accuracy_Classification.m**: Tracks putting accuracy.
6. **Six_Hole_Location_Injection.m**: Updates metadata with hole locations.

---

## File Dependencies

- **Video Files**: Organized in `Videos/Videopanel` and `Videos/Results` directories.
- **EMG Data**: Includes calibrated sensor files (`.dat`).

### Sensor Data Channels
| Channel ID | Role/Location                      | Data Types                       |
|------------|------------------------------------|----------------------------------|
| 7ED1       | Magnetometer 1 (ground, clubhead)  | UTC, Mag x, Mag y, Mag z        |
| 7EDB       | Magnetometer 2 (ground)           | Mag x, Mag y, Mag z             |
| 8AAA       | Right Arm Kinematics (wrist)      | Accel x/y/z, AngVel x/y/z       |
| 8009       | Left Arm Kinematics (wrist)       | Accel x/y/z, AngVel x/y/z       |
| 541A       | Putter Kinematics                 | Accel x/y/z, AngVel x/y/z       |
| 88F1       | Pronator Teres Muscle Data        | Muscle Activation Data          |
| 88F4       | Pronator Quadratus Muscle Data    | Muscle Activation Data          |
| 88F6       | Supinator Muscle Data             | Muscle Activation Data          |
| 8FCF       | Brachioradialis Muscle Data       | Muscle Activation Data          |

---

## Usage Notes

1. Follow the recommended script execution order.
2. Use the specified folder and naming conventions.
3. Review script headers for detailed requirements.

---

## Contact
For assistance, contact **Beorn Nijenhuis** at [beorn01@gmail.com].
