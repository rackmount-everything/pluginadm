# pluginadm

##### An extremly alpha set of scripts for automatically building and installing applications in SmartOS zones. More documentation to follow.

## Installation

download the repository into `/opt/.pluginadm`

modify the contents of `default.json` to appropriate values for your system

modify the json files in `/opt/.pluginadm/filesystems/` to point the source field to the appropriate datasets on your machine

Optional: Create a xml manifest for svcadm to automatically sym link pluginadm into /opt/local/bin at boot

## Usage

`/opt/.pluginadm/pluginadm <command> [options]`

Use `pluginadm help` to see available commands and options

## Updating

You can update pluginadm with `/opt/.pluginadm/pluginadm update
