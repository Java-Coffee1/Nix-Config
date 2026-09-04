#/bin/bash
declare module_name="mt7921e"

rmmod --verbose "$module_name"

sleep 1

modprobe --verbose "$module_name"

