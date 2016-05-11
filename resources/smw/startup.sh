#!/bin/bash
#:#########################################################################
#: Intent: Start Apache and Mysql when docker container starts
#:##########################################################################

service apache2 restart
service mysql restart
tail -f /dev/null
