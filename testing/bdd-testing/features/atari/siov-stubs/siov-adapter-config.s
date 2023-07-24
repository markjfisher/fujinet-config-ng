; stub SIOV
  .include    "atari.inc"
  .include    "../../../../../src/inc/macros.inc"
  .include    "../../../../../src/atari/io.inc"
  .export     ac

  .segment "SIOSEG"
  .org SIOV
  ; Emulate SIOV call by copying ssid/pass into 

  ; copy test data into struct
  copy_y #11, {t_ssid,y}, {ac+AdapterConfig::ssid, y}
  copy_y #14, {t_hostname,y},    {ac+AdapterConfig::hostname,y}
  copy_y  #2, {t_local_ip,y},    {ac+AdapterConfig::localIP,y}
  copy_y  #2, {t_gateway,y},     {ac+AdapterConfig::gateway,y}
  copy_y  #2, {t_netmask,y},     {ac+AdapterConfig::netmask,y}
  copy_y  #3, {t_dns_ip,y},      {ac+AdapterConfig::dnsIP,y}
  copy_y  #6, {t_mac_address,y}, {ac+AdapterConfig::macAddress,y}
  copy_y  #5, {t_bssid,y},       {ac+AdapterConfig::bssid,y}
  copy_y #14, {t_fn_version,y},  {ac+AdapterConfig::fn_version,y}

  ; copy the test adapterconfig to the caller's buffer.
  mwa DBUFLO, $80  ; copy DBUF pointers into ZP

  ldy #0
: mva {ac, y}, {($80), y}
  iny
  cpy #.sizeof(AdapterConfig)-1
  bne :-

  rts

; locations for test to set values
t_ssid:        .byte "ssid name!!"
t_hostname:    .byte "the 'hostname'"
t_local_ip:    .byte "ip"
t_gateway:     .byte "gw"
t_netmask:     .byte "nm"
t_dns_ip:      .byte "dns"
t_mac_address: .byte "macadd"
t_bssid:       .byte "bssid"
t_fn_version:  .byte "version string"

; location to store our stubbed return
ac:            .tag AdapterConfig
