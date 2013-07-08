#!/usr/bin/ruby

require 'Qt'

class QtApp < Qt::Widget

	def initialize
		super

		setWindowTitle "Startup manager"
		setWindowFlags Qt::Tool

		if File.exists?(ENV['HOME']+'/.startup-chooserrc') then
			@progs = Hash.new("/usr/bin/xmessage unknown program")
			@prognames = []
			@tseconds = 0
			File.open(ENV['HOME']+'/.startup-chooserrc', 'r').each { |line|
				if line.index(':') then
					progname,progcommand = line.strip.split(":")
					@progs[progname] = progcommand
					@prognames << progname
				else
					@tseconds = line.to_i
				end
			}
		else
			Qt::MessageBox.critical self, "Oops!", "It appears that you don't have a ~/.startup-chooserrc file.\nPlease create it first! The lines should be formatted as follows:\nprogram name 1:command to launch 1\nprogram name 2:command to launch 2\n...\n\nYou also can use one line to specify timeout in seconds, like \"30\".\nThere's no timeout by default."
			exit
		end
		init_ui
		show
	end

	def runstartup
		@prognames.each_index do |i|
			if @cbs[i].isChecked then
				system(@progs[@prognames[i]]+'&')
			end
		end
		$qApp::quit()
	end

	def init_ui
		vbox = Qt::VBoxLayout.new
		hbbox = Qt::HBoxLayout.new
		info1 = Qt::Label.new("Hello!
Please choose what programs do you want to run this time.
Thank you!",self)
		vbox.addWidget info1

		@cbs = []
		@prognames.each_index do |i|
			@cbs << Qt::CheckBox.new(@prognames[i], self)
			@cbs[i].setChecked true
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
		if @tseconds > 0 then
			timer.start(1000)
			tcount = @tseconds
		end

		connect(okb, SIGNAL('clicked()')){runstartup}
		connect(desb, SIGNAL('clicked()')) {
			@cbs.each_index do |i|
				@cbs[i].setChecked false
			end
		}
		connect(selb, SIGNAL('clicked()')) {
			@cbs.each_index do |i|
				@cbs[i].setChecked true
			end
		}
		connect(timer, SIGNAL('timeout()')){
			tcount-=1
			setWindowTitle "Startup manager ("+tcount.to_s+"s left)"
			if tcount<1 then
				runstartup
			end
		}
	end
end

app = Qt::Application.new ARGV
QtApp.new
app.exec
