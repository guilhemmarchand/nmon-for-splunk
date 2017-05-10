###################################################
###		NMON for SPLUNK			                ###
###################################################

### Technical add-on for Splunk Enterprise ###

### create_agent.py : Create multiple copies of the TA-nmon with different configuration ###

A Python script utility is provided to allow creating on demand custom TA-nmon packages ready to be deployed, the Python tool allows to:

- Create a new TA-nmon package with the name of your choice
- Customize the target index name if required (eg. for example if you use the customization tool to change the default index name
- Choose between Python Data Processing, or Perl Data Processing
- Integrate a specific version of nmon.conf to be deployed on specific hosts of your choice to fit your needs

The create_agent.py script is located in the "resources" directory.

### Using the create_agent.py ###

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
  


Example of utilization: Create a custom TA package called "TA-nmon-qua" that will use "myindex" as the App index

./create_agent.py -f nmon-performance-monitor-for-unix-and-linux-systems_1514.tgz --agentname TA-nmon-qua --indexname myindex

Extracting tgz Archive: nmon-performance-monitor-for-unix-and-linux-systems_1514.tgz
INFO: Extracting Agent tgz resources Archives
INFO: Renaming TA-nmon default agent to TA-nmon-qua
Achieving files transformation...
Done.
INFO: Customizing any reference to index name in files
INFO: ************* Tar creation done of: TA-nmon-qua.tar.gz *************

*** Agent Creation terminated: To install the agent: ***

 - Upload the tgz Archive TA-nmon-qua.tar.gz to your Splunk deployment server
 - Extract the content of the TA package in $SPLUNK_HOME/etc/deployment-apps/
 - Configure the Application (set splunkd to restart), server class and associated clients to push the new package to your clients

Operation terminated.
