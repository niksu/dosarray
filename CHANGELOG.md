## DoSarray
0.1:
* First release
* added attacks: Slowloris, GoldenEye, Tor's Hammer.
* and targets: Apache (Event and Worker MPMs), Nginx, lighttpd, Varnish, HA-Proxy.
* Tested using various mitigations (iptables configurations etc).

0.2:
* Various improvements to configurability and reliability.
* Various bug fixes.
* Added documentation.
* More reliable load measurements.

0.3:
* Added support for experiments on HTTPS targets.
* Improved configurability -- instead of specifying number of attackers implicitly (through placement) can now specify it as a number and the system will figure out a balanced placement.
* Added HULK attack, and DeDOS target.
* Further bug fixes.

0.4:
* Improved stability, and deployed to another cluster.
* Made more modular -- so experiment and rendering phases can be (re)run separately.
* Added checks to ensure configuration arrays are consistently sized, and that the attack times don't outlast the experiment.
* Improved coding style (e.g., removed hard-codings, added parameters).
* Improved documentation, and added FAQ and diagnosis checklist.

0.5:
 * Added support for clusters that have access nodes through which the other nodes can be reached.
 * Added script to check whether a cluster has been configured correctly.
 * Improved cluster configuration script.
 * Added description of 3D-printing the 3D graphs produced using DoSarray.
 * Improved documentation.

## DoSarray image
* 0.1/0.2: Initial image containing various attacks scripts.
* 0.2a: added dependencies for Slowloris over SSL.
