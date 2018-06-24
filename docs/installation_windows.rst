==================
Running on Windows
==================

.. image:: img/Windows_72px.png
   :alt: Windows_72px.png
   :align: center

**It is NOT possible to generate Nmon data of a Windows machine!**

**But you can install and run the applications on Windows for different purposes:**

+----------------------+---------------------+------------------------+-------------------------+
| Splunk roles         | nmon-for-splunk     | PA-nmon_light          |  TA-nmon                |
|                      |                     |                        |                         |
+======================+=====================+========================+=========================+
| Search head          |     X               |                        |                         |
+----------------------+---------------------+------------------------+-------------------------+
| Indexer              |                     |    X                   |                         |
+----------------------+---------------------+------------------------+-------------------------+
| Master node          |                     |                        |                         |
+----------------------+---------------------+------------------------+-------------------------+
| Deployment server    |                     | Conditional            |    Conditional          |
+----------------------+---------------------+------------------------+-------------------------+
| Heavy Forwarder      |                     | Conditional            |                         |
+----------------------+---------------------+------------------------+-------------------------+
| Universal Forwarder  |                     |                        |    X                    |
+----------------------+---------------------+------------------------+-------------------------+

* Using Windows as a deployment server to push applications to Unix/Linux based servers is strongly discouraged as required file permissions will be lost, and manual actions would be required
