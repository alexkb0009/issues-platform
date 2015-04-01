# README #

[_My Issues_](https://myissues.us) is a prototypical citizen-centric e-participation platform which aims to enhance the quantity and quality of communication between citizens and their representatives in legislature.

This is the repository of the code which runs it! This readme is a brief overview of implementation details & requirements.


### How do I get set up? ###

#### Minimum Requirements ####

To run this platform on a machine, at minimum, Windows or Linux with a Python (3.3+) installation and dependent modules are required, along with access to either a local or remotely-hosted (e.g. through MongoLabs) MongoDB instance. If running on one machine, in your _settings.ini_ file set `sessions_type` to `cookie`; if running multiple instances (e.g. in scalable cloud hosting), access to a redis or memcached (untested) instance are required for session storage, setting `session_type` appropriately. 

#### Running ####

This is geared to run on OpenShift and thus has a couple of OpenShift-specific files/directory which are not really needed for development  or running on local. These include:

* .openshift
* requirements.txt
* setup.py
* wsgi.py

The real 'entry-point' is _boot.py_, which initializes and launches the application. It is enough to simply run that file to initialize the application - it is configured to use CherryPy Python server by default when run directly or as service. To run the application locally, on whichever port is configured in your settings.ini, simply type in your command-line: `python boot.py` from the directory _boot.py is in. Files such as wsgi.py are run by OpenShift which simply run _boot.py_ but rely on Apache's mod_wsgi instead of CherryPy server.

Though now not particularly recommended, it is possible to install on Windows as a service and then manage it like all others in your _services.msc_. This requires PyWin32. May be installed by running `python installAsWinService.py install` from root directory of application.

#### Python Modules ####

Module dependencies are listed in both the OpenShift-specific _setup.py_ file as well as in _boot.py_. Make sure you have them, install via command-line with pip or easy_install: `pip install <name_of_module>` or `easy_install <name_of_module>`.


### Who do I talk to? ###

* alexkb0009
  * alex.balashov@gmail.com
  * alexander.balashov@the-bac.edu
  * http://akb.productions