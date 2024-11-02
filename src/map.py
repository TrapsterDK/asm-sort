if __name__ == "__main__":
    with open("numberMap.s", "w+") as f:
        f.write(
            """
.section .data
.global int_to_str
int_to_str:
"""
        )
        for i in range(32768):
            f.write(
                "   .byte {}, {}\n".format(
                    len(str(i)), ",".join([f"'{c}'" for c in (str(i) + "-------")[:7]])
                )
            )
