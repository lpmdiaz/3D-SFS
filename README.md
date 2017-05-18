# 3D-SFS
*Detecting positive selection from multidimensional site frequency spectra*

**To install**

	git clone https://github.com/lpmdiaz/3D-SFS
	cd ./3D-SFS

**To compile**

	g++ -Wall 3D_SFS_to_log_likelihood_ratio.cpp -o CLRT

**To run**, the 3D global SFS file must be called "ms.3d.sfs", the 3D windows SFS file must be called "ms.3d.windows.sfs"; the program will automatically output the selection test result for each window in a file called "composite.log.likelihood.ratio".

	./CLRT 


**Rscript**

	Rscript clrt3pop.R Data/ms.3d.windows.sfs Data/ms.3d.sfs > CLRT.txt







