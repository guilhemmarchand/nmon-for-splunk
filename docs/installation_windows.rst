==================
Running on Windows
==================

.. image:: img/Windows_72px.png
   :alt: Windows_72px.png
   :align: center

It is not possible to generate Nmon data of a Windows machine. (nmon is *nix specific !)

**But you can install and run Nmon Performance app over Windows in various conditions:**

* Within a distributed deployment architecture (for any role)

* In standalone instance with Universal Forwarders clients running the TA-nmon

* In distributed / standalone instance to manage cold nmon files generated out of Splunk

100% of App's functionality are available on Windows hosts running Nmon Performance app.

**1. Install the Python interpreter for Windows (version 2.x)**

Download and Install Python 2.x package for Windows from: https://www.python.org/download

**2. If you intend to manage nmon file locally on the Windows server, install the TA-nmon**

After installation, you must use specific version of inputs.conf and props.conf (in the TA-nmon directory)

* Copy the inputs.conf_forWindows.spec file from default to local/inputs.conf in the TA-nmon directory

* Copy the props.conf_forWindows.spec file from default to local/props.conf in the TA-nmon directory

**3. Restart Splunk.**