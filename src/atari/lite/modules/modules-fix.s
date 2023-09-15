
        .export     md_is_devices_data_fetched
        .export     md_device_selected
        .export     mh_host_selected
        .export     mh_is_hosts_data_fetched
        .export     booting_mode
        .export     mf_dir_pos
        .export     mf_selected
        .export     mod_devices
        .export     mod_exit
        .export     mod_files
        .export     mod_hosts
        .export     mod_info
        .export     mod_wifi
        .export     setup_fonts
        .export     get_scrloc
        .export     fn_dir_filter
        .export     fn_dir_path
        .export     fn_io_buffer
        .export     fn_io_hostslots
        .export     fn_io_netconfig


.code

md_is_devices_data_fetched: .res 1
md_device_selected: .res 1
mh_host_selected: .res 1
mh_is_hosts_data_fetched: .res 1
booting_mode: .res 1
mf_dir_pos: .res 1
mf_selected: .res 1
mod_devices: .res 1
mod_exit: .res 1
mod_files: .res 1
mod_hosts: .res 1
mod_info: .res 1
mod_wifi: .res 1
get_scrloc: .res 1

fn_dir_filter: .res 1
fn_dir_path: .res 1
fn_io_buffer: .res 1
fn_io_hostslots: .res 1
fn_io_netconfig: .res 1


.segment "INIT"
setup_fonts:
        rts
