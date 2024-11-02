import subprocess
import time
import sys


def time_command(command: str, times: int) -> float:
    total_time = 0.0

    for i in range(times):
        start = time.time()
        subprocess.run(command, shell=True)
        end = time.time()

        elapsed = end - start
        total_time += elapsed
        print(f"Run {i + 1}: {elapsed:.6f} seconds")

    average_time = total_time / times
    print(f"Average time per run: {average_time:.6f} seconds")


if __name__ == "__main__":
    args = sys.argv[1:]
    program, n = args[0], args[1]
    time_command(program, int(n))
