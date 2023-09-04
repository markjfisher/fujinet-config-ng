
        .export     devices_fetched
        .export     host_selected
        .export     hosts_fetched
        .export     is_booting
        .export     mf_dir_pos
        .export     mf_selected
        .export     mod_devices
        .export     mod_done
        .export     mod_files
        .export     mod_hosts
        .export     mod_info
        .export     mod_init
        .export     mod_wifi
        .export     setup_fonts
        .export     get_scrloc
        .export     fn_dir_filter
        .export     fn_dir_path
        .export     fn_io_buffer
        .export     fn_io_hostslots


.code

devices_fetched: .res 1
host_selected: .res 1
hosts_fetched: .res 1
is_booting: .res 1
mf_dir_pos: .res 1
mf_selected: .res 1
mod_devices: .res 1
mod_done: .res 1
mod_files: .res 1
mod_hosts: .res 1
mod_info: .res 1
mod_init: .res 1
mod_wifi: .res 1
get_scrloc: .res 1

fn_dir_filter: .res 1
fn_dir_path: .res 1
fn_io_buffer: .res 1
fn_io_hostslots: .res 1


.segment "INIT"
setup_fonts:
        rts
