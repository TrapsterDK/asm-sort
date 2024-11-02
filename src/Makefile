NUMBERS = 1 10 100 1000 10000 100000 1000000 5000000 10000000
FAST_SORTER = sorter
SMALL_SORTER = smallSorter
NUMBER_MAP = numberMap
SMALL_HEADER = smallHeader
SMALL_SORTER_COMBINED = smallSorterCombined

%.o: %.s
	as -g -o $@ $^

$(SMALL_SORTER_COMBINED).s:
	sed -e '/%%MAIN_CODE%%/{r $(SMALL_SORTER).s' -e 'd}' "$(SMALL_HEADER).s" > "$(SMALL_SORTER_COMBINED).s"
	
$(SMALL_SORTER): $(SMALL_SORTER_COMBINED).s $(SMALL_SORTER_COMBINED).o
	ld --relax --oformat binary -o $(SMALL_SORTER) $(SMALL_SORTER_COMBINED).o

$(FAST_SORTER): $(NUMBER_MAP).o $(FAST_SORTER).o
	ld -g -o $@ $^
	# ld --discard-all --relax --strip-all -o $@ $^
	
$(SMALL_SORTER)Debug: $(SMALL_SORTER).o
	ld --discard-all --relax --strip-all -N -o $(SMALL_SORTER)Debug $(SMALL_SORTER).o

%Size: %
	du -sh --apparent-size $^
	
%Dump: %
	objdump -d $^

%Time: %
	$(foreach n,$(NUMBERS), echo "Timing $(n) numbers" && time ./$^ numbers_$(n).txt > /dev/null;)

%Timer: %
	$(foreach n,$(NUMBERS), echo "Timing $(n) numbers" && python3 timer.py "./$^ numbers_$(n).txt > /dev/null" 10;)

%Timer5: %
	echo "Timing $(n) numbers" && python3 timer.py "./$^ numbers_5000000.txt > /dev/null" 10

%Test: %
	./$^ fixed-numbers.txt

%TestEmpty: %
	./$^ empty-numbers.txt

.PHONY: clean numbers $(SMALL_SORTER_COMBINED).s
clean:
	rm -f *.o smallSorterCombined.s && find . -type f ! -name "*.*"  ! -name "Makefile" -exec rm -f {} +
numbers:
	python3 ./data.py $(NUMBERS)