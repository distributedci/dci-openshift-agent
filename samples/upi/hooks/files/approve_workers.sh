#!/usr/bin/sh

PATH=$1:$PATH

CSRS=$(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}')
while [ -z "$CSRS" ]; do
	echo "Waiting for pending workers"
	sleep 5
	CSRS=$(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}')
done

# We process the CSR's slowly and re-build the list because approving will create kubelet-serving CSR's
while [ -n "$CSRS" ]; do
	for CSR $CSRS; do
		oc adm certificate approve $CSR
		sleep 5
	done
	CSRS=$(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}')
done

