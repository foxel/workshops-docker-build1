#!/bin/bash

# configuration apply:
sed -i "s/{OPTIONS_STRING_VALUE}/${OPTIONS_STRING_VALUE}/g" /etc/app.ini

exec /opt/app/app
