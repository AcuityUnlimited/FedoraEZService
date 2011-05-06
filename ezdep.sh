#!/bin/sh

java -jar lib/saxon9.jar -xsl:ezdep.xsl -versionmsg:off -s:$1 ezdef=$2
