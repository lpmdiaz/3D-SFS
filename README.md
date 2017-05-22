# pop3D: detecting positive selection from multidimensional site frequency spectra
  
This software detects positive selection in three populations using the Composite Likelihood Ratio Test (CLRT) as a test for selection. It requires two 3D SFS files in input, as follows:

+ a *global* SFS file containing the SFS of the whole genomic region;
+ a *windows* SFS file containing the SFS of windows of the global file. This approach allows to perform the CLRT test as a sliding window.

Note: this software is integrated within a pipeline allowing the simulation of genomic data (with [MSMS](http://www.mabs.at/ewing/msms/index.shtml)) and the estimation of the 3D SFS (both global and windows, with [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD)). This is described in the pipeline file.

## Set up

### Unix

On Unix machines, you can install and compile the software by doing:

	git clone https://github.com/lpmdiaz/pop3D
	cd pop3D
	make

### Other operating systems

We would recommend using a virtual machine running a Unix OS (such as [Oracle VM VirtualBox](https://www.virtualbox.org/) running [Ubuntu](https://www.ubuntu.com/download/desktop)). Alternatively, **Windows** users can use the [CodeBlocks](http://www.codeblocks.org/) software to run and compile the C++ files to executables. In a similar way, **Mac** users should use XCode.

## Use

### Composite likelihood ratio test

With the **pop3D** repository in the path, do

	./pop3Dclrt

to display information on the arguments the software needs. As an example, the call

	./pop3Dclrt ./data/ms.3d.sfs ./data/ms.3d.windows.sfs clrt

runs the program with the input files *ms.3d.sfs* and *ms.3d.windows.sfs* located in the **Data** folder, and outputs the test result in the *clrt* file. This file can then be plotted as described in the following section.

### Plotting

#### CLRT

The *plotclrt.R* script takes the output of *pop3Dclrt* as an input and plots the CLRT in a pdf. This script takes in arguments the input CLRT file and the output pdf name (note: the extension will be added automatically), as well as the pdf width and height parameters. As an example, the call

	Rscript plotclrt.R ../clrt CLRT 14 7

plots the CLRT stored in the *clrt* file (in the parent directory) to the *CLRT.pdf* file, with a width of 14 and height of 7.

#### 3D SFS

Before plotting the 3D SFS with the R file, the SFS file needs to be parsed. The *parse3Dsfs* program builds an index of 3D coordinates and fills it wth the corresponding SFS values. The call

	./parse3Dsfs

will display information on the arguments this program needs (assuming the path now contains the **plotting** folder). As an example, the call

	./parse3Dsfs ../data/ms.3d.sfs parsed3Dsfs 10 10 10 42

creates an indexed 3D SFS file called *parsed3Dsfs* of the 42nd window, with specified population sizes. This file can now be used to plot the 3D SFS using the *plot3Dsfs.R* program, which takes as input the parsed 3D SFS, the output pdf name and optionally the two phi and theta angles (note: the extension will be added automatically). As an example, the call

	Rscript plot3Dsfs.R parsed3Dsfs 3Dsfs 40 40

does blah blah blah. Note that this program requires the *plot3D* R package. Do

	sudo Rscript ./plot3Dsfs.R [with the rest of the arguments]

the first time to install the package if not already installed (also to install *rgl* and *plot3Drgl* packages for interactive plotting).

### Rscript

	Rscript clrt3pop.R Data/ms.3d.windows.sfs Data/ms.3d.sfs > CLRT.txt

## Examples

Provide simulated files.
