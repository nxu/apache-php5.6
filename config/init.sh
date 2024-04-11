#!/bin/bash

set -euxo pipefail

# Display PHP errors
sed -i -e "s/error_reporting =.*=/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/g" /etc/php/5.6/apache2/php.ini
sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php/5.6/apache2/php.ini

# Start apache
apache2ctl -D FOREGROUND