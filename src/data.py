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
    for i in [10_000, 50_000, 100_000, 1_000_000, 5_000_000, 10_000_000, 100_000_000]:
        create_random_number_file(f"numbers_{i}.txt", i)
