.section .bss
count_array: .space 4*32768

.section .text
.globl _start
_start:
    # assume argument 2 is a file name, without checking

    # open()
    movl $2, %eax
    movq 16(%rsp), %rdi     # second console argument
    xorl %esi, %esi         # O_RDONLY
    syscall
    # don't check for open() errors
    movl %eax, %ebp         # file descriptor

    # don't check if file was opened successfully

    # fstat()
    movl $5, %eax
    movl %ebp, %edi         # file descriptor
    movq %rsp, %rsi         # statbuf buffer
    syscall
    # don't check for fstat() errors
    movq 48(%rsp), %r13     # file size

    # check if file is empty as mmap
    # requries length to be greater than 0
    testq %r13, %r13
    jz   _done

    # mmap()
    movl $9, %eax
    xorl %edi, %edi         # NULL addr automatic address asignment
    movq %r13, %rsi         # file size
    movl $1, %edx           # PROT_READ
    movq $2, %r10           # MAP_PRIVATE
    movq %rbp, %r8          # file descriptor
    xorq %r9, %r9           # offset
    syscall
    # don't check for mmap() errors
    movq %rax, %r15         # mmap address
    
    # madvice()
    movl $28, %eax
    movq %r15, %rdi         # mmap address
    movq %r13, %rsi         # file size
    movl $2, %edx           # MADV_SEQUENTIAL
    syscall
    # don't check for madvice() errors
    
    # brk()
    movl $12, %eax
    xorl %edi, %edi         # 0 (gets current end address)
    syscall
    # don't check for brk() errors
    movq %rax, %r12         # brk address
    addq %r13, %rax         # brk address + file size
    movq %rax, %r14

    # brk()
    movl $12, %eax
    movq %r14, %rdi         # new brk end address
    syscall
    # don't check for brk() errors

    movq %r12, %rbx         # brk current address
_read_number:
    xorl %ecx, %ecx         # number
_read_byte:
    movzbl (%r15), %eax      # read character
    
    # check if end of file is reached (if read returns 0)
    testb %al, %al
    jz _end_of_file         # end of file

    incq %r15               # move pointer to next character

    subb $'0', %al          # subtract ascii code '0' to make it an integer
    # if the register is now signed it is because the value
    # was either \t (DEC: 9) or \n (DEC: 10) which both are smaller than '0' (DEC: 30)
    # which are the only non number characters allowed in the input
    # this also means there is no need to check if %al is greater than 9
    js   _seperator         # is not a number

    leal (%rcx, %rcx, 4), %ecx   # multiply number by 5
    leal (%rax, %rcx, 2), %ecx   # multiply number by 2, add new number

    jmp  _read_byte

_seperator:
    movw %cx, (%rbx)        # add the number to array of tuples 
    addq $2, %rbx           # increment pointer by word size

    # determine if current number is x or y by checking if the character is \t
    # while taking into account that '0' has already been subtracted
    cmpb $('\t' - '0'), %al
    jz   _read_number       # number is x
    # number now must be y
    
    incl count_array(, %rcx, 4) # increment y in counting array
    jmp  _read_number

_end_of_file:
    # rax is already 0
    xorl %ebx, %ebx         # count

_count:
    addl count_array(, %rax, 4), %ebx   # add to running count
    movl %ebx, count_array(, %rax, 4)   # replace the value in count array

    # use that max size is 32767 where next value causes an overflow
    incw %ax
    jno  _count             # 0 to 32768

    # brk()
    movl $12, %eax
    # make space for the sorted array
    leaq (%r14, %rbx, 4), %rdi # brk end address + sum*4
    syscall
    # don't check for brk() errors

    xorl %eax, %eax         # counter
_sort:
    cmpl %eax, %ebx
    je   _sorted            # iterated entire array
    
    # get x and y from unsorted array
    movw (%r12, %rax, 4), %dx
    movzwl 2(%r12, %rax, 4), %edi
    
    # decrement position for y number and get y position
    decl count_array(, %rdi, 4)
    movl count_array(, %rdi, 4), %esi

    # insert x and y into sorted array
    movw %dx, (%r14, %rsi, 4)
    movw %di, 2(%r14, %rsi, 4)

    incl %eax
    jmp _sort

_sorted:
    xorl %eax, %eax         # counter
    movq %r12, %rdi         # buffer destination

_buffer:
    cmpl %eax, %ebx
    je   _done              # iterated entire array

    # table lookup x then move to buffer
    movzwl (%r14, %rax, 4), %edx
    movzbl int_to_str(, %rdx, 8), %ecx
    leaq int_to_str + 1(, %rdx, 8), %rsi
    rep movsb

    # move \t to buffer
    movb $'\t', (%rdi)
    incq %rdi

    # table lookup y then move to buffer
    movzwl 2(%r14, %rax, 4), %edx
    movzbl int_to_str(, %rdx, 8), %ecx
    leaq int_to_str + 1(, %rdx, 8), %rsi
    rep movsb    

    # move \n to buffer
    movb $'\n', (%rdi)
    incq %rdi

    incl %eax
    jmp  _buffer

_done:
    # write()
    movl $1, %eax
    movl $1, %edi           # stdout
    movq %r12, %rsi         # brk base address
    movq %r13, %rdx         # file size
    syscall
    # don't check for write() errors

    # let linux cleanup mmap mapped memory
    # this should allow the program to exit slightly faster
    # munmap()
    # movl $11, %eax
    # movq %r15, %rdi       # mmap address not really in %r15 anymore
    # movq $r13, %rsi       # file size
    # syscall
    # don't check for munmap() errors

    # let linux cleanup file descriptor
    # close()
    # movl $3, %eax
    # movl %ebp, %edi       # file descriptor
    # syscall
    # don't check for close() errors

    # exit()
    movl $60, %eax
    xorl %edi, %edi         # status code 0
    syscall
