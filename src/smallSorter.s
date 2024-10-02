.globl _start
_start:
    # open file
    movq $2, %rax
    movq 16(%rsp), %rdi
    xor  %rsi, %rsi
    syscall
    movq %rax, %rbx

    # don't check if file was opened successfully

    # allocate memory
    subq $12, %rsp

    xor  %r12, %r12
_count:
    # seek start
    movq $8, %rax
    movq %rbx, %rdi
    xor  %rsi, %rsi
    xor  %rdx, %rdx
    syscall

_line:
    xor %r13, %r13
    xor %r14, %r14
_scan_x:
    # read byte
    xor  %rax, %rax
    movq %rbx, %rdi
    lea  (%rsp, %r13), %rsi
    movq $1, %rdx
    syscall

    test %rax, %rax
    jz   _file_end

    movb (%rsp, %r13), %al
    inc  %r13
    cmp  $'\t', %al
    jne  _scan_x

_scan_y:
    # read byte
    xor  %rax, %rax
    movq %rbx, %rdi
    lea  (%rsp, %r13), %rsi
    movq $1, %rdx
    syscall

    movb (%rsp, %r13), %al
    inc  %r13
    subb $'0', %al
    jb _new_line
    cmpb $9, %al
    ja _new_line
    
    imul $10, %r14, %r14
    add %rax, %r14
    
    jmp  _scan_y

_new_line:
    cmp %r12, %r14
    jne _line

    # write to stdout
    movq $1, %rax
    movq $1, %rdi
    movq %rsp, %rsi
    movq %r13, %rdx
    syscall
    jmp  _line

_file_end:
    inc  %r12
    cmp  $32768, %r12
    jl  _count 

    # don't close the file

    # exit
    movq $60, %rax
    xor  %rdi, %rdi
    syscall
