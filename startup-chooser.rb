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
			File.open(ENV['HOME']+'/.startup-chooserrc', 'r').each { |line|
				progname,progcommand = line.strip.split(":")
				@progs[progname] = progcommand
				@prognames << progname
			}
		else
			Qt::MessageBox.critical self, "Oops!", "It appears that you don't have a ~/.startup-chooserrc file.\nPlease create it first! The lines should be formatted as follows:\nprogram name 1:command to launch 1\nprogram name 2:command to launch 2\n..."
			exit
		end
		init_ui
		show
	end

	def init_ui
		vbox = Qt::VBoxLayout.new
		hbbox = Qt::HBoxLayout.new
		info1 = Qt::Label.new("Hello!
Please choose what programs do you want to run this time.
Thank you!",self)
		vbox.addWidget info1

		cbs = []
		@prognames.each_index do |i|
			cbs << Qt::CheckBox.new(@prognames[i], self)
			cbs[i].setChecked true
			vbox.addWidget cbs[i]
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

		connect(okb, SIGNAL('clicked()')) {
			@prognames.each_index do |i|
				if cbs[i].isChecked then
					system(@progs[@prognames[i]]+'&')
				end
			end
			$qApp::quit()
		}
		connect(desb, SIGNAL('clicked()')) {
			cbs.each_index do |i|
				cbs[i].setChecked false
			end
		}
		connect(selb, SIGNAL('clicked()')) {
			cbs.each_index do |i|
				cbs[i].setChecked true
			end
		}
	end
end

app = Qt::Application.new ARGV
QtApp.new
app.exec
