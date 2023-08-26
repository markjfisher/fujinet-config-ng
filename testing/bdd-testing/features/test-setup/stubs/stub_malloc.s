        .export     _malloc, _free, next_malloc_addr, last_malloc_addr

        .include    "fn_macros.inc"

; STUB malloc and free to just return constantly growing area so test can get last allocated

; void * malloc(unit16 length)
; this just
.proc _malloc
    axinto  size_request

    ; copy current into last
    mwa     next_malloc_addr, last_malloc_addr
    ; add size into next
    adw     next_malloc_addr, size_request
    ; return last
    setax   last_malloc_addr
    rts
.endproc

.proc _free
    ; we don't care about freeing, tests shouldn't allocate too much.
    rts
.endproc

.data
next_malloc_addr: .addr $c000
last_malloc_addr: .addr $0000
size_request:     .res 2