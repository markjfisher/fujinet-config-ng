        .export     mh_is_hosts_data_fetched
        .export     mh_host_selected

.data

; flag to indicate hosts data is loaded
mh_is_hosts_data_fetched:   .byte 0
; the current host index selected on page
mh_host_selected:           .byte 0
