#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <iterator>
#include <sstream>
#include <cmath>
using namespace std;


void calc_proba (string input_filename, string output_filename) // calculate derived allele probabilities
{
    // DECLARE INPUT, OUTPUT AND VARIABLES
    ifstream input (input_filename.c_str());
    ofstream output(output_filename.c_str(), ios::trunc); // truncate mode to overwrite the file each time
    string line;

    // PROBABILITY CALCULATION AND STORAGE
    while (getline(input, line)) // read file line by line
    {
        // STORE INDIVIDUAL ELEMENTS OF LINE IN VECTOR
        stringstream ssline(line);      // consider each string line as a stream
        istream_iterator<float> begin(ssline);  // iterator extracts elements of the string stream,
        istream_iterator<float> end;            // from the beginning to the end of the stream
        vector<float> v(begin, end);    // fill vector with individual elements
        float totaln = v.size()/3;      // retrieve total number of sites

        // CALCULATE PROBABILITIES FROM 3D FREQUENCIES
        for (int i = 0; i < v.size(); i+=3)
        {
            float freqi = (v[i]+v[i+1]+v[i+2])/3;       // calculate 3D frequency and
            float probi = pow((freqi/totaln), freqi);   // derive the probability

            // WRITE PROBABILITY TO OUTPUT
            if (probi > 1) {                // loop implemented to replace
                output << "1 ";             // probabilities greater than 1
            } else {                        // with a probability of 1
                output << probi << " ";     // in the output
            }
        }
        output << "\n"; // add new line to output
    }

    // ERROR DIAGNOSTIC
    if (input.is_open() == false)
    {
        string diagnostic = "Error opening file: ";
        cout << diagnostic << input_filename << endl;
    }

    input.close(); output.close(); // close files
}


float calc_global_cl (string input_filename, string output_filename) // calculate global composite likelihood and export to file
{
    // DECLARE INPUT, OUTPUT AND VARIABLES
    ifstream input (input_filename.c_str());
    ofstream output(output_filename.c_str(), ios::trunc);
    string line;

    // STORE INDIVIDUAL ELEMENTS OF LINE IN VECTOR
    getline(input, line);           // extract the first and only line of the file
    stringstream ssline(line);      // consider line as a string stream
    istream_iterator<float> begin(ssline);  // iterator extracts elements of the string stream,
    istream_iterator<float> end;            // from the beginning to the end of the stream
    vector<float> v(begin, end);    // fill vector with individual elements

    // CALCULATE GLOBAL COMPOSITE LIKELIHOOD
    float global_cl = 0;    // declare global composite likelihood
    for (int i = 0; i < v.size(); i++)
    {
        global_cl+=log(v[i]);       // use log transformation
    }
    global_cl = exp(global_cl);     // use exp to go back to the product

    // EXPORT GLOBAL COMPOSITE LIKELIHOOD TO FILE
    output << global_cl << " \n";

    input.close(); output.close(); // close files
    return global_cl;
}


float log_likelihood_ratio (float X, float Y) // calculate and return log likelihood ratio statistical test
{
    float test_result = 2*(log(X) - log(Y));
    return test_result;
}


// calculate and export to file composite likelihood for each window, test against global composite likelihood
void calc_windows_cl (string input_filename, string output_filename, float global_cl)
{
    // DECLARE INPUT, OUTPUT AND VARIABLES
    ifstream input (input_filename.c_str());
    ofstream output(output_filename.c_str(), ios::trunc);
    ofstream test_output("log.likelihood.ratio", ios::trunc);
    string line;

    // COMPOSITE LIKELIHOOD AND STATISTICAL TEST CALCULATION
    while (getline(input, line)) // read file line by line
    {
        // STORE INDIVIDUAL ELEMENTS OF LINE IN VECTOR
        stringstream ssline(line);      // consider each string line as a stream
        istream_iterator<float> begin(ssline);  // iterator extracts elements of the string stream,
        istream_iterator<float> end;            // from the beginning to the end of the stream
        vector<float> v(begin, end);    // fill vector with individual elements

        // CALCULATE COMPOSITE LIKELIHOOD FOR THE WINDOW
        float window_cl = 0;
        for (int i = 0; i < v.size(); i++)
        {
            window_cl+=log(v[i]);       // use log transformation
        }
        window_cl = exp(window_cl);

        // EXPORT GLOBAL COMPOSITE LIKELIHOOD TO FILE
        output << window_cl << " \n";

        // CALCULATE AND EXPORT LOG LIKELIHOOD RATIO
        float test_result = log_likelihood_ratio(window_cl, global_cl);
        test_output << test_result << " \n";
    }
    input.close(); output.close(); test_output.close(); // close files
}

void temp_log_likelihood_ratio_analysis (void)
{
    // DECLARE INPUT, OUTPUT AND VARIABLES
    ifstream input_test ("log.likelihood.ratio");
    ifstream input_coo ("windows.txt");
    string line; float x; int y, z;

    // ESTABLISH CORRESPONDANCE BETWEEN TEST RESULT AND WINDOW COORDINATES
    while(input_test >> x && input_coo >> y >> z) // gets through log likelihood ratio and coordinates at the same time
    {
        cout << x << " log likelihood ratio for the " << y << " to " << z << " window." << endl;
    }
    input_test.close(); input_coo.close(); // close files
}


int main (void)
{
    // SETTING FILE NAMES
    string global_sfs_file, windows_sfs_file;                   // lets user set global and
    cout << "Global SFS file name (with extension)?\n";          // windows SFS file names
    //cin >> global_sfs_file;
    global_sfs_file = "ms.3d.sfs";
    cout << "Local windows SFS file name (with extension)?\n";
    //cin >> windows_sfs_file;
    windows_sfs_file = "ms.3d.windows.sfs";

    // CALCULATE AND STORE SITE PROBABILITIES
    string global_prob_file = "global.derived.site.prob";      // declaring global and windows
    string windows_prob_file = "windows.derived.site.prob";    // site probabilities file names
    calc_proba(global_sfs_file, global_prob_file);      // calculating global and
    calc_proba(windows_sfs_file, windows_prob_file);    // windows site probabilities

    // CALCULATE AND STORE GLOBAL COMPOSITE LIKELIHOOD
    string global_cl_file = "global.cl";                // declaring global composite likelihood file name
    float global_cl = calc_global_cl(global_prob_file, global_cl_file);

    // CALCULATE WINDOWS COMPOSITE LIKELIHOODS AND TEST AGAINST GLOBAL
    string windows_cl_file = "windows.cl";              // declaring windows composite likelihood file name
    calc_windows_cl(windows_prob_file, windows_cl_file, global_cl);

    // TEMPORARY INCORPORATION OF WINDOWS COORDINATES FOR FURTHER ANALYSIS
    temp_log_likelihood_ratio_analysis();

    return 0;
}


/*
TO DO
- Ask if better to use double or float? If double, might want to change exp function and maths functions in general.
- Probabilities > 1?
- Remove the declaration for file name beginning main, so that use chooses.
*/
