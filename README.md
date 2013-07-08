startup-chooser
=========

A qtruby script to launch at system startup and let you choose what programs to run this time.

This script looks for ~/.startup-chooserrc as a file containing settings.
The lines of the config should be formatted as follows:

    program name 1:command to launch 1
    program name 2:command to launch 2
    ...

You also can use one line to specify timeout in seconds, like "30". If there are several lines with numbers, the script will use the last one. There's no timeout by default.
