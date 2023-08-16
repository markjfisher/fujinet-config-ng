; Modules 
.enum Mod
    hosts   ; show the host slots, and allow drilling into them to pick a device to mount
    devices ; show device list from hosts files navigated to
    wifi    ; view/pick wifi
    info    ; show various information about FN, e.g. version, memory, ...?
    done    ; screen to allow user to see exit/boot options etc

    files   ; file selection screen when browsing chosen host
    select_host_slot ; sub page of files that selects the host slot to put selected file into

    ; no real screen associated with next entries, so no need to allocate device specific data to them
    init    ; the initial module to load, runs all module initialisation before moving to appropriate next module, e.g. wifi if no wifi selected, or hosts if there is
    exit    ; this is a marker to exit application
.endenum

.enum KB_HANDLER
    NOT_HANDLED     ; not handled by module, try in global handler
    RELOOP          ; handled by module, start main handler loop again
    EXIT            ; main kb handler should exit
.endenum