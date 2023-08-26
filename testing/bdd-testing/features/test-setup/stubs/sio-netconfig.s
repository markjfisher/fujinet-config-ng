; stub SIOV
    .include    "fn_macros.inc"
    .include    "fn_data.inc"
    .include    "fn_io.inc"

  .segment "SIO"
  .org SIOV
  ; Emulate SIOV call by copying ssid/pass into 
  mwa IO_DCB::dbuflo, $80

  ; copy ssid into nc
  ldy #8
: mva {t_ssid, y}, {nc + NetConfig::ssid, y}
  dey
  bpl :-

  ; copy pass into nc
  ldy #8
: mva {t_pass, y}, {nc + NetConfig::password, y}
  dey
  bpl :-

  ; copy NetConfig to buffer
  ldy #.sizeof(NetConfig)-1
: mva {nc, y}, {($80), y}
  dey
  bpl :-

  rts

t_ssid: .byte "yourssid", 0
t_pass: .byte "password", 0

nc: .tag NetConfig