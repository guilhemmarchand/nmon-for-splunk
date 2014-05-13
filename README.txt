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




ReadMe

nmon release 1.1.5

#Welcome in Splunk for NMON, Performance Monitor for Unix and Linux Systems#

##TABLE OF CONTENT##

1. INTRODUCTION
2. PREREQUISITES
3. INSTALLATION
4. DEPLOYMENT SCENARIOS
5. ADVANCED CONFIGURATION
6. USAGE
7. UPGRADE INSTRUCTIONS
8. REFERENCE MATERIAL



#1. INTRODUCTION#

>NMON stands for Nigel's Performance Monitor and is available on AIX Systems, Solaris (with Sarmon), Linux and now ARM Systems. 
This is a great all in one Performance Monitor tool that gives a large amount of system performance informations and can be used in different scenarios. 

It first can be used for Realtime monitoring within a terminal by simply issuing the "nmon" command, giving you access to many system informations within a single screen.

 ![](f0227e06-d37d-11e3-8fa9-02b791857185.png)

Beyond RealTime Analysis, NMON is very often used as a Capacity Planning tool by running NMON in csv generating mode all along it's run time, for later cold Analyse.

There is very few (or none) solutions to Analyse these data with a global and historical vision (Excel has its limits), fortunately Splunk's power is here and this Application will, i hope, answer to your needs.




##Here are some useful links about NMON:##

<http://nmon.sourceforge.net/pmwiki.php>

<http://www.ibm.com/developerworks/aix/library/au-analyze_aix>

Analysing NMON csv data is not easy because of a very specific format Splunk cannot directly manage. (One big problem stands in the event timestamp identification which is very uncommon and defined by a non timestamp pattern)

This is why i decided to develop this App, based on my own professional experience in Unix systems Capacity Planning, to provide to anyone interested a powerful too to Analyse NMON data with an Enterprise Class Application.

##In a few words, here is how the App works:##

- After installation, the App is ready to be used, out of the Box
- Default installation has a file monitor that watches for any new nmon file located in "/opt/splunk/etc/apps/nmon/var/nmon_repository"
- When a new file is found by Splunk Archive Processor (such as any monitored file or directory), Splunk will call a third party perl script
- The perl script "nmon2csv" will translate nmon data into several csv files in "/opt/splunk/etc/apps/nmon/var/csv_repository"
- By default, Splunk will watch for this this directory running in "batch" mode, meaning any csv file within this directory will be indexed then deleted (you should not need to keep these files)
- Once indexed, NMON Data will be ready to be analysed within any available views

You can verify NMON workflow indexing by requesting on index with nmon processing sourcetype:

		index="nmon" sourcetype="nmon_processing" 

This will output the NMON file processing timestamp that has been threaten by Splunk. (identified by standard "source" field) 
The real data itself will be identified by it's "type" field and indexed in "nmon" Splunk index, currently here are NMON sections (type field) threaten by the third party script:
 
- CPU_ALL
- DISKBSIZE
- DISKBUSY
- DISKREAD
- DISKWRITE
- DISKXFER
- FILE
- IOADAPT
- LPAR
- MEM
- MEMNEW
- MEMUSE
- NET
- NETERROR
- NETPACKET
- PAGE
- PROC
- PROCSOL
- TOP

##Accessing Raw data will be achieved as follows:##

		index="nmon" sourcetype="nmon_data"

##Technical informations about these system metrics and how they are collected are well described in NMON Analyser Documentation:##

<https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/Power%20Systems/page/nmon_analyser>

Sarmon site for Solaris version has also a very nice description of NMON Metrics (with some specifics to Sarmon):

<http://www.geckotechnology.com/fr/sarmon>


##Host Configuration data (AAA and BBB sections of NMON) can be retrieved as follows:##

		index="nmon" sourcetype="nmon_config"


##Installing NMON##

Installing NMON is out of the scope of this document, here are some links which should help installing NMON for your OS: 

###AIX NMON Installation:###

<http://www.ibm.com/developerworks/aix/library/au-analyze_aix/>

###LINUX NMON Installation:###

For many distributions, NMON shall be available in distrib repository packages (rpm, deb and so on) 
You can also download the last binary for you OS: 

