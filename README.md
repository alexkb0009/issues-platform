# ReadMe #

[_My Issues_](https://myissues.us) is a prototypical citizen-centric e-participation platform which aims to enhance the quantity and quality of communication between citizens and their representatives in legislature.

This is the repository of the code which runs it! This readme is a brief overview of implementation details & requirements. Please browse through the repository's _Source_ if you would like to get acquainted with and understand the code a little.

#### Please Note (Code Quality) ####

Most of this platform has been rapidly prototyped in under 4 months (Jan-April 2015), with the primary goal of obtaining feedback on concepts and user experience in order to iterate on platform design. Due to this, much of the code isn't super-ideal for production - for example, there are no proper classes built for the concepts of users, issues, etc., (yet), partly because dictionaries' structure/variables might be more easily adjusted than classes when rapidly prototyping, along w/ structure of corresponding MongoDB doc(s).


### How do I get set up? ###

#### Minimum Requirements ####

To run this platform on a machine, at minimum, Windows or Linux with a Python (3.3+) installation and dependent modules are required, along with access to either a local or remotely-hosted (e.g. through MongoLabs) MongoDB instance. If running on one machine, in your _settings.ini_ file set `sessions_type` to `file` (it will then use the _tmp_data_ directory for storing sessions); if running multiple instances (e.g. in scalable cloud hosting), access to a redis or memcached (untested) instance are required for session storage, setting `sessions_type` appropriately. 

#### Running ####

This is geared to run on OpenShift and thus has a couple of OpenShift-specific files/directory which are not really needed for development  or running on own/local machine. These include:

* .openshift
* requirements.txt
* setup.py
* wsgi.py

The real 'entry-point' is _boot.py_, which initializes and launches the application. It is enough to simply run that file with Python to initialize the application - it is configured to use CherryPy Python server by default when run directly or as service. To run the application locally, on whichever port is configured in your settings.ini, simply type in your command-line: `python boot.py` from the directory _boot.py_ is in. Files such as wsgi.py are run by OpenShift which simply run _boot.py_ but rely on Apache's mod_wsgi instead of CherryPy server.

Though now not particularly recommended, it is possible to install on Windows as a service and then manage it like all others in your _services.msc_. This requires PyWin32. May be installed by running `python installAsWinService.py install` from root directory of application.

#### Python Modules ####

Module dependencies are listed in both the OpenShift-specific _setup.py_ file as well as in _boot.py_. Make sure you have them, install via command-line with pip or easy_install: `pip install <name_of_module>` or `easy_install <name_of_module>`.


### Who do I talk to? ###

* Alex Balashov
    * BitBucket: [alexkb0009](https://bitbucket.org/alexkb0009)
    * alex.balashov@gmail.com
    * alexander.balashov@the-bac.edu
    * http://akb.productions


### Background & Direction of Project ###

My Issues is an online platform which seeks to increase representation of any constituency’s interests to constituency’s legislature by leveraging evolving concepts of user experience (UX) design and collaborative content generation in the field of software development. Ideally, the platform will counter-balance the influence of special-interest lobbyists – many of whom are not direct members of the constituency of the legislator which they are lobbying to. In a dangerous plausible scenario, a lobbyist’s interests might be more closely aligned with interests of a foreign power than with interests of the constituency.

Encroachment on a constituency’s representatives is sometimes evident in the lobbying efforts of resourceful entities. U.S. Representative Tony Cárdenas, in context of discussing the disproportionate influence of Comcast Corporation’s lobbying efforts on legislative decision-making, resolves via a Reddit post that while decision-making based solely on positions presented by lobbyists is rare, “Hearing people who are completely sure of themselves making a case helps me see parts of it I may not have seen before.”[1] Cárdenas also demonstrates a difficulty in identifying preferences of constituencies: “I don't get to be black and white. I have 750,000 shades of greyscale in my district…”[2] Disproportionate representation of interests thus appears to be catalyzed in part by legislators’ lack of access to definite comprehensible information about their constituencies’ preferences.[3] Additionally, much of the population arguably perceives real and imagined hindrances to individual participation in the form of a large & increasing constituent–representative ratio (average of over 738,000-to-1 for U.S. House of Representatives)[4] and depressed availability of time & interest to allocate to civic participation relative to immediate needs[5].

The My Issues platform adapts concepts exemplified in precedent online collaborative and social platforms to transparently aggregate and present constituencies’ preferences regarding relevant issues as well as possible responses to those issues. Reddit’s voting & ranking mechanism informs a similar design in My Issues for aggregating constituent preferences while Wikipedia’s mechanism for iteratively revising an article to reach and maintain consensus of article’s content and structure is adapted for issue definitions. Simple-to-use, rapidly-loading, and engaging user experiences in popular social media platforms such as Twitter and Facebook inform UX design in My Issues and simultaneously serve as conduits for cascading the visibility of the collaboratively-defined issues and consequently, visibility of and participation on the My Issues platform itself. Further work includes iterating on elements of platform design in response to feedback – e.g. mechanism function, UX, ‘branding’ & other details – and implementing alongside already-planned components – e.g. constituent authentication, settings pages.

---------

[1] Cárdenas, Tony, "Proud Today That I Became One of the First House Members Vocally AGAINST Comcast/Time-Warner," Reddit, February 18, 2015, accessed July 4, 2015, https://www.reddit.com/r/technology/comments/2wcoxy/proud_today_that_i_became_one_of_the_first_house/copx5zn.

[2] Ibid.

[3] As well as lack of access by other legislatively influential entities, e.g. politicians, business leaders, media, and other constituents.

[4] The U.S. House of Representatives is limited by law to 435 members, while the overall population of the United States (321,288,000 – on July 14, 2015 at 1:13PM EST) is currently increasing at a rate of one (+1) every twelve seconds.

- “The House Explained,” United States House of Representatives, accessed November 18, 2014, http://www.house.gov/content/learn/.
- “Population Clock,” United States Census Bureau, accessed July 14, 2015, http://www.census.gov/popclock/.

[5] E.g. shopping for groceries & essential products, taking care of & educating children, household maintenance & upkeep.