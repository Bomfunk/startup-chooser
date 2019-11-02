#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import yaml
import os
from PyQt5.QtWidgets import QWidget, QLabel, QApplication, QVBoxLayout, QHBoxLayout, QCheckBox, QMessageBox, QPushButton
from PyQt5.QtCore import Qt, QTimer

class StartupChooser(QWidget):

  def __init__(self):
    super().__init__()

    self.handleConfig()

    self.initUI()

  def initUI(self):

    vbox = QVBoxLayout(self)
    hbox = QHBoxLayout(self)
    
    info1 = QLabel("\n".join(["Hello!",
              "Please choose what programs you want to run this time."]))
    vbox.addWidget(info1)

    # Creating the checkboxes for each program
    global cbs
    cbs = []
    progs = list(settings["programs"].keys())
    if settings["sort_names"]:
      progs.sort()
    for prog in progs:
      cbs.append(QCheckBox(prog,self))
      cbs[-1].setChecked(not "enabled" in settings["programs"][prog] or settings["programs"][prog]["enabled"])
      vbox.addWidget(cbs[-1])
    
    if settings["timeout"] != 0:
      global tcount
      tcount = settings["timeout"]
      timer = QTimer(self)
      timer.setSingleShot(False)
      timer.timeout.connect(self.countDown)
      timer.start(1000)

    okb = QPushButton("OK", self)
    hbox.addWidget(okb)
    desb = QPushButton("Deselect all", self)
    hbox.addWidget(desb)
    selb = QPushButton("Select all", self)
    hbox.addWidget(selb)

    okb.clicked.connect(self.runstartup)
    desb.clicked.connect(self.deselectAll)
    selb.clicked.connect(self.selectAll)

    vbox.addLayout(hbox)

    self.setLayout(vbox)
    self.setWindowTitle("Startup Chooser")
    self.setWindowFlags(Qt.Tool)
    self.setAttribute(Qt.WA_QuitOnClose)

    self.show()

  def countDown(self):
    global tcount
    tcount-=1
    self.setWindowTitle("Startup Chooser "+str(tcount)+"s left")
    if tcount<1:
      self.runstartup()

  def selectAll(self):
    for cb in cbs:
      cb.setChecked(True)

  def deselectAll(self):
    for cb in cbs:
      cb.setChecked(False)

  # Proceeding with launching the programs
  def runstartup(self):
    for cb in cbs:
      if cb.isChecked():
        if "cmd" in settings["programs"][cb.text()]:
          os.system(settings["programs"][cb.text()]["cmd"]+"&")
    self.close()

  def handleConfig(self):
    global settings
    confdir = os.environ["HOME"] + "/.config"
    confpath = confdir + "/startup-chooser.yaml"

    if os.path.exists(confpath):
      with open(confpath, 'r') as stream:
        settings = yaml.safe_load(stream)
    else:
      # Default settings
      settings = {"timeout": 0,
            "sort_names" : True,
            "programs": {
              "ProgramName1": {"cmd": "/usr/bin/xmessage prog1"},
              "ProgramName2": {"cmd": "/usr/bin/xmessage prog2", "enabled": False},
              "ProgramName3": {"cmd": "/usr/bin/xmessage prog3", "enabled": True}
              }
            }
      if not os.path.exists(confdir):
        os.makedirs(confdir)
      with open(confpath, 'w') as outfile:
        yaml.dump(settings, outfile, default_flow_style=False)

      msgBox = QMessageBox()
      msgBox.setIcon(QMessageBox.Information)
      msgBox.setWindowTitle("Config file was generated")
      msgBox.setText("\n".join(["It looks like this is the first time startup-chooser was launched.",
                    "The configuration file was generated ("+confpath+").",
                    "Please go ahead and change the configuration as you like,",
                    "but keep the Yaml syntax correct."]))
      msgBox.setStandardButtons(QMessageBox.Ok)
      msgBox.exec()

if __name__ == '__main__':

  app = QApplication(sys.argv)
  sc = StartupChooser()
  sys.exit(app.exec_())
