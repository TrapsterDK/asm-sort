sizes := 10000 50000 100000 1000000 5000000

OBJS = sorter.o
SMALL_OBJS = smallSorter.o

sorter: $(OBJS)
	ld --discard-all --relax --strip-all -o sorter $^
	
smallSorter: $(SMALL_OBJS)
	ld --relax --oformat binary -o smallSorter $^

smallSorterDebug: $(SMALL_OBJS)
	ld --discard-all --relax --strip-all -N -o smallSorterDebug $^
	
smallSorterSize: smallSorter
	du -sh --apparent-size $^
	
smallSorterDump: smallSorterDebug
	objdump -d $^

sorterTime: sorter
	time ./sorter numbers.txt > /dev/null

.PHONY: clean numbers
clean:
	rm -f *.o sorter
numbers:
	for size in 10000 50000 100000 1000000 5000000; do \
		for i in $$(seq 1 $$size); do \
			echo "$$(shuf -i 0-32767 -n 1)\t$$(shuf -i 0-32767 -n 1)"; \
		done > numbers-$$size.txt; \
	done