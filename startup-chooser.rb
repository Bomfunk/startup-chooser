#!/usr/bin/ruby

require 'Qt'

class QtApp < Qt::Widget

	def initialize
		super

		setWindowTitle "Startup manager"

		if File.exists?(ENV['HOME']+'/.startup-chooserrc') then
			@progs = Hash.new("/usr/bin/xmessage unknown program")
			File.open(ENV['HOME']+'/.startup-chooserrc', 'r').each { |line|
				@progs[line.gsub(/^(.*):.*$/, '\1').chomp] = line.gsub(/^.*:(.*)$/, '\1').chomp
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
		count = 0
		@progs.each { |pn,pc|
			count += 1
			cbs << Qt::CheckBox.new(pn, self)
			cbs[count-1].setChecked true
			vbox.addWidget cbs[count-1]
		}

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
			count = 0
			@progs.each { |pn,pc|
				if cbs[count].isChecked then
					system(pc)
				end
				count =+ 1
			}
			$qApp::quit()
		}
		connect(desb, SIGNAL('clicked()')) {
			count = 0
			@progs.each { |pn,pc|
				cbs[count].setChecked false
				count =+ 1
			}
		}
		connect(selb, SIGNAL('clicked()')) {
			count = 0
			@progs.each { |pn,pc|
				cbs[count].setChecked true
				count =+ 1
			}
		}
	end
end

app = Qt::Application.new ARGV
QtApp.new
app.exec
