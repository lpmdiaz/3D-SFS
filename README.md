# 3D-SFS
*Detecting positive selection from multidimensional site frequency spectra.*

## Set up

### To install

	git clone https://github.com/lpmdiaz/pop3D
	cd ./pop3D

### To compile

**Windows users** Can use CodeBlocks software to run and compile .cpp file.

**Mac users** Use XCode.

Would recommend using a virtual machine.

**Unix users**

	g++ -Wall 3D_SFS_to_log_likelihood_ratio.cpp -o CLRT


## Use

### To run the main script

The 3D global SFS file must be called "ms.3d.sfs", the 3D windows SFS file must be called "ms.3d.windows.sfs"; the program will automatically output the selection test result for each window in a file called "composite.log.likelihood.ratio".

	./CLRT 

### Plotting

**CLRT**
The *plotclrt.R* file takes the output of *pop3Dclrt* as an input and plots the CLRT in a pdf. This script takes in arguments the input CLRT file and the output pdf name (note: the extension will be added by default), as well as the pdf width and height parameters. Example:

	Rscript plotclrt.R clrt CLRT 14 7

This command will create the *CLRT.pdf* file containing the plotted CLRT.

**3D SFS**
Input 3D SFS, output pdf name without extention, then angles phi and theta.


	Rscript plot3Dsfs.R parsed3Dsfs 3Dsfs 40 40

### Rscript

	Rscript clrt3pop.R Data/ms.3d.windows.sfs Data/ms.3d.sfs > CLRT.txt







