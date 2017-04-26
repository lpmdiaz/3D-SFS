# 3D-SFS
*Detecting positive selection from multidimensional site frequency spectra*

**To compile**
	gcc ...

**To run**, the 3D global SFS file must be called "ms.3d.sfs", the 3D windows SFS file must be called "ms.3d.windows.sfs"; the program will automatically output the selection test result for each window in a file called "composite.log.likelihood.ratio".


**Rscript**

	Rscript clrt3pop.R Data/ms.3d.windows.sfs Data/ms.3d.sfs > CLRT.txt







