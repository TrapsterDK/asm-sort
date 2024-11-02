ehdr:
    .byte 0x7F
    .byte 0x45 # E
    .byte 0x4c # L
    .byte 0x46 # F
    .byte 0x02 # 64 bit ; CLASS
    .byte 0x01 # lsb ; DATA
    .byte 0x01 # ; VERSION
    .byte 0x00 # None/Sytem V ; OS ABI
    .8byte 0x0 # ABI VERSION + PADDING

    .2byte 0x02 # ET_EXEC ; E_TYPE
    .2byte 0x3E # AMD64 ; E_MACHINE
    .4byte 0x01 # 1 ; E_VERSION
    .8byte _start # ; E_ENTRY
    .8byte phdr - ehdr # offset into program header ; E_PHOFF
    .8byte 0x00 # offset into section header ; E_SHOFF
    .4byte 0x00 # flag ; E_FLAGS
    .2byte ehdrsize # ELF header size ; E_EHSIZE
    .2byte phdrsize # Program header size ; E_PHSIZE
    .2byte 0x01 # Number of program headers ; E_PHNUM
    .2byte 0x00 # Section header size ; E_SHENTSIZE
    .2byte 0x00 # Number of section headers ; E_SHNUM
    .2byte 0x00 # Section header string table index ; E_SHSTRNDX

DECLARE_ELF_HEADER_SIZE:
.set ehdrsize,  DECLARE_ELF_HEADER_SIZE - ehdr

phdr:
    .4byte 0x01 # PT_LOAD ; P_TYPE
    .4byte 5 # R-X ; P_FLAGS
    .8byte 0 # located at offset 0??? ; P_OFFSET
    .8byte ehdr # ; P_VADDR
    .8byte ehdr # ; P_PADDR
    .8byte filesize # ; P_FILESIZE
    .8byte filesize # ; P_MEMSZ
    .8byte 0x1000 # P_ALIGN

DECLARE_PHEADER_SIZE:
.set phdrsize, DECLARE_PHEADER_SIZE - phdr

%%MAIN_CODE%%

DECLARE_FILE_SIZE:
.set filesize, DECLARE_FILE_SIZE - ehdr
