*******
Delegated driver usage guide
*******

Requirements
============

* The molecule framework used for ansible role QA.
* Using delegated driver approach for molecule CI with Jenkins in which configured VM with igia-platform pre-requisites will be required.
* The configured VM will be added as Jenkins node (slave) and futher restricting the jobs to be executed on the newly added node.
* The endpoints are assumed to be configured correctly. If you have to execute the QA suite against different endpoints, you will need to update those in respective component's QA suite config files.
* The QA suite pre-requisites need to be installed on the target VM, in order to execute molecule verify action which invokes QA suite execution for selected igia-platform stack components. 

