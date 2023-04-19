#!/bin/bash
mkdir temporal
unzip web.zip -d temporal
cd temporal
mv * /var/www/html
cd ..
rm web.zip
rmdir temporal
