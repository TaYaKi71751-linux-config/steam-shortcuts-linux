#!/bin/bash

which shc >& /dev/null || (\
	echo "Install shc ( https://github.com/neurobin/shc )" && \
	exit 1
)

shell_scripts=`find ./sh -name "*.sh"`
for shell_script in ${shell_scripts[@]};do
	out="${shell_script/\.\/sh\//\.\/out\/}"
	out="${out/\.sh/\.out}"
	echo "mkdir -p $(dirname ${out})"
	mkdir -p $(dirname ${out})
	echo "shc -f ${shell_script} -o ${out}"
	shc -f ${shell_script} -o ${out}
done
