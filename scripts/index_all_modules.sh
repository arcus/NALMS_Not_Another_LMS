## This script is for running in the education_modules repo. 
## There might be a better way to get all of these titles out of the yaml and over here, but I don't know it yet,
## so this is the fast and easy way.

#!/bin/bash

echo module_name: Module Title > module_list.txt

# Add a row for each module, this time the sample module is included

for FOLDER in *
do
  if [[ -s $FOLDER/$FOLDER.md && "$FOLDER" != "a_sample_module_template" ]]       ## Only do this for folders that have a real module inside them.
    then
      ROW=$FOLDER
      ROW+=" `grep -m 1 title: $FOLDER/$FOLDER.md | sed "s/^[^ ]* //" | sed "s/^[ ]* //" | tr -dc '[:print:]' | tr ',' ' '`"  # Pull the YAML entry but remove excess white space at the front, as well as any unprintable characters or commas

      echo $ROW 
  fi
done

