.export _main
.export t1
.export t2
.export t3
.export t1_end
.export t2_end
.export t3_end

.export _change_bank
.export _fc_strlen
.export _fc_strncpy
.export _get_bank_base
.export _page_cache_get_pagegroup
.export _page_cache_check_exists
.export _put_s
.export _set_default_bank
.export clear_status_2
.export get_scrloc
.export pushax
.export show_next
.export show_prev
.export size_to_str
.export ts_to_datestr

.import _find_params
.import empty_last_page
.import fake_bank_data
.import fake_cache_entry
.import full_last_page
.import full_not_last_page
.import mfp_pg_buf
.import mf_dir_pg_cnt
.import mf_dir_pos
.import mf_is_eod
.import mfp_show_page
.import show_next_calls
.importzp ptr1
.importzp ptr4

.include "page_cache.inc"

.segment "CODE"

_main:
t1:
        lda     #16
        sta     mf_dir_pg_cnt
        lda     #0
        sta     mf_dir_pos
        sta     mf_dir_pos+1
        sta     mf_is_eod
        sta     show_next_calls

        ldx     #0
copy_page:
        lda     full_last_page,x
        sta     mfp_pg_buf,x
        inx
        cpx     #162
        bne     copy_page

        jsr     mfp_show_page
t1_end:
        lda     #16
        sta     mf_dir_pg_cnt
        lda     #0
        sta     mf_dir_pos
        sta     mf_dir_pos+1
        sta     mf_is_eod
        sta     show_next_calls

        ldx     #0
copy_page2:
        lda     full_not_last_page,x
        sta     mfp_pg_buf,x
        inx
        cpx     #162
        bne     copy_page2

t2:     jsr     mfp_show_page
t2_end:
        lda     #16
        sta     mf_dir_pg_cnt
        lda     #32
        sta     mf_dir_pos
        lda     #0
        sta     mf_dir_pos+1
        sta     mf_is_eod
        sta     show_next_calls

        lda     empty_last_page
        sta     mfp_pg_buf
        lda     empty_last_page+1
        sta     mfp_pg_buf+1

t3:     jsr     mfp_show_page
t3_end:
        rts

_page_cache_get_pagegroup:
clear_status_2:
show_prev:
_put_s:
pushax:
_fc_strncpy:
ts_to_datestr:
size_to_str:
        rts

_page_cache_check_exists:
        lda     #<fake_cache_entry
        sta     _find_params+page_cache_find_params::entry_loc
        lda     #>fake_cache_entry
        sta     _find_params+page_cache_find_params::entry_loc+1
        lda     #0
        rts

_get_bank_base:
        lda     #<fake_bank_data
        ldx     #>fake_bank_data
        rts

_change_bank:
        lda     #0
        rts

_set_default_bank:
        rts

show_next:
        inc     show_next_calls
        rts

get_scrloc:
        lda     #$00
        sta     ptr4
        sta     ptr4+1
        rts

_fc_strlen:
        sta     ptr1
        stx     ptr1+1
        ldy     #0
:       lda     (ptr1),y
        beq     :+
        iny
        bne     :-
:       tya
        rts
