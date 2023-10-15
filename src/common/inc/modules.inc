; Modules

; if more modules are defined, also change:
;  run_module
;  mod_highlight_offsets

.enum Mod
    hosts               ; show the host slots, and allow drilling into them to pick a device to mount
    devices             ; show device list from hosts files navigated to
    wifi                ; view/pick wifi
    info                ; show various information about FN, e.g. version, memory, help, ...

    files               ; file selection screen when browsing chosen host

    ; no real screen associated with next entries, so no need to allocate device specific data to them
    init                ; the initial module to load, runs all module initialisation before moving to appropriate next module, e.g. wifi if no wifi selected, or hosts if there is
    boot                ; boot options, either lobby or mount current devices
    exit                ; this is a marker to exit application
.endenum

; Keyboard Handler status codes
.enum KBH
    NOT_HANDLED         ; not handled by module, try in global handler
    RELOOP              ; handled by module, start main handler loop again
    EXIT                ; main kb handler should exit
    ; following allow modules to return different codes that can be act on instead of explicitly exiting
    APP_1               ; app specific code 1, ... not really being used other than an exit
.endenum

; EXIT mod modes
.enum ExitMode
    none                ; make 0 the default no boot option, so we can detect if anyone asked to exit, but didn't set a mode
    boot                ; normal "option" boot
    lobby               ; our friend the LOBBY!
.endenum
