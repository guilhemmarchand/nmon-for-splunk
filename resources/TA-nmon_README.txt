###################################################
###		NMON for SPLUNK			###
###################################################

Since the Version 1.6.0 of Nmon Splunk, only the TA-nmon is provided as the choice between Python and Perl converter is done automatically
by the nmon2csv.sh wrapper.

If you want to create a custom version of the TA-nmon that will use either Python or Perl converter, follow these instructions:

A Python script utility is provided to allow creating on demand custom TA-nmon packages ready to be deployed, the Python tool allows to: 

Create a new TA-nmon package with the name of your choice
Customize the target index name if required (eg. for example if you use the customization tool to change the default index name
Choose between Python Data Processing, or Perl Data Processing


./create_agent.py 

create_agent.py

This utility had been designed to allow creating customized agents for the Nmon Splunk Application, please follow these instructions:

- Download the current release of Nmon App in Splunk Base: https://apps.splunk.com/app/1753
- Uncompress the create_agent.py.gz script available in resources directory of the Application
- Place the downloaded tgz Archive and this Python tool a temporary directory of your choice
- Run the tool: ./create_agent.py and check for available options
- After the execution, a new agent package will have been created in the resources directory
- Extract its content to your Splunk deployment server, configure the server class, associated clients and deploy the agent
- Don't forget to set the application to restart splunkd after deployment



./create_agent.py -h
usage: create_agent.py [-h] [-f INFILE] [--indexname INDEX_NAME]
                       [--agentname TA_NMON] [--agentmode AGENTMODE]
                       [--version]

optional arguments:
  -h, --help            show this help message and exit
  -f INFILE             Name of the Nmon Splunk APP tgz Archive file
  --indexname INDEX_NAME
                        Customize the Application Index Name (default: nmon)
  --agentname TA_NMON   Define the TA Agent name and root directory
  --agentmode AGENTMODE
                        Define the Data Processing mode, valid values are:
                        python,perl / Default value is python
  --version             show program's version number and exit
  


Example of utilization: Create a custom TA package called "TA-nmon-perl" that will use "myindex" as the App index, and Perl as the Data processing language 

./create_agent.py -f nmon-performance-monitor-for-unix-and-linux-systems_1514.tgz --agentname TA-nmon-perl --agentmode perl --indexname myindex

Extracting tgz Archive: nmon-performance-monitor-for-unix-and-linux-systems_1514.tgz
INFO: Extracting Agent tgz resources Archives
INFO: Renaming TA-nmon default agent to TA-nmon-perl
Achieving files transformation...
Done.
INFO: Customizing any reference to index name in files
INFO: ************* Tar creation done of: TA-nmon-perl.tar.gz *************

*** Agent Creation terminated: To install the agent: ***

 - Upload the tgz Archive TA-nmon-perl.tar.gz to your Splunk deployment server
 - Extract the content of the TA package in $SPLUNK_HOME/etc/deployment-apps/
 - Configure the Application (set splunkd to restart), server class and associated clients to push the new package to your clients

Operation terminated.



############################################################################################################################################################

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

