.section .bss
count_array: .space 4*32768

.section .text
.globl _start
_start:
    # assume argument 2 is a file name, without checking

    # open()
    movl $2, %eax
    movq 16(%rsp), %rdi     # second console argument
    xorl %esi, %esi         # O_DONLY
    syscall
    movl %eax, %ebp         # file descriptor

    # don't check if file was opened successfully

    # fstat()
    movl $5, %eax
    movl %ebp, %edi         # file descriptor
    movq %rsp, %rsi         # *statbuf
    syscall
    movq 48(%rsp), %r13     # file size

    # check if file is empty as mmap
    # requries length to be greater than 0
    test %r13, %r13
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
    movq %rax, %r15         # mmap address
    
    # madvice()
    movl $28, %eax
    movq %r15, %rdi         # mmap address
    movq %r13, %rsi         # file size
    movl $2, %edx           # MADV_SEQUENTIAL
    syscall
    
    # brk()
    movl $12, %eax
    xorl %edi, %edi         # 0 (gets current end address)
    syscall
    movq %rax, %r12         # brk address
    addq %r13, %rax         # brk address + file size
    movq %rax, %r14         # new brk end address

    # brk()
    movl $12, %eax
    movq %r14, %rdi         # new brk end address
    syscall

    xorl %eax, %eax         # char holder
    movq %r12, %rbx         # brk current address
_read_number:
    xorl %ecx, %ecx
_read_byte:
    movb (%r15), %al
    
    # check if file end is reached
    test %al, %al
    jz _end_of_file

    incq %r15

    subb $'0', %al          # subtract ascii code '0' to make it an integer
    # if the register is now signed it is because the value
    # was either \t (DEC: 9) or \n (DEC: 10) which both are smaller than '0' (DEC: 30)
    # which are the only non number characters allowed in the input
    # this also means there is no need to check if %al is greater than 9
    js   _seperator

    lea (%rcx, %rcx, 4), %ecx # multiply by 5
    lea (%rax, %rcx, 2), %ecx # multiply by 2, add new number

    jmp  _read_byte

_seperator:
    addb $('0' - '\t'), %al

    movw %cx, (%rbx)
    addq $2, %rbx

    test %al, %al
    jz   _read_number
    
    incl count_array(, %rcx, 4)
    jmp  _read_number

_end_of_file:
    # rax is already 0
    xorl %ebx, %ebx         # count
_count:
    addl count_array(, %rax, 4), %ebx
    movl %ebx, count_array(, %rax, 4)

    # use that max size is 32767 where next value
    # causes an overflow
    incw %ax
    jno  _count

    leal (%r14, %rbx, 4), %edi

    # brk()
    movl $12, %eax
    syscall

    xorl %eax, %eax
    movq %r12, %rcx
    xorl %edx, %edx
    xorl %edi, %edi
_sort:
    cmpl %eax, %ebx
    je   _sorted
    
    movw (%rcx), %dx
    movw 2(%rcx), %di
    decl count_array(, %rdi, 4)
    movl count_array(, %rdi, 4), %esi
    movw %dx, (%r14, %rsi, 4)
    movw %di, 2(%r14, %rsi, 4)

    addq $4, %rcx
    incl %eax
    jmp _sort

_sorted:
    xorl %eax, %eax
    xorl %edx, %edx
    xorl %ecx, %ecx
    movq %r12, %rdi
_buffer:
    cmpl %eax, %ebx
    je   _done

    movw (%r14, %rax, 4), %dx
    leaq int_to_str + 1(, %rdx, 8), %rsi
    movb int_to_str(, %rdx, 8), %cl
    rep movsb

    movb $'\t', (%rdi)
    incq %rdi

    movw 2(%r14, %rax, 4), %dx
    leaq int_to_str + 1(, %rdx, 8), %rsi
    movb int_to_str(, %rdx, 8), %cl
    rep movsb    

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

    # let linux cleanup mmap mapped memory and file descriptors
    # this should allow the program to exit slightly faster
    # munmap()
    # movl $11, %eax
    # movq %r15, %rdi       # mmap address not really in %r15 anymore
    # movq $r13, %rsi       # file size
    # syscall

    # close()
    # movl $3, %eax
    # movl %ebp, %edi       # file descriptor
    # syscall

    # exit()
    movl $60, %eax
    xorl %edi, %edi         # status code 0
    syscall
