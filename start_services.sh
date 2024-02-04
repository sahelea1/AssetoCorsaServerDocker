#!/bin/bash

# Starting SSH Service
service ssh start

# Starting VSFTPD Service
service vsftpd start

# Execute the run_ac_servers.sh script
/usr/local/bin/run_ac_servers.sh

