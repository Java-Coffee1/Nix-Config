#/bin/bash

pg_dumpall -u admin > homelab_all+$(date+%F).sql