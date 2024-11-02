.global _start
_start:
    xorq %r12, %r12         # set loop counter
_count:
    # assume argument 2 is a file name (without checking)

    # open()
    xorl %eax, %eax
    xorb $2, %al
    movq 16(%rsp), %rdi     # second console argument
    xorl %esi, %esi         # O_DONLY
    syscall
    movl %eax, %ebx         # save file descriptor

    # don't check if file was opened successfully

_line:
    xorl %ebp, %ebp         # set character counter
    xorq %r13, %r13         # set y
    xorq %r14, %r14         # set reached y flag
_scan:
    # read single byte into 12 byte buffer on the stack
    # buffer is 12 because 5 chars for x, 1 for tab, 5 for y and 1 for newline
    # read()
    xorl %eax, %eax
    movl %ebx, %edi         # file descriptor
    leaq (%rsp, %rbp), %rsi # buffer at character counter
    xorl %edx, %edx
    incl %edx               # read count
    syscall

    # check if end of file is reached (if read returns 0)
    test %eax, %eax
    jz   _file_end

    movb (%rsp, %rbp), %al  # load char from buffer at character counter
    # use eax because it is already 1 since read returns the number of bytes read
    # therefore it is not nessecary to clear the upper bits
    # and because subb and addb are one byte shorter for only this register

    incl %ebp               # increment character counter

    subb $'0', %al          # subtract ascii code '0' to make it an integer
    # if the register is now signed it is because the value
    # was either \t (DEC: 9) or \n (DEC: 10) which both are smaller than '0' (DEC: 30)
    # which are the only non number characters allowed in the input
    # this also means there is no need to check if %al is greater than 9
    js   _other

    # the character now must be a number from 0-9
    # now check if the number is part of x or y
    # this is done by checking the reached y flag
    test %r14, %r14
    jz   _scan
    
    imulq $10, %r13         # multiply y by 10
    addq %rax, %r13         # add new number to y

    jmp  _scan
_other:
    # set flag showing we have reached y
    # this is also set if we are done reading y
    # but this will be reset when beginning to read next line
    incq %r14
    
    # subtract \t from the character read
    # while taking into account that '0' has already been subtracted
    addb $('0' - '\t'), %al
    je   _scan              # if the character is \t then continue reading

    # check if line should be printed to stdout by comparing y to loop counter
    cmpq %r12, %r13
    jne  _line

    # write()
    # eax is already 1 since \t (DEC: 9) has been subracted
    # from the character and \n is (DEC: 10)
    movl %eax, %edi         # stdout file descriptor is 1
    movq %rsp, %rsi         # buffer on the stack
    movl %ebp, %edx         # character count
    syscall
    jmp  _line

_file_end:
    # close()
    xorb $3, %al            # eax is already 0 since read() returns 0 when end of file
    movl %ebx, %edi         # file descriptor
    syscall

    # increment as word because max allowed input number is 2^15-1
    # therfore allowing to check for overflow instead of having to compare with 32768
    incw %r12w
    jno  _count

    # exit()
    xorb $60, %al           # eax is already 0 since close() returns 0 when closed successfully 
    xorl %edi, %edi         # status code 0
    syscall
