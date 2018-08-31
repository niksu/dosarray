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

## DoSarray image
* 0.1/0.2: Initial image containing various attacks scripts.
* 0.2a: added dependencies for Slowloris over SSL.
