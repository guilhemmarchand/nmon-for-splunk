Performance Monitor for Unix and Linux Systems



Copyright 2014 Guilhem Marchand	

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

nmon release 1.5.18

See Releases Notes



bug

Bug to report ? Feature request ? Contact me: guilhem.marchand@gmail.com



people

Looking for Community help ? See:

Questions on Splunk Base: http://answers.splunk.com/answers/app/1753
Join the Google Group: https://groups.google.com/d/forum/nmon-splunk-app

Welcome in Splunk for NMON, Performance Monitor for Unix and Linux Systems

TABLE OF CONTENT


INTRODUCTION

PREREQUISITES

INSTALLATION

STANDARD INSTALLATION

WINDOWS SPECIFIC INSTRUCTIONS

DEPLOYMENT SCENARIOS

SIMPLE DISTRIBUTED ENVIRONMENT

CLUSTER CONFIGURATION

USING CENTRAL SHARES

USING CENTRAL SHARES IN CLUSTER ENVIRONMENT WITH FORWARDERS

ADVANCED CONFIGURATION

CUSTOMIZE NMON ACCURACY

AIX MAPPING SN WITH PSERIES

CUSTOMIZE SPAN FEATURE

USAGE

NMON COLLECT

NMON PROCESSING

NMON DATA

UPGRADE INSTRUCTIONS

REFERENCE MATERIAL

FAQ

NFS STATISTICS

Debugging the nmon2csv Python converter

Nmon_SplunkApp_Customize.py: Customize the Application

Performance Monitors extraction: Customize Monitors to extract (reduce Data volume and licence costs)

1. INTRODUCTION

NMON is short for Nigel's Performance Monitor and is available on AIX Systems, Solaris (with Sarmon), Linux and now ARM Systems. 
This is a great all in one Performance Monitor tool which provides a very large amount of system performance informations and can be used in different scenarios. 

The classical way to use NMON, running the "nmon" command in terminal, opens a Real time monitoring interface, giving you access to many system informations within a single screen: 

Nmon 

Nmon2 

Beyond this terminal interface, NMON is very often used as a Capacity Planning and Performance tool by running NMON in csv generating mode all along it's run time, for later cold Analyse.

There is very few (or none) solutions to Analyse these data with a global and historical vision (Excel has its limits), fortunately Splunk's power is here and this Application will, i hope, answer to your needs.

Here are some useful links about NMON:

http://nmon.sourceforge.net/pmwiki.php

http://www.ibm.com/developerworks/aix/library/au-analyze_aix

Analysing NMON csv data is not easy because of a very specific format Splunk cannot directly manage. (One big problem stands in the event timestamp identification which is very uncommon and defined by a non timestamp pattern)
This is why i decided to develop this App, based on my own professional experience in Unix systems Capacity Planning, to provide to anyone interested a powerful too to Analyse NMON data with an Enterprise Class Application.
In a few words, here is how the App works:

After installation, the App is ready to be used, out of the Box
Default installation has a file monitor that watches for any new nmon file located in "/opt/splunk/etc/apps/nmon/var/nmon_repository"
When a new file is found by Splunk Archive Processor (such as any monitored file or directory), Splunk will call a third party Python script
The Python script "nmon2csv.py" will translate nmon data into several csv files in "/opt/splunk/etc/apps/nmon/var/csv_repository"
By default, Splunk will watch for this this directory running in "batch" mode, meaning any csv file within this directory will be indexed then deleted (you should not need to keep these files)
Once indexed, NMON Data will be ready to be analysed within any available views

You can verify NMON workflow collecting and indexing by requesting on index with nmon collect/processing sourcetype:

index="nmon" sourcetype="nmon_collect"
And:

index="nmon" sourcetype="nmon_processing" 

The "nmon_collect" sourcetype contains iteration of nmon command launched by Splunk, if you collect NMON performance data in your host. 

The "nmon_processing" sourcetype contains outputs of the nmon2csv.py Python script which converts NMON files to csv files eaten by Splunk. This contains various information about nmon conversion steps (automatically extracted by Splunk when searching for the sourcetype) such as: 

nmon2csv_version: Version of the Python converter
hostname: hostname of the Nmon host being extracted
nbr_lines: Number of lines in the Nmon file
size_in_bytes: Size of the Nmon file
elapsed_in_seconds: Data processing time in seconds
Nmon_version: Version of Nmon binary
Time_of_Nmon_Data: Time of Nmon Data (extracted from the Nmon file)
Date_of_Nmon_Data: Date of Nmon Data (extracted from the Nmon file)
INTERVAL: Interval between 2 Nmon measures
SNAPSHOTS: Total number of Nmon measures
logical_cpus: Logical number of CPUs (extracted from the Nmon file)
virtual_cpus: Virtual number of CPUs (extracted from the Nmon file)
Nmon_ID: ID of the Nmon file composed by DATE:TIME:hostname:SN
Accessing Performance Metrics Raw data will be achieved as follows:

index="nmon" sourcetype="nmon_data" 

Performance Data is identified by it's "type" field and indexed in "nmon" Splunk index, currently here are NMON sections (type field) threaten by the third party script: 

CPU_ALL
DISKBSIZE (Up to 10 sections, 10 x 150 devices)
DISKBUSY (Up to 10 sections, 10 x 150 devices)
DISKREAD (Up to 10 sections, 10 x 150 devices)
DISKWRITE (Up to 10 sections, 10 x 150 devices)
DISKXFER (Up to 10 sections, 10 x 150 devices)
DISKRIO (Up to 10 sections, 10 x 150 devices)
DISKWRIO (Up to 10 sections, 10 x 150 devices)
FILE
IOADAPT
JFSFILE
JFSINODE
LPAR
MEM
MEMNEW
MEMUSE
NET
NETERROR
NETPACKET
NFSSVRV2 / NFSSVRV3 / NFSSVRV4 (Automatically extracted but not collected in default config of nmon_helper.sh)
NFSCLIV2 / NFSCLIV3 / NFSCLIV4 (Automatically extracted but not collected in default config of nmon_helper.sh)
PAGE
PROC
PROCSOL
TOP
UARG