<http://nmon.sourceforge.net/pmwiki.php?n=Site.Download>

###SOLARIS NMON (SARMON) Installation:###

Download and installation procedure: 

<http://www.geckotechnology.com/fr/sarmon>

One great goal of this App is to take huge benefit of Splunk Archive processor system to identify and manage NMON files as it would do with any other standard log file, through a custom archive command stanza 
Splunk call when required the third party script which will convert NMON data in log files Splunk can easily manage. 

Beyond this, NMON data takes great advantage of Splunk intelligence to exploit this large amount of technical data. 
This Application comes as it is, with absolutely no warranty. Still i think and hope you will find this very very useful and will answer to your need. 

Do not hesitate to contact me if you have any further question or comment, any feedback will be greatly appreciated ! 

##WARNING and DISCLAIMER:##

Depending on your nmon command settings, a huge amount of data may be generated by nmon2csv conversion script, don't expect to manage thousands of servers with a free Splunk licence. 



#2. PREREQUISITES#

##Here are requirements for successfully install and use Splunk for NMON##

###The Splunk Web Framework Toolkit, freely available###

<http://apps.splunk.com/app/1613>

###PERL environment: The third party script required a standard and functional perl environment, thus no additional library are required###

###NMON installation: Only if you intend to collect NMON data using Splunk (see sections below)###

Nothing else is required, this App can be used with a free Splunk licence without any limitation, but as said above remember a very large amount of data may have to be indexed. 


#3. INSTALLATION#

##Splunk for NMON installation is very easy to achieve as for any standard Splunk application:##

Under SPlunk Application manager, getting the App online or downloaded as a file from Splunk Base
By directly uncompressing the Archive file content under your Splunk installation directory: $SPLUNK_HOME/etc/apps

Once installed, please restart Splunk to make the App fully available. 

##Default installation:##

- Every NMON data will indexed into an index called "nmon"
- The App watches for nmon file available within the directory "/opt/splunk/etc/apps/nmon/nmon_repository"
- The directory "/opt/splunk/etc/apps/nmon/spool" will be used as temporary directory by the nmon2csv third party script
- The nmon2scv generates csv files within the directory "/opt/splunk/etc/apps/nmon/csv_repository" and immediately indexed and deleted

###INFO: Path above are full path i could not yet adapt them with environment variables, if you have a non standard Splunk Home installation, please copy settings from:###

- props.conf
- inputs.conf

And adapt them to match your Splunk home path

##Additional Monitor:##

You can easily add additional NMON files monitors, therefore please set these monitors in the "local" directory bases on "props.conf" and "inputs.conf" default examples you will find within the App. 

###INFO about conversation and indexing system cost:###

Please keep in mind than converting and indexing NMON files will temporarily have an important impact on local system load if they are very large files. (such as a full day Nmon file)









#4. DEPLOYMENT SCENARIOS#

##Scenario 1 "Distributed Environment": Splunk indexer(s) And Splunk Forwarders Agents used to collect Nmon data on servers##

###In this scenario, Splunk indexer(s) will collect NMON Metrics data from clients servers using Splunk Forwarders. 
Indexers themselves will collect local NMON Data.###

 ![](23d19994-d37e-11e3-ab12-02b791857185.png)

###Step 1: Activate local Nmon data collect in Splunk indexers###

You will probably want to be able to have Usage statistics of Splunk indexer(s) themselves, this can be achieved very simply as follows: 

####At installation time, activate the input accorded to your local OS type:####

 ![](276c10ca-d37e-11e3-8fa9-02b791857185.png)

####This can also be set at any time accessing the Settings menu within Nmon application####

 ![](2a606e8e-d37e-11e3-ab12-02b791857185.png)

####Manually:#### 

		Copy defaults/inputs.conf to local/, edit the file and look for the adapted nmon_collect entry 

Change "disabled = true" to "false", and restart Splunk. 

###Step 2: Enable Receiving input on the Index Server###


Configure the Splunk Index Server to receive data, either in the manager: 
		Manager -> sending and receiving -> configure receiving -> new 

or via the CLI: 
		/opt/splunk/bin/splunk enable listen 9997 

