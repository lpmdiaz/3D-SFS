/*
program to compute the CLRT from 3D SFS
input is a global 3D sfs  file and the corresponding local windows 3D sfs file
*/

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <cmath>
#include <iomanip>
using namespace std;


// parse a string line to a vector of doubles
void line_to_vector (string line, vector<double> & v) {
    stringstream ssline(line); double d;
    while(ssline >> d)
    {
        v.push_back(d);
    }
}

// remove the first and last values from the input vector
void zero_freq_remove (vector<double> & v) {
    v.erase(v.begin() + 0);
    v.erase(v.begin() + v.size()-1);
}

// help factor calculation for window SFS scaling
double calculate_help_fact (double globalSNPsnr) {
    double help_fact;
    double windowsSNPsnr;
    int windowsnr = 0; // will count the number of windows in the windows SFS file
    string line;        // string to store each line of the files
    vector<double> sfs; // vector to store the elements of each line
    string windows_sfs_file = "ms.3d.windows.sfs";
    ifstream windows_sfs (windows_sfs_file.c_str()); // input windows SFS

    // GET WINDOWS SNPs NUMBER
    while (getline(windows_sfs, line)) // read windows SFS file line by line
    {
        line_to_vector(line, sfs); // parse line
        zero_freq_remove(sfs); // remove first and last SFS values
        for (int i = 0; i < sfs.size(); i++) windowsSNPsnr += sfs[i]; // sums up SNPs
        windowsnr += 1;
        sfs.clear();
    }

    help_fact = globalSNPsnr / (windowsSNPsnr/windowsnr); // global SNPs number / mean windows SNPs number
    windows_sfs.close();
    return help_fact;
}

// composite likelihood calculation
double calculate_CL (vector<double> & v, double & nrSNPs, double & help_fact) {
    double CL = 0; double pk = 0; // the CL will be the sum of all p^k values
    for (int i = 0; i < v.size(); i++) {
        pk = log( pow((v[i]/nrSNPs), v[i]/help_fact) ); // log transformation
        CL+=pk;
    }
    return CL;
}

// CLRT calculation
double calculate_CLRT (double X, double Y) {
    double CLRT;
    CLRT = 2*(X-Y);
    return CLRT;
}

// help printout
void info() {
    fprintf(stderr,"Required arguments:\tGlobal 3D SFS file path\n");
    fprintf(stderr,"\t\t\tWindows 3D SFS file path\n");
    fprintf(stderr,"\t\t\tOutput file name\n");
}


//                //
//      MAIN      //
//                //

int main (int argc, char *argv[]) {

    // HELP PRINTOUT
    if (argc==1) {
        info();
        return 0;
    }
    
    // CHECKING CORRECT ARGUMENT NUMBER
    if (argc < 4) {
        cout << "Error: not enough arguments!\n";
        return 0; // terminate
    }

    // OPENING FILES, SETTING VARIABLES
    ifstream global_sfs (argv[1]);      // input files (the global
    ifstream windows_sfs (argv[2]);     // and windows SFS files)
    if ( !global_sfs.is_open() ) { // checking that the first file was successfully open
        cout<<"Could not open the global SFS file\n";
        return 0; // terminate
    }
    if ( !windows_sfs.is_open() ) { // checking that the second file was successfully open
        cout<<"Could not open the windows SFS file\n";
        return 0; // terminate
    }
    ofstream clrt_output(argv[3], ios::trunc); // output file to store test results
    string line;        // string to store each line of the files
    vector<double> sfs; // vector to store the elements of each line
    double global_CL;   // double to store the global CL value
    double windows_CL;  // double to store the CL for each window in turn
    double CLRT;        // double to store the test results

    // CALCULATE THE GLOBAL COMPOSITE LIKELIHOOD
    getline(global_sfs, line); // retrieving the first and only line of the
    cout << "Global SFS line: "<< line << "\n"; ////////////////////////////////////////////////////////////////////////////////////////
    line_to_vector(line, sfs); // global SFS file and storing it into a vector
    cout << "Checking SFS value: " << sfs[42] << "\n"; /////////////////////////////////////////////////////////////////////////////////
    zero_freq_remove(sfs); // remove first and last SFS values
    cout << "Checking SFS values: " << sfs[41] << " " << sfs[42] << " " << sfs[43] << "\n"; ////////////////////////////////////////////
    double globalSNPsnr = 0; for (int i = 0; i < sfs.size(); i++) globalSNPsnr += sfs[i]; // number of SNPs in global SFS
    cout << "Global SNPs number: " << globalSNPsnr << "\n"; ////////////////////////////////////////////////////////////////////////////
    double help_fact = calculate_help_fact(globalSNPsnr);
    cout << "Help factor for debugging purposes (should be 99.9385): " << help_fact << "\n"; ///////////////////////////////////////////
    global_CL = calculate_CL(sfs, globalSNPsnr, help_fact);
    sfs.clear();

    // CALCULATE WINDOWS CL, CALCULATE AND STORE THE CL RATIO TEST RESULT
    help_fact = 1;
    while (getline(windows_sfs, line)) // read windows SFS file line by line
    {
        line_to_vector(line, sfs); // parse line
        zero_freq_remove(sfs); // remove first and last SFS values
        double windowSNPsnr = 0; for (int i = 0; i < sfs.size(); i++) windowSNPsnr += sfs[i]; // number of SNPs in windows SFS
        windows_CL = calculate_CL(sfs, windowSNPsnr, help_fact);
        CLRT = calculate_CLRT(windows_CL, global_CL);
        clrt_output << setprecision(10) << CLRT << " \n";
        sfs.clear();
        //cout << CLRT << " "; //////////////////////////////////////////// -nan
    }

    // CLOSING FILES
    global_sfs.close();
    windows_sfs.close();
    clrt_output.close();

    return 0;
}

