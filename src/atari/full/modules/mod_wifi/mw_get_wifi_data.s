        .export     _mw_get_wifi_data

        .import     _fuji_error
        .import     _fuji_get_adapter_config_extended
        .import     _mw_init_screen
        .import     mw_adapter_config
        .import     mw_error_fetch_ac
        .import     mw_is_ac_data_fetched
        .import     return0
        .import     return1

        .include    "zp.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "macros.inc"

; int mw_get_wifi_data()
;
; fetches AdapterConfig data if not yet done.
; On an error, it will return 1 and already have zero'd AC data, otherwise returns 0 after setting data in mw_adapter_config
; also stores it in mw_adapter_config

.proc _mw_get_wifi_data
        lda     mw_is_ac_data_fetched
        beq     fetch_ac
        rts

fetch_ac:
        setax   #mw_adapter_config
        jsr     _fuji_get_adapter_config_extended
        jsr     _fuji_error
        bne     fetch_ac_error
        mva     #$01, mw_is_ac_data_fetched
        jmp     return0

fetch_ac_error:
        lda     #$00
        ldx     #.sizeof(AdapterConfigExtended)-1
:       sta     mw_adapter_config, x
        dex
        bpl     :-

        jsr     mw_error_fetch_ac
        jsr     _mw_init_screen
        jmp     return1
.endproc