Where 9997 (default) is the receiving port for Splunk Forwarder connections 

###Step 3: Prepare your package to be deployed###

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








###Step 4: Activate and Configure the Splunk Deployment server###


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

 ![](d4c899ea-d631-11e3-a1d0-06ca2297e8bc.png)

 ![](d78a40c0-d631-11e3-a1d0-06ca2297e8bc.png)

The Splunk server is now ready to act as Deployment server, next steps will concern client installation and initial configuration.


###Step 4: Clients Forwarders Installation and configuration###


Note: If forwarders are already installed and connected to your deployment server, you can off course bypass this section 

Steps for Installing/Configuring *nix forwarders:


####2.1 Download Splunk Universal Forwarder:####

<http://www.splunk.com/download/universalforwarder>


####2.2 Install Forwarder####

####2.3 Enable boot-start/init script:####

Activate the forwarder at boot time: 
		/opt/splunkforwarder/bin/splunk enable boot-start 

To start the forwarder: 
		/opt/splunkforwarder/splunk start


####2.4 Connect the Forwarder to your Server:####

On Forwarders: 

On the deployment client, run these CLI commands: 

		splunk set deploy-poll IP_address/hostname:management_port 

		splunk restart 

Use the IP_address/hostname and management_port of the deployment server you want the client to connect with. 

For example:
 
		splunk set deploy-poll deploymentserver.splunk.mycompany.com:8089 

		splunk restart



####FINAL: Check your clients deployments:####


After your restarted the client (upon initial configuration above), wait a few minutes (be patient, this can require time) and if everything is ok you will quickly see the application being deployed within your client. 
Congratulations :-) 

 ![](daac2d72-d631-11e3-9857-06ca2297e8bc.png)



















##Scenario 2: Manage NMON Data collected into centralized shares##

###In a scenario where there is no Splunk forwarders installed in servers but there is another process in place which periodically collect Nmon data, all you need is a central share (such as an NFS share) which Splunk indexer has access.###


####Step 1: Splunk indexer Nmon metrics local collect####


In such a scenario, you will still probably want to have Splunk indexer metrics being collected locally, to do so: 

####At installation time, activate the input accorded to your local OS type:####

 ![](276c10ca-d37e-11e3-8fa9-02b791857185.png)

####This can also be set at any time accessing the Settings menu within Nmon application####

 ![](2a606e8e-d37e-11e3-ab12-02b791857185.png)

####Manually:#### 

		Copy defaults/inputs.conf to local/, edit the file and look for the adapted nmon_collect entry 

Change "disabled = true" to "false", and restart Splunk. 


####Step 2: Add Splunk Monitors####


Then, simply add a monitor that will watch for any new or updated Nmon file and will convert and index Nmon data. 

Copy defaults/inputs.conf and defaults/props.conf to local/, edit each config file to configure your additional monitor. 

Restart Splunk and Nmon collect will start. 



#5. ADVANCED CONFIGURATION#

Splunk for NMON works out the box after installation and does not require additional configuration to manage NMON files, just copy them to "/opt/splunk/etc/apps/nmon/nmon_repository" and files will immediately be managed. 

