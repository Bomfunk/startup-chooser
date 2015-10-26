#!/usr/bin/ruby

require 'Qt'
require 'yaml'

class QtApp < Qt::Widget

	def initialize
		super

		setWindowTitle "Startup manager"
		setWindowFlags Qt::Tool

		confdir = "#{ENV['HOME']}/.config"
		confpath = "#{confdir}/startup-chooser.yaml"

		if File.exists?(confpath)
			@settings = YAML.load_file(confpath)
		else
			# Default settings
			@settings = {"timeout"=> 0,
						"sort_names" => true,
						"programs"=> {
							"ProgramName1"=> {"cmd"=> "/usr/bin/xmessage prog1"},
							"ProgramName2"=> {"cmd"=> "/usr/bin/xmessage prog2", "enabled"=> false},
							"ProgramName3"=> {"cmd"=> "/usr/bin/xmessage prog3", "enabled"=> true}
							}
						}
			if not Dir.exists?(confdir) then Dir.mkdir(confdir) end
			File.open(confpath, "w") {|f| f.write @settings.to_yaml }
			Qt::MessageBox.information self, "Config file was generated",
										["It looks like this is the first time startup-chooser was launched.",
										"The configuration file was generated (\"#{confpath}\").",
										"Please go ahead and change the configuration as you like,",
										"but keep the Yaml syntax correct."].join("\n")
		end

		init_ui
		show
	end

	# Proceeding with launching the programs
	def runstartup
		@cbs.each do |cb|
			if cb.isChecked and @settings["programs"][cb.text].has_key?("cmd")
				system("#{@settings["programs"][cb.text]["cmd"]}&")
			end
		end
		$qApp::quit()
	end

	def init_ui
		vbox = Qt::VBoxLayout.new
		hbbox = Qt::HBoxLayout.new
		info1 = Qt::Label.new(["Hello!",
					"Please choose what programs do you want to run this time.",
					"Thank you!"].join("\n"),self)
		vbox.addWidget info1

		# Creating the checkboxes for each program
		@cbs = []
		progs = @settings["programs"].keys
		if @settings["sort_names"] then progs.sort! end
		progs.each do |prog|
			@cbs << Qt::CheckBox.new(prog, self)
			@cbs.last.setChecked (not @settings["programs"][prog].has_key?("enabled") or @settings["programs"][prog]["enabled"])
			vbox.addWidget @cbs.last
		end

		okb = Qt::PushButton.new("OK",self)
		okb.resize 80, 30
		hbbox.addWidget okb
		desb = Qt::PushButton.new("Deselect all",self)
		desb.resize 80, 30
		hbbox.addWidget desb
		selb = Qt::PushButton.new("Select all",self)
		selb.resize 80, 30
		hbbox.addWidget selb

		vbox.addLayout hbbox
		setLayout vbox

		timer = Qt::Timer.new
		if @settings["timeout"] > 0
			timer.start(1000)
			tcount = @settings["timeout"]
		end

		connect(okb, SIGNAL('clicked()')){ runstartup } # OK
		connect(desb, SIGNAL('clicked()')) { @cbs.each {|i| i.setChecked false}	} # Deselect all
		connect(selb, SIGNAL('clicked()')) { @cbs.each {|i| i.setChecked true} } # Select all
		# Timer:
		connect(timer, SIGNAL('timeout()')) do
			tcount-=1
			setWindowTitle "Startup manager (#{tcount.to_s}s left)"
			if tcount<1 then runstartup end
		end
	end
end

app = Qt::Application.new ARGV
QtApp.new
app.exec
