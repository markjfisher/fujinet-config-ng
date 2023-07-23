; io_mem.s
;
; buffers etc for io

        .export io_scan, io_buffer

.data

io_scan:    .res 4
io_buffer:  .res $100
