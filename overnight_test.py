import os
import subprocess
import time

# Parameters
num_runs = 1000  # Total number of test cases to run
tests_per_run = 5  # Number of tests per batch
base_output_dir = '1000_overnight_test'  # Base directory to store test results
scenic_script = 'scenarios-dddas/persistent_attack.scenic'  # Path to your Scenic script
model = 'carla'  # Model to be used in the experiment

# Create the base directory if it doesn't exist
if not os.path.exists(base_output_dir):
    os.makedirs(base_output_dir)

# Run the tests in batches
for i in range(0, num_runs, tests_per_run):
    # Generate a unique subfolder name for each batch of tests
    batch_num = (i // tests_per_run) + 1
    output_dir = os.path.join(base_output_dir, f'batch_{batch_num}')
    
    # Create the subfolder for the batch
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Construct the command to run the experiment
    command = [
        'python', 'falsifier.py', '--model', model,
        '--path', scenic_script, '--route', output_dir
    ]
    
    # Run the command
    print(f"Running batch {batch_num}...")
    subprocess.run(command)
    time.sleep(1)  # Pause briefly to avoid overloading the system

print("All test cases completed.")
