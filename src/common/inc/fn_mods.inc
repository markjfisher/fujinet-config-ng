; Modules 
.enum Mod
    hosts   ; show the host slots, and allow drilling into them to pick a device to mount
    devices ; show device list from hosts files navigated to
    wifi    ; view/pick wifi
    info    ; show various information about FN, e.g. version, memory, ...?
    done    ; screen to allow user to see exit/boot options etc

    files   ; file selection screen when browsing chosen host

    ; no real screen associated with next entries, so no need to allocate device specific data to them
    init    ; the initial module to load, runs all module initialisation before moving to appropriate next module, e.g. wifi if no wifi selected, or hosts if there is
    exit    ; this is a marker to exit application
.endenum
