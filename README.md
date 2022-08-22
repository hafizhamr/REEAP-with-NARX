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

In this project, I obtained 39 dataset with each dataset consisting of timestamp, EMG, and angle data for 20 seconds at a rate of 10000 data per second. So the total data length for this project is 7800000 data points or 780 seconds.

![rawSudutEMG](https://user-images.githubusercontent.com/80141940/185895233-7a9972c2-4388-4431-be31-f33d4cc0e354.png)

## Dataset Preparation and Preprocessing

Once the datasets are combined into one, they have to go through preprocessing steps. For EMG data, it is filtered with Butterworth IIR Filter. The first filter is second order Bandpass filter with bandpass frequency of 10 - 450 Hz because usually the important component of EMG signal lies between 10-20 Hz (high-pass) and 450-500 Hz (low-pass). The second filter is Notch filter at 50 Hz frequency. This is important to eliminate the noise from power line (Power Line Interference / PLI).

![filtNotch](https://user-images.githubusercontent.com/80141940/185896113-0193e4e0-4a6f-426e-9c47-03544a6d029b.png)

For angle data from potentiometer, it is filtered with moving average filter for smoothing and to remove any motion artifacts. This filter uses 500 ms window.

![filtSudut](https://user-images.githubusercontent.com/80141940/185896132-2cf572e8-3aef-4e32-99e3-4de0310b1391.png)

## Feature Extraction

To train and make a NARX model, it is important to define the features that mathematically can be recognized easily by a machine. To do this, the data needs to be segmented and from there its features can be extracted. This data is segmented using disjoint window with the length of each window segment is 50 ms, 100 ms, and 200 ms.

The features of EMG data from this dataset is extracted using Zero Crossing and Integrated EMG

Window: 50 ms
![fitur-50](https://user-images.githubusercontent.com/80141940/185896274-83345b9e-08fc-457e-9a26-1213224a0c95.png)

Window: 100 ms
![fitur-100](https://user-images.githubusercontent.com/80141940/185896282-1fe35aec-54cd-493d-9239-882b7668c7d0.png)

Window: 200 ms
![fitur-200](https://user-images.githubusercontent.com/80141940/185896345-b289ddf3-6120-4b00-8724-2b888c20d062.png)

## Open-loop Training

Window&nbsp;&nbsp;&nbsp;: 50 ms

Network &nbsp;&nbsp;: 9 hidden layers, 5 input delays, and 5 feedback delays

RMSE &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 0,378527731°

R &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 0,99993258

Accuracy  &nbsp;: 98,838%
![OLT-50](https://user-images.githubusercontent.com/80141940/185896519-b4fb6664-5867-4347-86ce-3beaa615b49e.png)

Window&nbsp;&nbsp;&nbsp;: 100 ms

Network &nbsp;&nbsp;: 4 hidden layers, 5 input delays, and 3 feedback delays

RMSE &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 1,254589868°

R &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 0,99926381

Accuracy  &nbsp;: 96,15%
![OLT-100](https://user-images.githubusercontent.com/80141940/185896539-7f119fa8-680b-4f7d-bd02-780e62b3c2ae.png)

Window&nbsp;&nbsp;&nbsp;: 200 ms

Network &nbsp;&nbsp;: 6 hidden layers, 2 input delays, and 5 feedback delays

RMSE &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 3,527780428°

R &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: 0,99425133

Accuracy  &nbsp;: 89,175%
![OLT-200](https://user-images.githubusercontent.com/80141940/185896556-b9a6e893-1315-4ef9-a06a-7670dee5c9f5.png)

## Closed-loop Training

Window: 50 ms
![UjiCL-50](https://user-images.githubusercontent.com/80141940/185896605-218a3e0b-29cd-4ead-9b2d-b365c9f3e03b.png)

Window: 100 ms
![UjiCL-100](https://user-images.githubusercontent.com/80141940/185896622-3a85e3fb-d821-4eb7-86af-6d79829f7980.png)

Window: 200 ms
![UjiCL-200](https://user-images.githubusercontent.com/80141940/185896631-3c83ba9e-e9b8-44a9-99f3-8a636da572f8.png)

## Real-time Implementation

Window: 50 ms
![RT-50](https://user-images.githubusercontent.com/80141940/185896655-0f3307e0-9c3e-4f20-9af2-bbdce9545af0.png)

Window: 100 ms
![RT-100](https://user-images.githubusercontent.com/80141940/185896659-9921f9d7-eeba-493c-bdc5-b968675e57aa.png)

Window: 200 ms
![RT-200](https://user-images.githubusercontent.com/80141940/185896711-d51a5bc5-25db-4371-baa2-b78111c0ce7d.png)



