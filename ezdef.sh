#!/bin/sh

java -jar lib/saxon9.jar -xsl:ezdef.xsl -versionmsg:off -s:$1
