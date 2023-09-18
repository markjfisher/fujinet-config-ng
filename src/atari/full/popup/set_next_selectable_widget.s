        .export     set_next_selectable_widget

        .import     ss_has_sel
        .import     ss_widget_idx
        .import     type_at_x
        .import     debug

        .include    "popup.inc"

.proc set_next_selectable_widget
        ; first check if this is info popup only
        lda     ss_has_sel
        beq     out

        ldx     ss_widget_idx
add_1:
        inx
get_type:
        jsr     type_at_x               ; get type of x'th popup Item
        cmp     #PopupItemType::finish
        bne     :+
        ldx     #$00
        beq     get_type
:       cmp     #PopupItemType::space
        beq     add_1
        cmp     #PopupItemType::text
        beq     add_1

        stx     ss_widget_idx
out:
        rts
.endproc