# https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
_elf_header:
    .byte 0x7F, 'E', 'L', 'F'   # magic
    .byte 2                     # 64 bit
    .byte 1                     # lsb
    .byte 1                     # version
    .byte 0x0                   # System V
    .byte 0                     # deprecated
    .byte 0, 0, 0, 0, 0, 0, 0   # padding
    .2byte 2                    # ET_EXEC
    .2byte 0x3E                 # AMD x86-64
    .4byte 1                    # version
    .8byte _start               # start
    .8byte _program_header      # program header
    .8byte 0                    # no section headers
    .4byte 0                    # no flags
    .2byte _elf_header_size     # header size
    .2byte _program_header_size # program header size
    .2byte 1                    # single program header
    .2byte 0                    # no section headers
    .2byte 0                    # no section headers
    .2byte 0                    # no section headers

_elf_header_end:
.set _elf_header_size, _elf_header_end - _elf_header

_program_header_start:
.set _program_header, _program_header_start - _elf_header
    .4byte 0x00000001           # PT_LOAD
    .4byte 0x1 + 0x4            # PF_X | PF_R
    .8byte 0                    # no offset
    .8byte _elf_header          # elf header start
    .8byte _elf_header          # elf header start
    .8byte _file_size           # file image size
    .8byte _file_size           # file memory size
    .8byte 0x1000               # align 4kb

_program_header_end:
.set _program_header_size, _program_header_end - _program_header_start

%%MAIN_CODE%%

_program_end:
.set _file_size, _program_end - _elf_header
