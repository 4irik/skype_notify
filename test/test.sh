#!/bin/bash

for i in $(find . -type f -name "test_*.sh");
do
	scrip_dir=$(dirname $i)
	script_file=$(basename $i)
	(cd $scrip_dir && ./$script_file)
done
										   
