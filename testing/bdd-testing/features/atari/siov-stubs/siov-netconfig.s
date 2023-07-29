; stub SIOV
  .include    "atari.inc"
  .include    "../../../../../src/inc/macros.inc"
  .include    "../../../../../src/atari/fn_io.inc"

  .segment "SIOSEG"
  .org SIOV
  ; Emulate SIOV call by copying ssid/pass into 
  mwa DBUFLO, $80

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

t_ssid: .byte "yourssid"
t_pass: .byte "password"

nc: .tag NetConfig