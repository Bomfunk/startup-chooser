#!/usr/bin/ruby

require 'Qt'

class QtApp < Qt::Widget

	def initialize
		super

		setWindowTitle "Startup manager"
		setWindowFlags Qt::Tool

		if File.exists?(ENV['HOME']+'/.startup-chooserrc')
			@progs = Hash.new("/usr/bin/xmessage unknown program")
			@prognames = []
			@tseconds = 0
			File.open(ENV['HOME']+'/.startup-chooserrc', 'r').each do |line|
				if line.index(':')
					progname,progcommand = line.strip.split(":")
					@progs[progname] = progcommand
					@prognames << progname
				else
					@tseconds = line.to_i
				end
			end
		else
			Qt::MessageBox.critical self, "Oops!", ["It appears that you don't have a ~/.startup-chooserrc file.",
										"Please create it first! The lines should be formatted as follows:",
										"program name 1:command to launch 1",
										"program name 2:command to launch 2","...\n",
										"You also can use one line to specify timeout in seconds, like \"30\".",
										"There's no timeout by default."].join("\n")
			exit
		end
		init_ui
		show
	end

	# Proceeding with launching the programs
	def runstartup
		@prognames.each_index do |i|
			if @cbs[i].isChecked
				system(@progs[@prognames[i]]+'&')
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
		@prognames.each_index do |i|
			wcheck=true
			pname=@prognames[i]
			if pname[0] == "-"
				wcheck=false
				pname=pname[1,pname.length]
			end
			@cbs << Qt::CheckBox.new(pname, self)
			@cbs[i].setChecked wcheck
			vbox.addWidget @cbs[i]
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
		if @tseconds > 0
			timer.start(1000)
			tcount = @tseconds
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
