====================
Scripts and Binaries
====================

**Scripts and Binaries embedded in Nmon Performance Monitor**

*Since the major release V1.7.4, the core application does not bring any data generation related components*

**Technical addon: please consult the TA-nmon dedicated documentation:** http://ta-nmon.readthedocs.io

The Nmon core application embeds a few scripted tools to be used for advanced customization purposes, as described above

************************************
Embedded Scripts in technical addons
************************************

* resources/Nmon_SplunkApp_Customize.py.gz:

This Python script (must be uncompressed before execution) is a tool provided to execute different kind of automated customizations, such as restricting the application purpose to a given operating system for instance. (hide AIX and Solaris)

Detailed documentation: :ref:`Nmon_SplunkApp_Customize_py`

* resources/create_agent.py.gz:

This Python script (must be uncompressed before execution) is a tool provided to create different version of the TA-nmon technical addon, such as for instance having one for your Production servers, one for non-production and sending data to different indexes.

Detailed documentation: :ref:`create_agent_py`

Study of usage: :ref:`split_by_datacenter`
