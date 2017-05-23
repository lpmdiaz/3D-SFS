/*
program to parse the CLRT result before plotting
input is the output of pop3Dclrt
*/

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
using namespace std;


// build a 3D index based on the 3 dimensions in input
void index_building (ofstream & output, int dim1, int dim2, int dim3) {
    for (int i = 0; i <= dim1; i++) {
        for (int j = 0; j <= dim2; j++) {
            for (int k = 0; k <= dim3; k++) {
                output << i << " " << j << " " << k << " \n"; } } }
}

// parse a string line to a vector of doubles
void line_to_vector (string line, vector<double> & v) {
    stringstream ssline(line); double d;
    while(ssline >> d)
    {
        v.push_back(d);
    }
}

// parsing values with 3D coordinates
void sfs_parsing (ifstream & index, ofstream & output, vector<double> & v) {

    int i = 0; string line; // declare variables

    // parse each 3D coordinate with the corresponding SFS value
    while (getline(index, line))
    {
        output << line << v[i] << "\n";
        i+=1;
    }
}

// help printout
void info() {
    fprintf(stderr,"Required arguments:\tInput file path\n");
    fprintf(stderr,"\t\t\tOutput file name\n");
    fprintf(stderr,"\t\t\tSize of each population (three integers)\n");
    fprintf(stderr,"Optional argument:\tSpecific window to parse\n");
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
    if (argc < 6) {
        cout << "Error: not enough arguments\n";
        return 0; // terminate
    }

    // SETTING UP FILE NAMES AND VARIABLES
    ifstream sfs_file (argv[1]); // opening input file
    if ( !sfs_file.is_open() ) {        // checking that the file was successfully open
        cout<<"Could not open 3D SFS file\n";
        return 0; // terminate
    }
    string line; // string to store each line of the SFS
    vector<double> v; // vector to store the elements of each line
    ofstream parsed_sfs (argv[2], ios::trunc);

    // CREATING THE 3D SFS INDEX (3D COORDINATES)
    ofstream index ("3D.coordinates", ios::trunc); // temp file to stock 3D coordinates
    istringstream ss1(argv[3]); // convert each input
    istringstream ss2(argv[4]); // population size argument
    istringstream ss3(argv[5]); // to integer
    int pop1; int pop2; int pop3; // population sizes
    if (!(ss1 >> pop1)) { // check that have a size for population 1
        cout << "Invalid number " << argv[3] << " (population 1 size)\n";
        return 0; // terminate
    }
    if (!(ss2 >> pop2)) { // check that have a size for population 2
        cout << "Invalid number " << argv[4] << " (population 2 size)\n";
        return 0; // terminate
    }
    if (!(ss3 >> pop3)) { // check that have a size for population 3
        cout << "Invalid number " << argv[5] << " (population 3 size)\n";
        return 0; // terminate
    }
    index_building(index, pop1, pop2, pop3);
    index.close();

    // PARSING THE 3D SFS
    int window_number;
    if (argc == 7) {
        istringstream ss4(argv[6]); // convert window number argument to integer
        if (!(ss4 >> window_number)) { // check that window number is correct
            cout << "Invalid input " << argv[6] << " (window number)\n";
            return 0; // terminate
        }
    } else {
        window_number = 1; // default window number value (first window)
    }
    int i = 1; // count variable to extract the correct window
    while (getline(sfs_file, line) && i!=window_number) { // store the correct SFS window in string
        i+=1;
    }
    line_to_vector(line, v); // parsing the string in a vector
    ifstream coordinates ("3D.coordinates"); // using the coordinates file as input
    sfs_parsing(coordinates, parsed_sfs, v); // writing SFS values in the indexed output
    cout << "The parsed 3D SFS file contains the window number " << window_number << "\n";

    // CLEANING AND CLOSING FILES
    v.clear();
    sfs_file.close();
    parsed_sfs.close();
    index.close();

    return 0;
}

