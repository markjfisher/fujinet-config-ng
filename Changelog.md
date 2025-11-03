# Changelog

## [Unreleased]

## [1.1.2] - 2025-11-03

This is an accumulation of all the changes since 1.0.1 as I forgot to update the changelog.

- Directory Browsing uses caching by default when extended memory is available
- When caching is enabled:
-- Animation for long file names, with configurable "animation speed" for how quickly it updates
-- Show date timestamp and file size
-- Add toggle to use old style browsing (non cached)
- Added date preferences to choose between d/m/y, m/d/y, y/m/d when browsing in cached mode
- Added joystick support
- Fixed screen loading showing random data
- Show bank count on Preferences screen

Directory page caching is a huge new feature to speed up overall directory browsing.
It will remember directory listings you have visited across your current host, until you come
back to the main hosts selection screen, at which point the cache is disgarded.
This allows you to do a simple refresh by re-entering the host site.


## [1.0.1] - 2024-07-14

- Add "Option to boot" message to every module page
- Add "TAB" message to help message when entering wifi password
- Add Changelog.md to track changes in releases

## [1.0.0] - 2024-07-13

- First public release!
