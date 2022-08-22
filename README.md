# Real-time Estimation of Elbow Angular Position using EMG Signal with NARX Model

This project is part of my final project as an undergraduate student majoring in Biomedical Engineering.

Hardware:
1. NI myDAQ Student Data Acquisition Device
2. Myoware EMG Sensor
3. Bourns 3590S-2-502L Precision Potentiometer

Software:
1. MATLAB R2021a

Status: Finished

## EMG and Angle Data Acquisition

In this project, I obtained 35 dataset with each dataset consisting of timestamp, EMG, and angle data for 20 seconds at a rate of 1000 data per second. So the total data length for this project is 700000 data points or 700 seconds.

![Raw data](https://user-images.githubusercontent.com/80141940/177251610-cd752b29-911a-4bfe-bd78-e7e589cb7d88.png)

## Dataset Preparation and Preprocessing

Once the datasets are combined into one, they have to go through preprocessing steps. For EMG data, it is filtered with Butterworth IIR Filter. The first filter is second order Bandpass filter with bandpass frequency of 10 - 450 Hz because usually the important component of EMG signal lies between 10-20 Hz (high-pass) and 450-500 Hz (low-pass). The second filter is Notch filter at 50 Hz frequency. This is important to eliminate the noise from power line (Power Line Interference / PLI).

For angle data from potentiometer, it is filtered with moving average filter for smoothing and to remove any spike artifacts. This filter uses 100 ms window.

![filtered data split](https://user-images.githubusercontent.com/80141940/177253207-87e83216-6ff7-431a-918a-810d0bb1c67b.png)

## Feature Extraction

To train and make a NARX model, it is important to define the features that mathematically can be recognized easily by a machine. To do this, the data needs to be segmented and from there its features can be extracted. This data is segmented using disjoint window with the length of each window segment is 100 ms.

The features of EMG data from this dataset is extracted using Zero Crossing and Integrated EMG

![fitur](https://user-images.githubusercontent.com/80141940/177255679-46ab1d37-8a88-4c3b-a79a-46f2027870e4.png)
![fitur zoom](https://user-images.githubusercontent.com/80141940/177255690-4148344b-3af3-4056-95f6-0d98ce374c27.png)
