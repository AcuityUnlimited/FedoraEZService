#!/bin/bash
# EZService batch processing
#
# Stephen Bayliss 2011-05-09
#
# Dependencies:
# - EZService
# - Environment variable EZSERVICE must point to the EZService folder
#
# Description
#
# This script runs a set of related EZService input files through EZService to generate
# SDef and SDep FOXML files
#
# Usage
#
# Copy this script to the base directory of your EZDef and EZDep input files.
# Change to that directory, and run:
#
# ../batch-ezservice.sh
#
# The following directory structure (relative to this script) is required:
#
# ./EZDef - EZDef xml input files
# ./EZDep - EZDep xml input files
# ./SDef - SDef FOXML output files
# ./SDep - SDep FOXML output filles
#
# File naming:
# - EZDef input files must end in .xml
# - EZDep input files must be named the same as the EZDep input files, but with a "-[cmodel]" suffix in the name
# -- this allows for multiple EZDeps for each EZDef, differentiated by the content model name
# 
# eg
#  EZDef/myservice.xml
#    EZDep/myservice-image.xml
#    EZDep/myservice-document.xml
#
# output files are named the same as the corresponding input files

here=$(dirname $0)

# check for EZService
if [[ "$EZSERVICE" == "" ]]
then
  echo "Error: Please set (and export) environment variable EZSERVICE, pointing at your EZService installation folder"
  exit 1
fi

ezdefxsl="$EZSERVICE/ezdef.xsl"
ezdepxsl="$EZSERVICE/ezdep.xsl"
saxon="$EZSERVICE/lib/saxon9.jar"

dependencies="true"
if [[ ! -e "$ezdefxsl" ]]
then
  echo "Error: could not locate $ezdefxsl - check EZSERVICE is set correctly"
  dependencies="false"
fi
if [[ ! -e "$ezdepxsl" ]]
then
  echo "Error: could not locate $ezdepxsl - check EZSERVICE is set correctly"
  dependencies="false"
fi
if [[ ! -e "$saxon" ]]
then
  echo "Error: could not locate $saxon - check EZSERVICE is set correctly"
  dependencies="false"
fi

if [[ ! "$dependencies" == "true" ]]
then
  exit 1
fi

# output directories
if [[ ! -d SDef ]]
then
  mkdir SDef
fi
if [[ ! -d SDep ]]
then
  mkdir SDep
fi

# Iterate each EZDef
for file in EZDef/*.xml
do
  
  # generate input and output filenames
  base=`basename $file`
  ezdef="$here/EZDef/$base"
  sdef="$here/SDef/$base"

  # Corresponding EZDep pattern match
  ezdeppattern="$here/EZDep/${base/%.xml/-*.xml}"

  # do the EZDef
  echo "Creating SDef from EZDef $base"
  "$JAVA_HOME/bin/java" -jar $EZSERVICE/lib/saxon9.jar -xsl:$EZSERVICE/ezdef.xsl -versionmsg:off -s:$ezdef > $sdef
  
  for file2 in `ls $ezdeppattern`
  do
    base=`basename $file2`
    ezdep="$here/EZDep/$base"
    sdep="$here/SDep/$base"
    
    # the stylesheet additional input needs the full path to the ezdef input
    ezdeffull=$(pwd)/$ezdef
    
    # hack for cygwin
    if [[ "$OSTYPE" == "cygwin" ]]
    then
      ezdeffull=`cygpath -m $ezdeffull`
    fi

    # do the EZDep
    echo "...creating corresponding SDep from EZDep $base"
    "$JAVA_HOME/bin/java" -jar $EZSERVICE/lib/saxon9.jar -xsl:$EZSERVICE/ezdep.xsl -versionmsg:off -s:$ezdep ezdef=$ezdeffull > $sdep
  
  done
done

