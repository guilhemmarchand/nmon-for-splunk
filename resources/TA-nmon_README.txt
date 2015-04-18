###################################################
###		NMON for SPLUNK			###
###################################################

TA-nmon for Nmon Splunk Performance Monitor:

In the resources directory is provided 3 packages for your deployment:

- TA-nmon: This is the original package provided since the first version of the App, it uses Python for Nmon data processing (Python 2.7.x is best option but 2.6.x is expected to work with no issue in major cases)

- TA-nmon-python: This is the same package that enforces the use of Python (this is the default anyway, provided to prevent confusion for people)

- TA-nmon-perl: This is the TA-nmon package preset to use Perl for Nmon data processing

Wich TA for my systems ?

In main cases, you will want to use:

AIX: TA-nmon-perl 

--> AIX has not Python interpreter available by default, unless you can deploy a Python (2.7.x) interpreter to all of your hosts, Perl is the best option

Linux: TA-nmon-python

--> Linux distributions always comes with a Python interpreter (at least 2.6.x), most of the time using Python is the best option. (but note that Perl will work in most cases)
Therefore, old distribution may not work as expected, in such a case, fall back to Perl

Solaris: Version dependent

--> For Solaris 10.x : TA-nmon-perl is the best option (Solaris 10.x comes with an old Python interpreter)

--> For Solaris 11: TA-nmon-python is the best option