Technical informations about these system metrics and how they are collected are well described in NMON Analyser Documentation:

https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/Power%20Systems/page/nmon_analyser
Sarmon site for Solaris version has also a very nice description of NMON Metrics (with some specifics to Sarmon):

http://www.geckotechnology.com/fr/sarmon

Host Configuration data (AAA and BBB sections of NMON) can be retrieved as follows:

index="nmon" sourcetype="nmon_config" 

Installing NMON (recommended for Linux, optional for Solaris, required for AIX)

Beginning with Version 1.1.8, NMON App (and Forwarder TA-nmon version) comes with Linux and Solaris (sparc and X86) NMON pre-packages versions. 

If the "nmon" binary for Linux or "sadc" binary for Solaris is not found within $PATH, then the App will use prepackages versions. NMON for AIX should be installed in default configuration today, if the nmon binary isn't found in path, an error message will be shown 
You can also (and this recommended for Linux to be sure you have the better NMON version for your distribution) install NMON: 
Installing NMON is out of the scope of this document, here are some links which should help installing NMON for your OS: 

AIX NMON Installation:

http://www.ibm.com/developerworks/aix/library/au-analyze_aix/
LINUX NMON Installation:

For many distributions, NMON shall be available in distrib repository packages (rpm, deb and so on) 
You can also download the last binary for you OS: 
http://nmon.sourceforge.net/pmwiki.php?n=Site.Download
SOLARIS NMON (SARMON) Installation:

Download and installation procedure: 
http://www.geckotechnology.com/fr/sarmon

One great goal of this App is to take huge benefit of Splunk Archive processor system to identify and manage NMON files as it would do with any other standard log file, through a custom archive command stanza 
Splunk call when required the third party script which will convert NMON data in log files Splunk can easily manage. 

Beyond this, NMON data takes great advantage of Splunk intelligence to exploit this large amount of technical data. 
This Application comes as it is, with absolutely no warranty. Still i think and hope you will find this very useful and will answer to your needs. 

Do not hesitate to contact me if you have any further question or comment, any feedback will be greatly appreciated ! 
WARNING and DISCLAIMER:

Depending on your nmon command settings, a huge amount of data may be generated by nmon2csv conversion script, don't expect to manage thousands of servers with a free Splunk licence. 


2. PREREQUISITES
Here are requirements for successfully install and use Splunk for NMON


- For TA-nmon (Forwarder App): Python 2.x environment: The third party script requires a standard and functional Python 2.x environment


- For Windows OS: Python 2.x environment: The third party script requires a standard and functional Python 2.x environment (see Windows specific instructions)


- NMON installation: Optional but recommended for Linux, optional for Solaris and required for AIX (See section below)


- SPLUNK 6.x: I recommend running at least Splunk 6.x for Forwarders (non working situations have been reported with Splunk 5.x) and Splunk 6.1.x for Indexers and Head Searh nodes



Nothing else is required, this App can be used with a free Splunk licence without any limitation, but as said above remember a very large amount of data may have to be indexed. 

3. INSTALLATION

Installation of the Standard NMON for Splunk App: For standalone instance, indexers and Head Search nodes of a Cluster

NMON Splunk App: This is the "normal" and complete Application, the one you downloaded from Splunk Base, or installed through the Splunk Manager

The "nmon" App contains:


Views, Dashboards and Interfaces to exploit and analyse Performance Data of your AIX / Linux / Solaris Systems

resources for other Topologies: PA-nmon and TA-nmon

Required inputs, scripts and configuration to get and collect local NMON data on the host where the App has been installed

Supported Operating System:


You can download, install and use the NMON App on any kind of System, Windows, Linux, Unix, Mac OS X... 

BUT 

You can ONLY collect local NMON data (performance data for the host that is hosting the App) if your host is running AIX, Solaris or Linux ! 
Therefore, you can use the App with Windows / Mac os X to convert any Nmon file or collect nmon Data from Forwarder hosts running the TA-nmon App. 
For Windows, please see specific instructions in the section above. 

If your are using Universal Forwarders to collect NMON data from various hosts and to send it to your indexer, then this data will be exploitable with any system you've installed the App on. 

TA-nmon and PA-nmon: What is it ?

These are 2 small and specific versions of the standard Application, and are expected to be used as following: 

TA-nmon: This the lightweight version of the NMON App to be installed in Universal Forwarders
PA-nmon: This is the lightweight version of the NMON App to be installed in the master node of a Cluster, then pushed to peer nodes. This is the bundle configuration.

Installation and configuration of these 2 additional App are fully described in the deployment section. 

INSTALLATION:

Under normal circumstances, you should use the Splunk Manager to install (and update) the Application. 

You can do the installation Online (the manager will directly download the package) or download yourself the App and install it with the manager. 

Example with Online installation: 

Install1


Search for the Nmon Splunk App: 

Install2

Once the Application is installed, Please restart Splunk 

After Splunk has been restarted, you have to configure the Application before starting to use it 

Only if your host is an AIX, Linux or Solaris system, then you can collect local Nmon data by activating inputs: 

Settings 

Default installation:

Every NMON data will be indexed into an index called "nmon"
In default configuration, the App watches for nmon file available within the directory "/opt/splunk/etc/apps/nmon/nmon_repository"
If the Nmon local collect is activated (generating Nmon data with the input script nmon_helper.sh), Nmon files in this directory will be automatically purged by each run of the data collect
The directory "/opt/splunk/etc/apps/nmon/spool" will be used as temporary directory by the nmon2csv third party script
The nmon2scv generates csv files within the directory "/opt/splunk/etc/apps/nmon/csv_repository" that will be immediately indexed, and deleted


Additional Monitor:

You can easily add additional NMON files monitors, such as if you want to monitor other nmon files repository (central shares), this is being described in scenario 3 of Deployment Scenarios section. 

Note about indexing CPU cost:


