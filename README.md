# Installation of VerifAI and Scenic

1. Clone the [VerifAI](https://github.com/BerkeleyLearnVerify/VerifAI) repository and [Scenic](https://github.com/BerkeleyLearnVerify/Scenic) version 2.1.0.
2. Use python 3.8, higher versions of python might produce conflicts within some of the used libraries. 
3. Install both repositories, first Scenic then VerifAI. Go to their folders and run python -m pip install -e (we recommend installing everything in a virtual enviroment)
4. Download [Carla](https://carla.org/) (versions 0.9.12-0.9.15 work) 
5. Set the enviromental variables of carla and its wheel python file.
6. Our experiments use Town06 so make sure you install the additional maps for Carla.
7. Download this repository.

# Running the experiments

1. Activate the virtual environment where Scenic and VerifAI are installed.
2. Open Carla simulator 
3. To run an experiment run the python script falsifier.py with parameters: --model carla --path path/to/scenario eg: --path scenarios-ddas/persistent_attack.scenic --e output_name (to name the file where the falsification table will be stored) --route folder (to create a new folder to save the results of your simulation)

# Additional notes

- Take into account the variable inter_vehicle_distance in the scenario (.scenic file) to specify the setpoint distance, this gives the distance between the vehicles (remember that the distances are measured from the center of mass so in reality the bumper to bumper distance is x - 4.95)
- Remember to change the variable verifaiSampleType in each scenario, our experiments have test bo(Bayesian Optimization)  and ce (Cross Entropy) as of Feb/2025

# Automated Testing and Analysis

## 1. Running Overnight Tests

1.  To run automated overnight tests with randomized initial ego distances and speeds, use the `overnight_test.py` script.
2.  Execute the script: `python overnight_test.py`
3.  This will run 1000 test cases, divided into batches of 5, storing results in the `1000_overnight_test` directory.
4.  Each batch will have its own subdirectory within `1000_overnight_test`.
5.  **Note:** These tests utilize the `scenarios-dddas/persistent_attack.scenic` scenario and randomize the ego vehicle's initial distance and speed.
6.  For phantom brake attack you can use the `scenarios-dddas/phantom_brake_attack.scenic` scenario.

## 2. Parsing Crash Data

1.  After running the overnight tests, use `crash_parse.py` to extract successful crash data.
2.  Run the script with the input and output directories: `python crash_parse.py -i 1000_overnight_test -o 100_overnight_results`
3.  This script will copy all `cex.csv` files (indicating crashes) to the `100_overnight_results` directory, renaming them for clarity.
4.  The `100_overnight_results` folder will contain only the tests where a crash occurred without the ego car being directly involved.

## 3. Visualizing Results with Graphifier

1.  To visualize the distance and speed data from the crash results, use `graphifier.py`.
2.  Run the script with the input directory containing the CSV files: `python graphifier.py -i 100_overnight_results`
3.  This will generate PNG graphs for each CSV file, showing the distance between vehicles and the ego vehicle's speed over time.
4.  Graphs will be saved in a `graphs` subdirectory within `100_overnight_results`.
5.  Each graph will include the initial position of the ego car as a legend title.
6.  The graphs will highlight violations (crashes) where the distance between vehicles falls below a threshold (5 meters).