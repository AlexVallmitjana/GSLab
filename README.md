# GSLab: Open-Source Platform for Advanced Phasor Analysis in Fluorescence Microscopy

## Summary

The phasor approach to fluorescence lifetime imaging is a widely used method for image analysis in biophysics and a range of other fields. GSLab addresses the need for effective image analysis tools in fluorescence microscopy by providing an open-source platform that enhances traditional phasor analysis with advanced features. Key capabilities include machine learning-based clustering, real-time monitoring, and quantitative unmixing of fluorescent species. Designed for both commercial and custom systems, GSLab provides researchers with comprehensive lifetime and spectral phasor image analysis tools to tackle complex biological problems.

## Installation

**GSLab** requires **MATLAB2023b** or later with **Image Processing Toolbox** and **Statistics and Machine Learning Toolbox**. Follow these steps to set up and launch the program for the first time:
1.  Download the [package](https://github.com/AlexVallmitjana/GSLab/archive/refs/heads/main.zip).
2.  Unzip the package and copy it to a location in your computer.
3.	Open MATLAB and navigate to the **Home** tab.
4.	In the **Environment** section, click **Set Path**.
5.	In the **Set Path** window, click **Add with Subfolders**.
6.	Browse to the location where you copied GSLab-main, then click **Select Folder**.
7.  Check the checkbox **Save path for future sessions** and then **Apply** and **Ok**.  
7b.	In older versions (the checkbox is not there) click **Save** in the Set Path window and then click **Close**.

  
To launch the program, type **GSLab** in the MATLAB command window.  
Once the path has been saved in MATLAB, simply type GSLab in the command window to run the program in subsequent sessions.

### Help

A [user manual pdf file](GSLab_Manual.pdf) is inculded in the main directory. 

A follow-along [tutorial and sample files](https://doi.org/10.6084/m9.figshare.28067108) are available for download in Figshare.

### Standalone app for Windows without MATLAB

A precompiled executable [installer file for Windows](https://doi.org/10.6084/m9.figshare.28655276) is available in Figshare.

Simply download the file **GSLabInstaller.exe**, run the installer, it will install the MATLAB Runtime machine and **GSLab** in the **ProgramFiles** folder. 


## Citing
If you find this software valuable, please cite us using our [paper](https://doi.org/10.1093/bioinformatics/btaf162) in Bioinformatics:
```
Vallmitjana A. et al. GSLab: Open-Source Platform for Advanced Phasor Analysis in Fluorescence Microscopy, Bioinformatics (2025). https://doi.org/10.1093/bioinformatics/btaf162
```
