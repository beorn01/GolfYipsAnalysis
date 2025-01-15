# README

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
