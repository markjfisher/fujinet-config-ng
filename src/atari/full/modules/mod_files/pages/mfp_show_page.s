        .export     mfp_show_page

.segment "CODE2"

mfp_show_page:
;  store pagegroup we're on
;  ask cache for this pagegroup
;    - check if we have it in cache
;      - if not, request it, and let caching save the data ?? should be part of the library rather than us storing it
;  parse the data for pagegroup from returned memory location for the page
;  display this pages list of files

; when the cursor/selection is on a particular file
;   - <scroll> it to make it visible over whole name - NEED NEW ANIMATION
;   - print its file size and date in the extra line



        rts
