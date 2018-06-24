
.. _scripts_and_binaries:

====================
Scripts and Binaries
====================

**This depends on the stack component:**

+--------------------------------------------+-------------------------------------------------------------------------+
| Component name                             |                     Contains scripts and binaries ?                     |
|                                            |                                                                         |
+============================================+=========================================================================+
| nmon-for-splunk                            | No                                                                      |
+--------------------------------------------+-------------------------------------------------------------------------+
| PA-nmon_light                              | No                                                                      |
+--------------------------------------------+-------------------------------------------------------------------------+
| TA-nmon                                    | Yes                                                                     |
+--------------------------------------------+-------------------------------------------------------------------------+
| TA-nmon-hec                                | Yes                                                                     |
+--------------------------------------------+-------------------------------------------------------------------------+

***************
nmon-for-splunk
***************

The core front-end application does **NOT** contain any kind of script or binary.

*************
PA-nmon_light
*************

The Support Add-on does **NOT** contain any kind of script or binaries.

****************
Technical Addons
****************

**The Technical Add-on contains various scripts and binaries:**

* http://ta-nmon.readthedocs.io

* http://ta-nmon-hec.readthedocs.io

****************
Additional tools
****************

Customizer script
=================

* resources/Nmon_SplunkApp_Customize.py.gz:

This Python script (must be uncompressed before execution) is a tool provided to execute different kind of automated customizations, such as restricting the application purpose to a given operating system for instance. (hide AIX and Solaris)

Detailed documentation: :ref:`Nmon_SplunkApp_Customize_py`

https://github.com/guilhemmarchand/nmon-for-splunk/blob/master/nmon/resources/Nmon_SplunkApp_Customize.py.gz

Create agent script
===================

* create_agent.py available in the Git repositories:

https://github.com/guilhemmarchand/TA-nmon

This Python script is a tool provided to create different version of the TA-nmon technical addon.

For example, you can use it to create a specific TA-nmon version for your critical production servers, and another version for your non production servers.

Each of the TA-nmon version would have its own parameters, such as the indexes, the data accuracy (interval between measures), etc.

Detailed documentation: :ref:`create_agent_py`

Study of usage: :ref:`split_by_datacenter`
