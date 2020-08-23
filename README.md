# MRI HEART IMAGE SEGMENTATION
## Machine Learning Model for the automatic image segmentation of the myocardium. left and right ventricles of the heart

Code for the segmentation of left ventricle, right ventricle and myocardium from MRI images of the heart. 
The dataset used is the [**ACDC Dataset**](https://www.creatis.insa-lyon.fr/Challenge/acdc/).
The dataset was pre-processed and can be found as [NPY files]( [https://drive.google.com/drive/folders/1ajiGTrYsDYRGzsjKXaW9QSvwwrHouGmP?usp=sharing](https://drive.google.com/drive/folders/1ajiGTrYsDYRGzsjKXaW9QSvwwrHouGmP?usp=sharing)).

An example of the manual image segmentation of the heart can be found as a series of Matlab scripts/functions for reference.

The machine learning model uses a 2D UNet Neural Network architecture with instance normalisation to increase training speed.
