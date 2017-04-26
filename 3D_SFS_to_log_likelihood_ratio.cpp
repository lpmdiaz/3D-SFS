#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <cmath>
#include <iomanip>
using namespace std;


void line_to_vector (string line, vector<double> & v)   // parse a string line
{                                                       // to a vector of doubles
    stringstream ssline(line); double d;
    while(ssline >> d)
    {
        v.push_back(d);
    }
}

void zero_freq_remove (vector<double> & v)  // remove the first and last
{                                           // values from the input vector
    v.erase(v.begin() + 0);
    v.erase(v.begin() + v.size()-1);
}

double calculate_help_fact (double globalSNPsnr)
{
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


double calculate_CL (vector<double> & v, double & nrSNPs, double & help_fact)    // composite likelihood calculation
{
    double CL = 0; double pk = 0; // the CL will be the sum of all p^k values

    for (int i = 0; i < v.size(); i++)
    {
        pk = log( pow((v[i]/nrSNPs), v[i]/help_fact) ); // log transformation
        CL+=pk;
    }
    return CL;
}

double calculate_CLRT (double X, double Y)  // CLRT calculation
{
    double CLRT;
    CLRT = 2*(X-Y);
    return CLRT;
}


int main (void)
{
    // SETTING FILE NAMES
    string global_sfs_file, windows_sfs_file;
    global_sfs_file = "ms.3d.sfs";
    windows_sfs_file = "ms.3d.windows.sfs";

    // OPENING FILES, SETTING VARIABLES
    ifstream global_sfs (global_sfs_file.c_str());      // input files (the global
    ifstream windows_sfs (windows_sfs_file.c_str());    // and windows SFS files)
    ofstream clrt_output("composite.log.likelihood.ratio", ios::trunc); // output file to store test results
    string line;        // string to store each line of the files
    vector<double> sfs; // vector to store the elements of each line
    double global_CL;   // double to store the global CL value
    double windows_CL;  // double to store the CL for each window in turn
    double CLRT;        // double to store the test results

    // CALCULATE THE GLOBAL COMPOSITE LIKELIHOOD
    getline(global_sfs, line); // retrieving the first and only line of the
    line_to_vector(line, sfs); // global SFS file and storing it into a vector
    zero_freq_remove(sfs); // remove first and last SFS values
    double globalSNPsnr = 0; for (int i = 0; i < sfs.size(); i++) globalSNPsnr += sfs[i]; // number of SNPs in global SFS
    double help_fact = calculate_help_fact(globalSNPsnr);
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
    }

    // CLEANING UP
    global_sfs.close();
    windows_sfs.close();
    clrt_output.close();

    return 0;
}