##Beyond this, you can add as many monitor as you which to threat other NMON files repository (such as an NFS share), achieving this is very simple:##

		Copy "props.conf" and "inputs.con" files to local directory (don't edit files in default directory to be upgrade resilient) and adapt/add sections as described in configuration files.


##IBM PSeries Environments: Mapping Partitions with PSeries names##

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

##Time Interval definition: Custom macros used by App to dynamically define the more accurate span value##


NMON Splunk App uses an advanced search (eg. macro) to dynamically define the more accurate interval time definition possible within charts. 

Splunk has a charting limit of 1000 points per series, an adapted span value (time interval) has to be defined if we want charts to be more accurate than when Splunk sets itself this value 
This is why this custom macro is being defined based on analysing Time ranges supplied by users, see:

		${SPLUNK_HOME}/etc/apps/nmon/default/macros.conf 

If you have a different minimal time interval than 1 minute, you can customize these macro to adapt them to your data. (as for an example if you generate NMON data with an other process than Splunk) 
Simply copy macros.conf to your local/ directory and issue your modifications, please note a 5 minute time interval macro example if provided within configuration file.


#6. USAGE#

##NMON files conversion:##

As soon as NMON files are present in default monitor location or your own, NMON files conversion and Splunk indexing will start. 

NMON conversion treatment can be checked with request over "nmon" index and "nmon_processing" sourcetype, such as: 

		index="nmon" sourcetype="nmon_processing" | stats count by _time,source,md5sum 

source is equivalent to the full path and name of NMON files proceeded.

##Splunk NMON data indexing:##

Once converted, NMON data are generated into multiple csv files. (one file per kind of metric) 
In default configuration these files are located in $SPLUNK_HOME/etc/apps/nmon/var/csv_repository. 

Splunk will immediately index any csv file located within this directory in batch mode, meaning file deletion after being indexed. 
Please note that in a massive NMON data integration operation, this directory size may temporary greatly increase.
Duplicate Events Management and re-indexing Data

Because the Splunk archive processor manages itself NMON files (watch for them as it would any other file instead of running a standalone script input), 
a side effect of this was in first App versions resulting in the third party script being called multiple times by Splunk, and the data to be indexed being generated multiple times. To deal with this, a built-in md5sum feature had been included in the third party script. 

For each copy of an NMON file, an md5sum key is added to the file $SPLUNK_HOME/etc/apps/nmon/var/md5sum_reference.txt. Before generating data, the third party script will check if an md5sum key exists, if it does, the script won't generate any new data. 
The md5sum key / NMON file association can be checked within the nmon index / processing sourcetype. (see above) 

###If you need to re-index NMON data, you can proceed as follows:###

- Stop Splunk
- Delete $SPLUNK_HOME/etc/apps/nmon/var/md5sum_reference.txt
- Delete nmon index (ensure you have backups if required !)
- Verify Splunk has still access to previously proceeded NMON files
- Start index and check indexing process
- Accessing NMON Metrics Raw Data:

Every NMON Metrics are available through the "nmon" index and "nmon_data" sourcetype: 
		
		index=nmon sourcetype=nmon_data any other filters 

For example, Percentage of CPU Usage (known as CPU_ALL in NMON context) Raw data are available in inline search by: 

		index=nmon sourcetype=nmon_data type=CPU_ALL

For information, fields identification within Splunk is automatically achieved using the csv file header generated by the third party script. 

Beyond this, many views will work with computed fields or aggregation of fields and other filters such as time. 
The App Home Page will you give direct access to every content and views available. 


#7. UPGRADE INSTRUCTIONS#


##Upgrade of Splunk Indexer##

Upgrading Splunk for NMON App should be as easy as with any other App, just upgrade the App through the manager and you're done. 

Please note any configuration file located in "local" directory shall not be affected by any update process. 

Therefore, as with any upgrade or update operation, i strongly recommend to have up to date backups before trying any update, moreover on Production systems.


##Upgrade of light Forwarders##

When using Splunk Deployment server (see scenario 1), upgrading the TA-nmon Application will be achieved very easily by extracting the new TA-nmon archive version, note that local configuration will never be touched or overwritten

Upgrade the nmon application on Deployment server

In CLI, go within the deployment directory and extract the new TA-nmon version:

		$ cd /opt/splunk/etc/deployment-apps 

		$ tar -xvzf $HOME_SPLUNK/etc/apps/nmon/TA-nmon*.tar.gz 

You can restart the Splunk Deployment server to force it analysing immediately the new version and automatically deploying it to your clients, or simply wait for it.


#8. REFERENCE MATERIAL#

		nmon2csv.pl:

third party script located in "SPLUNK_HOME/etc/apps/nmon/bin/nmon2csv.pl" 

Invoked by the Splunk Archive Processor whenever required, this script will translate NMON data into data Splunk can successfully exploit 
This is a standard perl script with no uncommon perl requirement 

- nmon_for_linux.sh: third party script to collect NMON data for Linux indexer or forwarder
- nmon_for_solaris.sh: third party script to collect NMON data for Solaris indexer or forwarder
- purge_nmon_repository.sh: third party script to purge NMON repository (activated by default)
