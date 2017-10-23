#!/bin/bash

# configuration apply:
crudini --set /etc/app.ini OPTIONS string "${OPTIONS_STRING_VALUE}"

exec /opt/app/app
