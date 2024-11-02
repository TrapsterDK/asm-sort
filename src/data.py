import sys
import random


def create_random_number_file(filename: str, n: int) -> None:
    with open(filename, "w") as file:
        lines = (
            f"{random.randint(0, 32767)}\t{random.randint(0, 32767)}\n"
            for _ in range(n)
        )
        file.writelines(lines)
    print(f"File '{filename}' created with {n} random entries in x\\ty\\n format.")


if __name__ == "__main__":
    args = sys.argv[1:]
    for i in args:
        create_random_number_file(f"numbers_{i}.txt", int(i))
