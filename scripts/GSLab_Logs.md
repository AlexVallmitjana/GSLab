[v1.130] - Updated function for writing csv files to increase speed and allow xls format  
[v1.129] - Implemented loading masks as labeled pngs  
[v1.128] - Merged GS coordinate export with magnitude export to generate csv with all data together  
[v1.127] - Implemented a region connected components step to extract mean phasor values for each object in a mask  
[v1.126] - Simplified obsolete way in which masks were signaled to apply  
[v1.125] - Fixed a bug where after clearing the system was trying to apply mask  
[v1.124] - Changed calibration panel button behavior to remain in position  
[v1.123] - Save as ref allows up to 8harmonics  
[v1.122] - Modified refread to accomodate for ref formats up to 8harmonics  
[v1.121] - Added a warning when user tries to save ref files with only 1st harmonic
### May'25
[v1.120] - App reads changelog file to display version number  
[v1.119] - Modified csv writer function, now all csv files have headers  
[v1.118] - Simplified the way program deals with max harmonics computed  
[v1.117] - Fixed bug regarding loading previous settings  
[v1.116] - Added option to allow display of phasor axes and removed the export with/without axes functionality  
[v1.115] - Added plot Intensity vs Phasor Magnitude functionality  
[v1.114] - Modified ptu/sdt reader to accommodate for more channels  
[v1.113] - Added option for display axes in display tab and removed it from export  
[v1.112] - Fixed bug with batch load calibration files where only data from first one was being loaded  
[v1.111] - Added bidirectional correction option for FLAME data  
[v1.110] - Updated all FLAME imports to generic function
### Apr'25
[v1.109] - When cursor leaves phasor plot now it goes back to displaying the phasor-colored image  
[v1.108] - All user files are saved in Documents/MATLAB folder  
[v1.107] - Exporting phasor coordinates  
[v1.106] - Fixed a bug for files with uneven sizes  
[v1.105] - Added Anscombe transform option  
[v1.104] - Implemented wavelet filtering  
[v1.103] - Removed the need to reload the data when changing downsample  
[v1.102] - Added option to plot decay  
[v1.101] - Implemented PicoQuant ptu and Becker & Hickl sdt using CGohlke's Python libraries  
[v1.100] - Implemented FLIM LABS json format
### Mar'25
[v1.99] - Single traces can be loaded as txt/csv  
[v1.98] - Added gaussian filter for intensity images  
[v1.97] - Colormaps can be flipped, also added new colormaps
### Feb'25
[v1.96] - Added move deintercalated even/odd from file list  
[v1.95] - Added check even/odd from file list  
[v1.94] - Allow user to set spectral band for ticks in spectral phasors  
[v1.93] - Implemented stacks for lsm files  
[v1.92] - 3chan and 4chan now use intensity thresholds to enhance colors  
[v1.91] - Fixed a bug where margins were taken into account for normalizing merge images
### Jan'25
[v1.90] - Setting pure components as cursors (only for up to 3c, 1h)  
[v1.89] - Improved speed of pseudoHDR by using min/max instead of quantile  
[v1.88] - Improved speed or image rendering by rewriting ind2sub  
[v1.87] - Allow users to export magnitude spreadsheet files  
[v1.86] - Changed the image window creation and rendering for faster display time (x10)  
[v1.85] - Ratiometric spreadsheets can now include intensity column  
[v1.84] - Allow user to save/load current session including loaded files and all settings  
[v1.83] - Added compatibility with indexed images in masks  
[v1.82] - Released public version to FigShare
### Dec'24
[v1.81] - Phasors can be exported as vector files  
[v1.80] - Added file format dropdowns for phasors, decays and images  
[v1.79] - Added functionality to load files via context menu  
[v1.78] - Image window is now a uifigure instead of figure  
[v1.77] - Removed menus on the top  
[v1.76] - Files can be moved around to sort the order  
### Nov'24
[v1.75] - Phasor Plot panel can be directly exported  
[v1.74] - User can change tag associated to calibration file  
[v1.73] - Calibration is a table which shows tags, lifetime and filename  
[v1.72] - Allow user to use a loaded file as calibration  
[v1.71] - Added manual calibration functionality  
[v1.70] - Single composition of all combos images can be exported  
[v1.69] - Included single color option for the colormapping of phasor density and magnitude coloring  
[v1.68] - Add/remove margins in Image Window  
[v1.67] - Image Window contents can be directly exported  
[v1.66] - Added auto color range functionality  
[v1.65] - Pure components can be obtained from empirical measurements by selecting loaded files  
[v1.64] - User can set the tiling dimensions of image window  
[v1.63] - Added option to merge component image exports in unmixing panel  
[v1.62] - Solved the generating 3chan images ambiguity issue  
[v1.61] - Added a clustering tab for performing GMM and implemented cluster coloring and exporting capabilities  
[v1.60] - Added overlay to main tab panel labels to be able to add more tabs and control size and appearance  
### Oct'24
[v1.59] - Phasor contours can be added  
[v1.58] - When multiple files are loaded, phasor can be normalized by file  
[v1.57] - Phasor density can be plotted as log value  
[v1.56] - Intensity threshold can now be applied in absolute units in addition to relative  
[v1.55] - Allow user to export composition grouping by file or by component  
[v1.54] - User can specify the grid dimensions of the composition image  
[v1.53] - Component images can be saved individually or as a single composition image with or without margins  
[v1.52] - Intensity values can be exported with unmixed component fraction for photon-weighted averaging  
[v1.51] - Implemented ability to load mosaics as single or as split tiles  
[v1.50] - Added context menu to File panel to check all/none/invert and clear unchecked  
[v1.49] - Allow user to change downsampling factor for computational time cutdown (also to load UMAP data as ref)  
[v1.48] - Ratiometric image data can be exported as csv  
[v1.47] - Implemented loading Zmosaics  
[v1.46] - Added the ability to generate 3chan image from couples of A0 and A1 sharing a name or out of a 32sp  
[v1.45] - Added a panel that displays the current mask being applied  
[v1.44] - Allow user to turn intensity-thresholded image into a binary mask to save or load  
[v1.43] - Allow sending pixels above cap to zero to exclude them from computation  
[v1.42] - Added a panel to display image histograms and a slider to change the intensity threshold and cap  
### Sep'24
[v1.41] - Allow to generate ratiometric images of fraction of one component over another  
[v1.40] - Allow to export color-coded fraction, fraction-times intensity and a csv file with fraction values  
[v1.39] - User can compute unmixing of data at high and low resolution and export fraction images  
[v1.38] - Components are plotted on the fly and user can specify if they should be rendered and if lines should be added  
[v1.37] - Added phasor unmixing panel where user can manually add/remove components and specify their lifetime  
[v1.36] - Allow user to specify the excitation frequency in order to compute all transforms as a function of it  
[v1.35] - Allow user to change the colormap of the magnitude measured on the phasor plot  
[v1.34] - Allow user to change the colormap of the density representation on the phasor plot  
[v1.33] - Allow user to change the color of the preset cursors  
[v1.32] - Allow user to invert masks  
[v1.31] - Added ability to export single image as mask to apply to all loaded files  
[v1.30] - Allow user to request and plot and export specific harmonics  
[v1.29] - Allow user introduces the max number of harmonics to limit time  
[v1.28] - Implemented computation of N harmonics (instead of 1) but computational time is linear with N  
[v1.27] - Created a display tab for minor user configurations (lines on the plot, numbers, axes and tick font sizes)  
[v1.26] - Added ability to save current cursor masks to load in a posterior session  
[v1.25] - Added ability to save current cursor positions and sizes to load in a posterior session  
[v1.24] - Implemented functionality for stacks and mosaics  
[v1.23] - Rearranged app to have bigger phasor space and different sections in tabs  
[v1.22] - Implement calibration on distinct channels in order to hold 3 different calibration (32split,32A0 and 32A1)  
[v1.21] - Redo the way data is shown by using a panel of loaded files (simFCS style) where user can check/uncheck specific files  
### Aug'24
[v1.20] - Allow to save and load simFCS ref files  
[v1.19] - Allow to import Leica FALCON exported SnG data  
[v1.18] - Added the possibility to export at high res to understand the effect of spatial filtering  
[v1.17] - Changed the way data is crunched (used to load and export every time, now it preloads and keeps in memory, computes only when requested)  
[v1.16] - Allow for user to lay cursors on the phasor plot and keep rotating among a preset number of colors  
[v1.15] - Added real time display of phasor coordinates  
[v1.14] - Added interactive mouse response on image space that shows cursor on phasor space  
[v1.13] - Added interactive cursor that can be moved around the phasor plot and light the image space (at the cost of precomputing low resolution images and making all data manipulation on the low res)  
[v1.12] - Added window that renders intensity images  
[v1.11] - Added option to export colorbar  
[v1.10] - Added option to measure different magnitudes (S, G, Phase, Mod, NormPhase, TauPhase, TauMod)  
[v1.9] - Implemented a system to save all user defined values to a local file so that every time user starts the program everything is where they left it at (including window positions)  
[v1.8] - User can select which items to export (intensity image, phasor-coded image, phasor-coded times intensity, phasor plot)  
[v1.7] - User can change intensity lower and upper limits, S and G range, add a color-coded background to map to images  
[v1.6] - Real time computation of phasors while modifying parameters using edit fields  
[v1.5] - First GUI for the app  
[v1.4] - Allow to calibrate phasor for independent channels manually imputing the lifetime of the calibration measurement  
### Jul'24
[v1.3] - Implemented the possibility to extract the accumulated decay of an image  
[v1.2] - Added S and G range as parameters  
[v1.1] - Added a section at the begining with phasor filtering parameters  
[v1.0] - First simple script to read FLAME files, phasor transform and generate 2D histogram   
### Jun'24 - Suman requests a script to plot phasors from FLAME data

