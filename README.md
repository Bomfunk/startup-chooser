startup-chooser
=========

A qtruby script to launch at system startup and let you choose what programs to run this time.

The script now only supports configuration file in Yaml format. If not found, it will generate one at ~/.config/startup-chooser.yaml.
The syntax is pretty simple, but you need to keep the indentation (spaces before keys and values) as shown in the example:

    ---
    timeout: 0
    sort_names: true
    programs:
      ProgramName1:
        cmd: "/usr/bin/xmessage prog1"
      ProgramName2:
        cmd: "/usr/bin/xmessage prog2"
        enabled: false
      ProgramName3:
        cmd: "/usr/bin/xmessage prog3"
        enabled: true

The "timeout" setting tells startup-chooser how much seconds it should wait before pressing "OK" automatically. Default is 0, which means timeout is disabled.
The "sort_names" setting lets you automatically sort the program list to be shown by names.
You can also set if you would like a program's checkbox to be enabled or disabled by default - use the "enabled" option for any program.
