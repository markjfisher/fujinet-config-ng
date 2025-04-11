; these are word offsets, save ourselves a LSR and pre-double them
.enum DiskSize
    size90      = 0
    size130     = 2
    size180     = 4
    size360     = 6
    size720     = 8
    size1440    = 10
    sizeCustom  = 12
.endenum

.struct CreateDiskArgs
    host_slot           .byte
    device_slot         .byte
    size_index          .byte ; DiskSize index?
    cust_num_sectors    .word
    cust_size_sectors   .word
    disk_path           .word
.endstruct