Indexing a very large amount of NMON files (moreover if they are large files, 1 day of measure for example) can generate a temporary high system load. (CPU and I/O essentially) 
This is essentially true if you manage NMON files generated outside of Splunk and centralized in a file server. 

Under normal circumstances (such as NMON data collect through Splunk of the Universal Forwarder), system load is expected to be very trivial. 


Windows

WINDOWS Specific instructions

Windows OS can be used to Convert / Index and Analyse Nmon Performance Data, therefore a few simple manual steps are required: 

Install Python 2.x for Windows 

Download and Install Python 2.x package for Windows from: https://www.python.org/download


inputs.conf and props.conf 

Copy the inputs.conf_forWindows file from default to local/inputs.conf
Copy the props.conf_forWindows file from default to local/props.conf
Restart Splunk (or refresh using the debug URL: http://server:8000/debug/refresh)


4. DEPLOYMENT SCENARIOS

Scenario 1 "Simple Distributed Environment": Splunk indexer And Splunk Forwarders Agents used to collect Nmon data on servers, Forwarder being deployed by a Splunk Deployment server
In this scenario, A single Splunk indexer will collect NMON Metrics data from clients servers using Splunk Forwarders 
Indexers themselves will collect local NMON Data.

Diagram

STEP 1: Activate local Nmon data collect in Splunk indexer




At installation time, activate the input Nmon data collect:


Settings

This can also be set at any time accessing the Settings menu within Nmon application:


Settings_menu


Manually:


- Copy defaults/inputs.conf to local/, edit the file and look for the adapted nmon_collect entry 

Change "disabled = true" to "false", and restart Splunk. 

STEP 2: Enable Receiving input on the Index Server


Configure the Splunk Index Server to receive data, either in the manager: 

Manager -> sending and receiving -> configure receiving -> new 

or via the CLI: 

/opt/splunk/bin/splunk enable listen 9997 

Where 9997 (default) is the receiving port for Splunk Forwarder connections 

STEP 3: Prepare your package to be deployed


First, extract the content of TA-nmon App provided in $SPLUNK/etc/apps/nmon/resources to $SPLUNK_HOME/etc/deployment-apps, example:

cd /opt/splunk/etc/deployment-apps 

tar -xvzf /opt/splunk/etc/apps/nmon/resources/TA-nmon*.tar.gz 

Then, configure the outputs.conf to enable communication between the Forwarder and your Splunk server, example:

edit /opt/splunk/etc/deployment-apps/TA-nmon/local/outputs.conf 

Example of simple configuration:
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = mysplunk-server:9997

[tcpout-server://mysplunk-server:9997]

STEP 4: Activate and Configure the Splunk Deployment server



Configure the Splunk Server to act as a Deployment Server:

In CLI: 

/opt/splunk/bin/splunk enable deploy-server -auth admin 

Configure your serverclass.conf file, the following simple example will filter your hosts based on their hostname, and automatically deploy the TA-nmon App: 

Edit the file "$SPLUNK_HOME/etc/system/local/serverclass.conf" with section: 
[serverClass:linux_hosts]
whitelist.0 = *linux*

[serverClass:solaris_hosts]
whitelist.0 = *solaris*

[serverClass:solaris_hosts:app:TA-nmon]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled

[serverClass:linux_hosts:app:TA-nmon]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled


Restart your Splunk server. 

Go in the "Forwarder Management" page in Splunk Manager (distributed environment)

You should see 2 Applications and Classes: 

Settings1

Settings2

The Splunk server is now ready to act as Deployment server, next steps will concern client installation and initial configuration.


STEP 5: Clients Forwarders Installation and configuration


Note: If forwarders are already installed and connected to your deployment server, you can off course bypass this section 

Steps for Installing/Configuring *nix forwarders:


2.1 Download Splunk Universal Forwarder:

http://www.splunk.com/download/universalforwarder


2.2 Install Forwarder

2.3 Enable boot-start/init script:

Activate the forwarder at boot time: 

/opt/splunkforwarder/bin/splunk enable boot-start 

To start the forwarder: 

/opt/splunkforwarder/bin/splunk start


2.4 Connect the Forwarder to your Server:

On Forwarders: 

On the deployment client, run these CLI commands: 

splunk set deploy-poll <IP_address/hostname>:<management_port> 

splunk restart 

Use the IP_address/hostname and management_port of the deployment server you want the client to connect with. 

For example: 

splunk set deploy-poll deploymentserver.splunk.mycompany.com:8089 

splunk restart



FINAL: Check your clients deployments:


After your restarted the client (upon initial configuration above), wait a few minutes (be patient, this can require time) and if everything is ok you will quickly see the application being deployed within your client. 
Congratulations :-) 

Settings3




Scenario 2 "Cluster Distributed Environment": Each member of Splunk Cluster (master, peers, deployment server and search heads) will be monitored using Nmon, client hosts will have the Forwarder App deployed to collect Nmon data and send them to the Cluster

Basic Cluster

This scenario is a full Cluster and Clients Splunk implementation taking the benefit of Nmon Performance Monitor, things will work as follows:


Please note the following configuration can be adapted to whatever you need or prefer.


You have a functional Splunk cluster running: master node, peers nodes, heads searches and a deployment server

Manually deploy the "PA-nmon" Application to the master node (thus the PA-nmon could be deployed by the deployment server, this introduces more complications than interest)

The master node will deploy the bundle configuration (containing the PA-nmon App) to all of its peer nodes (also known as indexers)

Upon bundle configuration update, each peer node will automatically generate and collect Nmon data to the replicated nmon Index

The deployment server deploys the "TA-nmon" Application to Forwarders (for clients and non peers members of the cluster)

The standard Nmon Application is installed in all search head nodes of the Cluster (but don't generate and collect Nmon data themselves, this is the where the application frontal is being used)

On master node, head search nodes and on the Deployment Server a Splunk Forwarder will be installed (and linked to the Deployment Server) to collect Nmon data of these hosts, and send them to the replicated index

Each piece of the Cluster has Nmon performance data available and searchable, in such a way you will be able to analyse system load of every Cluster members and clients


Additional Notes:

In this configuration scenario, performance data indexing is being achieved by peer nodes only (and so available for all)

When a peer node indexes data, these data will be available and searchable for all the cluster, so performance data on peers node will be achieved with no additional operation (the PA-nmon is ready as it is, you just need to push it from the master)

Because master node, head search nodes and deployment server are not designed to index data themselves, we will install the universal Splunk Forwarder in each non peers node, and deploy the TA-nmon App (as for any standard client)

Every Forwarder will be managed by the Deployment Server, and the TA-nmon App deployed through it


Here we go !!!


For the tutorial purposes, i will assume we have:


A Splunk master node: splunk-master

Peers node: splunk-peer1, splunk-peer2, splunk-peer3

2 search head nodes: splunk-head1, splunk-head2

A Splunk deployment instance: splunk-deployment



STEP 1: Deploy the PA-nmon (bundle configuration) to the master node


Download the NMON Splunk App, extract its content and upload the "PA-nmon" App archive available within "resources" directory. (to /tmp directory for example) 

Then, extract the PA-nmon App to the master-apps directory in the master mode, example: 

cd /opt/splunk/etc/master-apps 

tar -xvzf /tmp/PA-nmon_V*.tar.gz 

STEP 2: Deploy bundle configuration from to the master node to your peer nodes


In master node, Push the configuration to your peers: 

splunk apply cluster-bundle 

splunk show cluster-bundle-status 

After all peers have restarted, you should see a new index replicated within the master dashboard (be patient and wait a few minutes before your can see your new replicated index) : 

Cluster1

STEP 3: Enable Receiving input on each peers node


Configure each peer node to receive data, either in the manager: 

Manager -> sending and receiving -> configure receiving -> new 

or via the CLI: 

/opt/splunk/bin/splunk enable listen 9997 

Where 9997 (default) is the receiving port for Splunk Forwarder connections 


STEP 4: Deployment Server configuration, prepare TA-nmon for deployments


First, extract the content of TA-nmon App provided in $SPLUNK/etc/apps/nmon/resources to $SPLUNK_HOME/etc/deployment-apps in your deployment server, example:

cd /opt/splunk/etc/deployment-apps 

tar -xvzf /opt/splunk/etc/apps/nmon/resources/TA-nmon*.tar.gz 

Then, configure the outputs.conf to enable communication between the Forwarder and peers with redundancy, example:

edit /opt/splunk/etc/deployment-apps/TA-nmon/local/outputs.conf 

Example: A load-balancing configuration with indexer acknowledgment
[tcpout]
defaultGroup=my_LB_peers
		
[tcpout:my_LB_peers]
autoLBFrequency=40
server=splunk-peer1:9997,splunk-peer2:9997,splunk-peer3:9997
useACK=true

STEP 5: Deployment Server configuration, Activate and configure serverclass.conf



Activate the deployment server:

In CLI: 

/opt/splunk/bin/splunk enable deploy-server 

Configure your serverclass.conf file, the following simple example will filter hosts based on hostnames, and automatically deploy the TA-nmon App for "*clients*": 

Edit the file "$SPLUNK_HOME/etc/system/local/serverclass.conf" with section:
[serverClass:cluster-nodes]
whitelist.0 = splunk-*

[serverClass:clients]
whitelist.0 = *clients*

[serverClass:cluster-nodes:app:TA-nmon]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled
		
[serverClass:clients:app:TA-nmon]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled


Restart the deployment server. 

STEP 6: Install the standard NMON Application in all head search nodes to collect Nmon data to the Cluster


As for a normal installation, Install the Application Nmon for Splunk as usual for every search heads node of your cluster. 
Each head search node won't index or collect Nmon data, but you will access to data through these nodes, this is why this is where you need the full App to be installed: 

Example with Online installation: 

Install1


Search for the Nmon Splunk App: 

Install2


Once the Application is installed, Splunk will propose you to set up the App, please set up it now and UNCHECK all boxes: 

NOTE: We deactivate every monitor because we don't want the search head to collect and index data, if we would these data would be available only for this host and not replicated to the Cluster. 
We will use the Forwarder to generate Nmon performance data collect on non peers host (following section) 

Install3 



STEP 7: Install Forwarders on non peer nodes: master node, head search nodes and deployment server


Because we want to collect NMON Performance data on every piece of our Cluster and want this data to be indexed in the Replicated clustered index, we will install the Universal Forwarder on all non peer nodes. 

If you install the standard NMON App on non peer nodes (master, head search and deployment server), NMON performance data for these hosts will be searchable only in this host and not the global clustered index 

If you don't want to be able to analyse system load on non peer nodes, then you can also bypass this section. 

Install and configure Splunk Forwarder on following instances: 

splunk-master (master node)

splunk-head* (head search nodes)

splunk-deloyment (Deployment Server)


Steps for Installing/Configuring *nix forwarders:

2.1 Download Splunk Universal Forwarder:

http://www.splunk.com/download/universalforwarder


2.2 Install Forwarder

2.3 Enable boot-start/init script:

Activate the forwarder at boot time:

As you already have a Splunk instance running on the same machine, you cannot use the enable boot-start command as this would replace managing splunk in rc levels by the splunkforwarder. 
Instead of this and depending on your preference, you can edit:

/etc/init.d/splunk
And Simply add the splunkforwarder instance. 

You may also prefer copying the existing init script, adapting it to the Splunk Forwarder and activating it in required rc levels. (See your OS specific procedure) 

Start the forwarder: 

/opt/splunkforwarder/bin/splunk start 

Because we already have the main Splunk instance running, when prompted, please change the Forwarder splunkd port by an increased number: 

/opt/splunkforwarder/bin/splunk start

Splunk> Needle. Haystack. Found.

Checking prerequisites...
	Checking mgmt port [8089]: already bound
ERROR: The mgmt port [8089] is already bound.  Splunk needs to use this port.
Would you like to change ports? [y/n]: 

Enter a new mgmt port: 8090
Setting mgmt to port: 8090
The server's splunkd port has been changed.
	Checking mgmt port [8090]: open
		Creating: /opt/splunkforwarder/var/run/splunk/appserver/i18n
		Creating: /opt/splunkforwarder/var/run/splunk/appserver/modules/static/css
		Creating: /opt/splunkforwarder/var/run/splunk/upload
		Creating: /opt/splunkforwarder/var/spool/splunk
		Creating: /opt/splunkforwarder/var/spool/dirmoncache
		Creating: /opt/splunkforwarder/var/lib/splunk/authDb
		Creating: /opt/splunkforwarder/var/lib/splunk/hashDb
New certs have been generated in '/opt/splunkforwarder/etc/auth'.
	Checking conf files for problems...
	Done
All preliminary checks passed.

Starting splunk server daemon (splunkd)...  
Declared role=universal_forwarder.
Done


2.4 Connect the Forwarder to the Deployment Server:

On Forwarders: 

/opt/splunkforwarder/bin/splunk set deploy-poll splunk-deployment:8089 

/opt/splunkforwarder/bin/splunk restart 

Check the Deployment Manager console, and after a few minutes you will the TA-nmon application being deployed over all Cluster members: 

Deployment_Cluster

Finally, Install Splunk Forwarders for other clients you may have following the same procedure as above (but the port change), you will be done ! Congratulations ! 



FINAL: Access your data


Every member of your Splunk Cluster has now NMON Performance Data being collected, and searchable over all your Cluster! Great!

Cluster_Search1

Cluster_Search2


Scenario 3: Manage NMON Data collected into centralized shares (Applicable for Indexers / Heavy Forwarders / Light Forwarders)
In a scenario where there is no Splunk forwarders installed in servers but there is another process in place which periodically collect Nmon data, all you need is a central share (such as an NFS share) which Splunk indexer has access.


CAUTION: The App won't manage nmon files being currently updated by the nmon binary running, if you give Splunk an access to nmon files on running this will generate duplicated events each time files are updated !

This scenario intends to manage cold nmon files only.


STEP 1: Splunk indexer Nmon metrics local collect


In such a scenario, you will still probably want to have Splunk indexer metrics being collected locally, to do so: 

At installation time, activate the input accorded to your local OS type:


Settings 

This can also be set at any time accessing the Settings menu within Nmon application:


Settings_menu 


Manually:


- Copy defaults/inputs.conf to local/, edit the file and look for the adapted nmon_collect entry 

Change "disabled = true" to "false", and restart Splunk. 


STEP 2: Add an additional monitor that watches for files and directories, and finally convert/index nmon files


So you have a central file server share where Nmon files are being centralized, the better option is probably having it mounted using NFS. 

For the example, we will admit nmon files are being stored in a time stamped directory for each day:

/mnt/NFS-SHARE/nmon-repository/YYYY-MM-DD/*.nmon

All you need is creating a custom monitor for your repository, this can be set using Splunk Web or Manually: 


Using Splunk Web (except for light forwarder):


INFORMATION: I recommend to set the crcSalft setting which will ensure Splunk won't ignore Nmon files with a very small size, or data too much similar. 
This cannot be done with the manager and me be set manually (can be added in the inputs.conf file after the operation above) 

crcSalt = <SOURCE>


custom_repo_splunkweb1 

custom_repo_splunkweb2 

custom_repo_splunkweb3 

custom_repo_splunkweb4 

custom_repo_splunkweb5 

Manually:


Create "$SPLUNK_HOME/etc/apps/nmon/local/inputs.conf" with the following configuration: 

[monitor:///mnt/NFS-SHARE/nmon-repository/*/*nmon]
		
disabled = false
index = nmon
sourcetype = nmon_processing
crcSalt = <SOURCE>


Then restart Splunk. (or refresh the configuration using the debug URL: http://myserver:8000/debug/refresh) 

Depending on the number of files and directory, Splunk may requires some times before beginning to start files conversion and indexing. 

NOTE: Keep in mind that if many files are present, an heavy and long process of conversion and indexing data will have to done, which can also result in a licence violation because a massive indexing operation. (thus that's not necessary a problem) 

Scenario 4: Manage NMON Data collected into centralized shares in a Splunk Cluster environment, using Forwarders to convert and stream Nmon Data
This deployment scenario intends to manage Nmon in central shares in a Splunk cluster environment, a Splunk Forwarder instance (either light or heavy) will be used to convert and stream the nmon data to the Splunk cluster.


CAUTION: The App won't manage nmon files being currently updated by the nmon binary running, if you give Splunk an access to nmon files on running this will generate duplicated events each time files are updated !

This scenario intends to manage cold nmon files only.


STEP 1: Deploy the PA-nmon (bundle configuration) to the master node


Download the NMON Splunk App, extract its content and upload the "PA-nmon" App archive available within "resources" directory. (to /tmp directory for example) 

Then, extract the PA-nmon App to the master-apps directory in the master mode, example: 

cd /opt/splunk/etc/master-apps 

tar -xvzf /tmp/PA-nmon_V*.tar.gz 

INFORMATION: By default, the PA-nmon will generate local nmon data for peer nodes, if you don't want to get performance data using the App, you can deactivate this feature as follows: 

Create a local inputs.conf which will disable the nmon_helper.sh input script: 

$SPLUNK_HOME/etc/master-apps/PA-nmon/local/inputs.conf

[script://./bin/nmon_helper.sh]
disabled = true

STEP 2: Deploy bundle configuration from to the master node to your peer nodes


In master node, Push the configuration to your peers: 

splunk apply cluster-bundle 

splunk show cluster-bundle-status 

After all peers have restarted, you should see a new index replicated within the master dashboard (be patient and wait a few minutes before your can see your new replicated index) : 

Cluster1

STEP 3: Enable Receiving input on each peers node


Configure each peer node to receive data, either in the manager: 

Manager -> sending and receiving -> configure receiving -> new 

or via the CLI: 

/opt/splunk/bin/splunk enable listen 9997 

Where 9997 (default) is the receiving port for Splunk Forwarder connections 

STEP 4: Install the TA-nmon in your Forwarder and configure the custom input


For the example, we will assume a manual installation of the TA-nmon App, and we will assume the Forwarder is already connected to the cluster (outputs.conf) 
If you intend to deploy the TA-nmon App using the deployment manager, or have to configure the connection with the cluster, please refer to scenarios 1 and 2. 

Upload the "TA-nmon" App archive available within "resources" directory to your Splunk Forwarder (light or heavy). (to /tmp directory for example) 

Then, extract the TA-nmon App in the Splunk application directory, example with a light forwarder: 

cd /opt/splunkforwarder/etc/apps 

tar -xvzf /tmp/TA-nmon_V*.tar.gz 

INFORMATION: By default, the TA-nmon will generate local nmon data for the host running the App, if you don't want to get performance data, you can deactivate this feature as follows: 

Create a local inputs.conf which will disable the nmon_helper.sh input script: 

$SPLUNK_HOME/etc/master-apps/TA-nmon/local/inputs.conf

[script://./bin/nmon_helper.sh]
disabled = true

Adding a custom Nmon input for your central share is very easy, here is an example: 

Create "$SPLUNK_HOME/etc/apps/nmon/local/inputs.conf" with the following configuration: 

[monitor:///mnt/NFS-SHARE/nmon-repository/*/*nmon]
		
disabled = false
index = nmon
sourcetype = nmon_processing
crcSalt = <SOURCE>


Finally, restart the Splunk Forwarder. 

Immediately after restart, the App will begin to proceed to any Nmon file located in the central share, and will start to stream the data to the Splunk Cluster 


5. ADVANCED CONFIGURATION

5.1 Customize NMON Accuracy, Time between performance measures and Number of measures per execution, Volume of data generated per host


Customize the minimal interval between 2 Nmon measures (formerly interval)

When you use NMON Splunk App to generate NMON performance data, the default configuration has a quite accurate configuration with generates performance measures each 10 seconds. 

While this has the advantage of being very accurate, this can also generate a quite large amount of data to be indexed, which implies license indexing and storage cost. 

You may want to tune this in a different configuration to be more compliant with your needs, in the following example we will tune the application to generate performance measures each minutes with a refreshment each 5 minutes. 

Factors of configuration are listed above: 

Polling time of nmon_helper.sh (time in seconds between each execution)

Command line used to run nmon binary by the nmon_helper.sh: interval and occurrence

Additionally the configuration of custom span definitions macro used within interfaces


To customize the configuration to have 1 performance measure by minute, refreshed within Splunk by step of 5 minutes, we would: 

Create our own local/inputs.conf (for standard nmon App, TA-nmon and PA-nmon if required) with a customized polling time:
[script://./bin/nmon_helper.sh]
disabled = false
interval = 300

Modify nmon_helper.sh to have
# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# Default to 10 seconds
interval="60"

# Number of Data refresh occurences, Nmon will refresh data X times
# Default to 6 occurences to provide 1 minute data measure
occurence="5"




5.2 AIX IBM PSeries Environments: Mapping Partitions with PSeries names


If you are planning to manage many partitions in IBM Pseries environment, you will take advantages of mapping lpars (also called micro-partitions) with your PSeries identification hostname. 

This will add a supplementary filter (interfaces, reports...) using the PSeries name, very useful in big environment. 

This can be achieved by adding a csv lookup based on "serialnum" field present in every NMON data section. 

In IBM Pseries environments, this serial number is in fact the PSeries serial number, create a csv lookup adapted to your need and store in SPLUNK_HOME/etc/apps/nmon/lookups, such as: 
PSERIES_NAME,serialnum

PSERIESfoo,xxxxxxxxxxx
PSERIESbar,xxxxxxxxxxx

Create a stanza in "$SPLUNK_HOME/etc/apps/nmon/local/transforms.conf" such as: 
[mylookup]
filename = mylookupfile.csv


Then, copy "props.conf" from default directory to local directory, within the [nmon_data] stanza, add your csv lookup mapping such as:
# mylookup Mapping
lookup_mylookup = mylookup serialnum OUTPUTNEW PSERIES

Restart Splunk (or refresh the configuration using debug URL), once this is done every lpar host will be associated with its PSeries. 
Beyond this point, you are free to modify views to include this information as a new important filter within dropdowns and so on... As always ensure you are working with files located in "local" directory to be upgrade resilient. 
You can off course add many other technical of functional informations depending on your environment to improve the way you exploit your data. 


5.3 Time Interval definition: Custom macros used by App to dynamically define the more accurate span value


*** SINCE VERSION 1.4.4, this step is not required any more, Proceed to this step ONLY if you have data indexed prior to Version 1.4.4 *** 

NMON Splunk App uses an advanced search (eg. macro) to dynamically define the more accurate interval time definition possible within charts. 

Splunk has a charting limit of 1000 points per series, an adapted span value (time interval) has to be defined if we want charts to be more accurate than Splunk automatically affects 

This is why this custom macro is being defined based on analysing Time ranges supplied by users, see:

${SPLUNK_HOME}/etc/apps/nmon/default/macros.conf 

If you have a different minimal time interval than 10 seconds between 2 measures at the lower level, you can customize these macro to adapt them to your data. (as for an example if you generate NMON data with an other process than Splunk) 
Simply copy macros.conf to your local/ directory and issue your modifications, please note a 5 minute time interval macro example if provided within configuration file.



6. USAGE

6.1 NMON Data Collect (using the App to generate nmon files):

You can use the Application to generate nmon files that will be converted and indexed within Splunk, this is called the Data Collect operation. 

The Data Collect is being operated by the input script "nmon_helper.sh" (for nmon / TA-nmon / PA-nmon), its output processing itself is indexed within Splunk: 

index="nmon" sourcetype="nmon_collect" 

You can also access to these information through pre-configured reports: 
reports_collect 

6.2 NMON Data Processing (conversion of Nmon raw data):

Whenever you are using the Application to collect the nmon data (generating nmon files) or only using the App to manage existing nmon files (generated by a third party workflow), Splunk watches for directories (the default repository or custom repositories) and when it finds a files that has not been yet handled, it proceeds to its conversion. 

This is achieved by the nmon2csv converter Python script (nmon2csv.py), its output contains many useful information about the conversion step, it can be retrieved by: 

index="nmon" sourcetype="nmon_processing" 

You can also access to these information through pre-configured reports: 

reports_processing 

The "Application Internal Statistics" interface available from Home page provides a graphical analysis of these data: 

application_internal_stats_processing

6.3 NMON Performance Monitor Data:

Once indexed, the Nmon Performance Data can be easily retrieved: 

index="nmon" sourcetype="nmon_data" 

This is the way all interfaces will access to the Performance Data, the type of Performance Monitor (CPU % usage, % of time busy disk...) can be filtered using the "type" field. 

Fields that are available within Splunk are dependent of the type of Performance monitor, each "type" corresponds to a csv file previously indexed by Splunk. 
These fields are automatically generated during Nmon Processing steps and may differ between Operating Systems. 

For example, to retrieve CPU percentage Usage, use: 

index="nmon" sourcetype="nmon_data" type="CPU_ALL" 




7. UPGRADE INSTRUCTIONS

7.1 Upgrade "nmon" standard Application for Indexers and Head search nodes

Upgrading Splunk for NMON App is easy as for any other Splunk App, just upgrade the App through the manager and you're done. (this can also be done manually but i would recommend using the Manager) 
Restarting Splunk after update is recommended. 

Note that any configuration file located in "local" directory will not be affected by the update procedure. (Splunk standard) 

Therefore, as with any upgrade or update operation, i strongly recommend to have up to date backups before trying any update, moreover on Production systems.


7.2 Upgrade of TA-nmon

When using Splunk Deployment server (see scenario 1), upgrading the TA-nmon Application will be achieved very easily by extracting the new TA-nmon archive version, note that local configuration will never be touched or overwritten

In CLI, go within the deployment directory and extract the new TA-nmon version: (that you uploaded in /tmp for example)

$ cd /opt/splunk/etc/deployment-apps 

$ tar -xvzf /tmp/TA-nmon*.tar.gz 

You can ask Splunk to reload the Deployment Server, It will then start to upgrade any connected client

$ $SPLUNK_HOME/bin/splunk reload deploy-server 


7.3 Upgrade of PA-nmon for Splunk Clusters (bundle configuration to deploy to master node, and then to be pushed to peer nodes)


In CLI, go within the master node and extract the new PA-nmon version: (that you uploaded in /tmp for example)

$ cd /opt/splunk/etc/master-apps 

$ tar -xvzf /tmp/PA-nmon*.tar.gz 

In CLI, Apply the new bundle configuration:

$ splunk apply cluster-bundle 

$ splunk show cluster-bundle-status 



8. REFERENCE MATERIAL


nmon2csv.py:

Formerly nmon2csv, this is the Python converter which will translate Nmon structured data into data Splunk will index and be able to manage. 
It is automatically Invoked by the Splunk Archive Processor whenever required, and reads data from standard input (stdin). 

This is a Python 2x compatible script which has no external requirement and should run with no issues in any modern enough Operating System. 

nmon_helper.sh:

Third party Shell script to collect NMON data for AIX / Linux / Solaris indexer or forwarder. 
Written in sh, it does not have any specific requirements and should work with any Operating System. 

resources/Nmon_SplunkApp_Customize.py

A Python command line tool to automatically customize the Application to fit your need and criteria: Customizing the index name, App root directory, TA and PA root directory... 
It can be used over future release to allow easy update, even when adapting the App to your needs is required.
9. FAQ

- NFS Statistics Collect:

Because many Linux distributions have nmon 14g in official repositories, the default configuration of Nmon Collect (nmon_helper.sh) will not collect NFS statistics unless you manually set it. 

The reason is that nmon 14g generates a segmentation fault when trying to access to NFS Statistics in many Linux OS, thus it as been corrected in nmon 14i, it is not currently the provided nmon version in repositories. 

If you want to collect NFS statistics using Splunk: 

NOTE: If you using the Application to convert nmon files generated out of Splunk, NFS Statistics are automatically extracted and indexed, you have nothing to do. 

Ensure your hosts are using nmon 14i version, install it if required

Edit the nmon_helper.sh and add the "-N" switch to the nmon command line

If you are using the TA-nmon, deploy the new TA-nmon configuration (you reload the deploy-server: $SPLUNK_HOME/bin/splunk reload deploy-server)

NFS Statistics will automatically be collected and indexed within Splunk


- Debugging the nmon2csv Python converter:

In case of trouble, you may be interested in debugging nmon2csv Python converter operations. 

This can easily be achieved, either on nmon / TA-nmon / PA-nmon Application: 

Create a temporary location for csv files, such like the normal directory structure of the App, example:

$ mkdir -p /tmp/nmon2csv_debug/etc/apps/nmon 

Have an nmon file ready to test, if you don't have some to get the current copy in $SPLUNK_HOME/etc/apps/nmon/var/nmon_resposity when the Application is running

Initiate conversion steps:

Adapt paths if you want to debug the nmon / TA-nmon / PA-nmon App and the type of Splunk instance (standard, light forwarder, heavy forwarder, peer node...), the following example will reproduce the conversion step for the standard Application: 

$ cd /tmp/nmon2csv_debug 

$ export SPLUNK_HOME="/tmp/nmon2csv_debug" 

$ cat my_file.nmon | /opt/splunk/etc/apps/nmon/bin/nmon2csv.py 

The Python converter will output its processing steps and generate various csv files in csv_repository and config_repository

Note that you can achieve the same operation in the proper normal Splunk directory, but if you do so, you need to stop Splunk before as it would immediately index and delete csv files


- Nmon_SplunkApp_Customize.py: Customize the Application

If for some reason you need to customize the Nmon Splunk Application, A Python command line tool is provided in the resources directory which will help you easily achieving your customizations. 

The Python tool allows to: 

Customize the Appication Index Name (default: nmon)
Customize the Application Root Directory (default: nmon)
Customize the TA NMON Root Directory (default: TA-nmon)
Customize the PA NMON Root Directory (default: PA-nmon)
Customize the local CSV Repository (default:csv_repository)
Customize the local Config Repository (default:config_repository)

Using this tool over releases, you can easily manage your customizations and update the Application as usual. 

./Nmon_SplunkApp_Customize.py

If for some reason you need to customize the Nmon Splunk Application, please follow these instructions:

- Download the current release of Nmon App in Splunk Base: https://apps.splunk.com/app/1753
- Uncompress the Nmon_SplunkApp_Customize.py.gz
- Place the downloaded tgz Archive and this Python tool in the directory of your choice
- Run the tool: ./customize_indexname.py and check for available options

After the execution, the Application (including TA-nmon and PA-nmon in resources) will have been customized are ready to be used


./Nmon_SplunkApp_Customize.py -h

usage: Nmon_SplunkApp_Customize.py [-h] [-f INFILE] [-i INDEX_NAME]
                                   [-r ROOT_DIR] [-a TA_NMON] [-p PA_NMON]
                                   [--csvrepo CSV_REPOSITORY]
                                   [--configrepo CONFIG_REPOSITORY]
                                   [--version]

optional arguments:
  -h, --help            show this help message and exit
  -f INFILE             Name of the Nmon Splunk APP tgz Archive file
  -i INDEX_NAME         Customize the Appication Index Name (default: nmon)
  -r ROOT_DIR           Customize the Application Root Directory (default:
                        nmon)
  -a TA_NMON            Customize the TA NMON Root Directory (default: TA-
                        nmon)
  -p PA_NMON            Customize the PA NMON Root Directory (default: PA-
                        nmon)
  --csvrepo CSV_REPOSITORY
                        Customize the local CSV Repository (default:
                        csv_repository)
  --configrepo CONFIG_REPOSITORY
                        Customize the local Config Repository (default:
                        config_repository)
  --version             show program's version number and exit




Example of utilization: 

./Nmon_SplunkApp_Customize.py -f nmon-performance-monitor-for-unix-and-linux-systems_146.tgz -i my_custom_index -r my_custom_app -a my_custom_ta -p my_custom_pa --csvrepo my_custom_csvrepo --configrepo my_custom_configrepo
Extracting tgz Archive: nmon-performance-monitor-for-unix-and-linux-systems_146.tgz
INFO: Changing the App Root Directory frm default "nmon" to custom "my_custom_app"
Achieving files transformation:
INFO: Customizing any reference to default root directory in files
Achieving files conversion
INFO: Customizing any reference to index name in files
INFO: Customizing indexes.conf
INFO: Customizing csv_repository to my_custom_csvrepo
INFO: Customizing config_repository to my_custom_configrepo
INFO: Removing tgz resources Archives
INFO: Customizing the TA-nmon Root directory from the default TA-nmon to my_custom_ta
INFO: Tar creation done of: my_custom_ta_custom.tar.gz
INFO: Customizing the PA-nmon Root directory from the default PA-nmon to my_custom_pa
INFO: Tar creation done of: my_custom_pa_custom.tar.gz
INFO: Creating the custom nmon_performance_monitor_custom.spl archive in current root directory
INFO: Tar creation done of: nmon_performance_monitor_custom.spl
Operation terminated.




- Customize Performance Monitors to be extracted from Nmon data: Focus on Performance Monitors and reduce the Data volume / Licence cost

There may be cases where you don't want or don't need every Performance monitor to be extracted from Nmon Data. 
For example, you want to focus only on particular Monitors such as CPU usage, or you goal is to drastically reduce the global amount of Data volume, and so reduce the licence cost or storage cost. 

Starting with version 1.4.8 you can easily customize the nmon2csv Python converter to choose exact Nmon sections you want to extract. 

To do so, customize the nmon2csv.py Python converter in the Parameters section: 

#################################################
##      Parameters
#################################################

# Customizations goes here:

# Sections of Performance Monitors with standard dynamic header but no "device" notion that would require the data to be transposed
# You can add or remove any section depending on your needs
static_section = ["LPAR", "CPU_ALL", "FILE", "MEM", "PAGE", "MEMNEW", "MEMUSE", "PROC", "PROCSOL", "VM", "NFSSVRV2",
                  "NFSSVRV3", "NFSSVRV4", "NFSCLIV2", "NFSCLIV3", "NFSCLIV4"]

# This is the TOP section which contains Performance data of top processes
# It has a specific structure and requires specific treatment
top_section = ["TOP"]

# This is the UARG section which contains full command line arguments with some other information such as PID, user, group and so on
# It has a specific structure and requires specific treatment
uarg_section = ["UARG"]

# Sections of Performance Monitors with "device" notion, data needs to be transposed by time to be fully exploitable
# This particular section will check for up to 10 subsection per Performance Monitor
# By default, Nmon create a new subsection (add an increment from 1 to x) per step of 150 devices
# 1500 devices (disks) will be taken in charge in default configuration
dynamic_section1 = ["DISKBUSY", "DISKBSIZE", "DISKREAD", "DISKWRITE", "DISKXFER", "DISKRIO", "DISKWIO"]

# Sections of Performance Monitors with "device" notion, data needs to be transposed by time to be fully exploitable
dynamic_section2 = ["IOADAPT", "NETERROR", "NET", "NETPACKET", "JFSFILE", "JFSINODE"]



And simply adapt sections to your needs, please note: 

To remove every monitor of a subsection, empty every monitor of it
The customization of the Python nmon2csv converter is not upgrade resilient, remember to reapply your change at every update of the Application


AboutSupportFile a BugDocumentationPrivacy Policy© 2005-2014 Splunk Inc. All rights reserved.
