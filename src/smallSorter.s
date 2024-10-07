.globl _start
_start:
    xorq %r12, %r12
_count:
    # asume argument 2 is a file name, without checking

    # open file
    xorl %eax, %eax
    xorb $2, %al
    movq 16(%rsp), %rdi
    xorl %esi, %esi
    syscall
    movl %eax, %ebx

    # don't check if file was opened successfully

    # allocate memory
    # sub $12, %rsp

_line:
    xorl %ebp, %ebp
    xorq %r13, %r13
    xorq %r14, %r14
_scan:
    # read byte
    xorl %eax, %eax
    movl %ebx, %edi
    leaq (%rsp, %rbp), %rsi
    xorl %edx, %edx
    incl %edx
    syscall

    test %eax, %eax
    jz   _file_end

    movb (%rsp, %rbp), %al
    incl %ebp

    subb $'0', %al
    js   _other

    # no need to check if greater than 9

    test %r14, %r14
    jz   _scan
    
    imulq $10, %r13
    addb %al, %r13b

    jmp  _scan
_other:
    incq %r14
    
    addb $('0' - '\t'), %al
    je   _scan

    cmpq %r12, %r13
    jne  _line

    # write to stdout
    # xorl %eax, %eax  # eax is 1 since \t is 9 and \n is 10
    # incl %eax
    movl %eax, %edi # eax is already 1
    #xorl %edi, %edi
    #incl %edi
    movq %rsp, %rsi
    movl %ebp, %edx
    syscall
    jmp  _line

_file_end:
    # close file
    # xorl %eax, %eax # read() returns 0 when end of file
    # xorl %eax, %eax
    xorb $3, %al
    movl %ebx, %edi
    syscall

    incw %r12w
    jno  _count

    # exit
    # xorl %eax, %eax  # close() returns 0 (when closed successfully) 
    xorb $60, %al
    xorl %edi, %edi
    syscall
