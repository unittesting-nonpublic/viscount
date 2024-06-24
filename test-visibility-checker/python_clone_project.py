import subprocess
import shlex
import signal
import csv
from multiprocessing.pool import ThreadPool

def run_with_timeout(command, timeout):
    # Split the command into individual arguments
    args = shlex.split(command)
    
    # Execute the command in a subprocess
    process = subprocess.Popen(args)

    try:
        # Wait for the process to complete within the timeout period
        process.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        # If the timeout expires, terminate the process
        process.send_signal(signal.SIGKILL)
        process.wait()
        print("TIMEOUT from Python")

def execute_command(command, timeout):
    # Wrap the run_with_timeout function call within a try-except block
    try:
        run_with_timeout(command, timeout)
    except Exception as e:
        print("Error executing command:", e)

# Example usage
bash_script = "bash /Users/firhard/Desktop/test-visibility-checker/clone_project_individually.sh"
project_cut2 ="bash /Users/firhard/Desktop/test-visibility-checker/project_cut.sh" 
project_cut = "bash /Users/firhard/Desktop/test-visibility-checker/project_mvn_test.sh"
timeout_seconds = 24000

# with open('/Users/firhard/Desktop/reports-tmp/zzz_successful_project.csv', 'r') as file:
with open('/Users/firhard/parsingmvnlog/projects.csv', 'r') as file:
    reader = csv.reader(file)
    print(reader)
    # Create a thread pool with a maximum of 5 threads/processes
    pool = ThreadPool(processes=1)
    
    for row in reader:
        # Use the apply_async method to submit the execute_command function
        # with the arguments to the thread pool
        # print(bash_script + " " + row[0])
        # pool.apply_async(execute_command, (bash_script + " " + row[0] + " " + row[1] + " " + row[2], timeout_seconds))
        pool.apply_async(execute_command, (project_cut + " " + row[0], timeout_seconds))
    
    # Close the pool and wait for all processes to complete
    pool.close()
    pool.join()