#!/usr/bin/env sh

~/.luarocks/bin/love-release -W 32
~/.luarocks/bin/love-release -W 64
~/.luarocks/bin/love-release -D --author slemonide --desc description --email email@email.com -u https://github.com/slemonide/raycast -v 0.1
~/.luarocks/bin/love-release -M --uti public.item
