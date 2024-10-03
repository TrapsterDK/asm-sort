.globl _start
_start:
    xorl %ebp, %ebp
_count:
    # open file
    movl $2, %eax
    movq 16(%rsp), %rdi
    xorl %esi, %esi
    syscall
    movl %eax, %ebx

    # don't check if file was opened successfully

    # allocate memory
    # sub $12, %rsp

_line:
    xor %r13, %r13
    xor %r14, %r14
    xor %r15, %r15
_scan:
    # read byte
    xorl %eax, %eax
    movl %ebx, %edi
    lea  (%rsp, %r13), %rsi
    xorl %edx, %edx
    incl %edx
    syscall

    test %eax, %eax
    jz   _file_end

    movb (%rsp, %r13), %al
    incq %r13

    subb $'0', %al
    js _other

    # no need to check if greater than 9

    test %r15, %r15
    jz _scan
    
    imul $10, %r14
    add %rax, %r14

    jmp  _scan
_other:
    inc %r15
    
    cmpb $('\t' - '0'), %al
    je _scan

    cmp %ebp, %r14d
    jne _line

    # write to stdout
    xorl %eax, %eax
    incl %eax
    xorl %edi, %edi
    incl %edi
    movq %rsp, %rsi
    movl %r13d, %edx
    syscall
    jmp  _line

_file_end:
    # close file
    movl $3, %eax
    movl %ebx, %edi
    syscall

    incw %bp
    jno _count

    # exit
    movl $60, %eax
    xorl %edi, %edi
    syscall
