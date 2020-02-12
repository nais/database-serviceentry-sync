#!/usr/bin/env bash
set -e
while sleep 1; do
  for ns in $(kubectl get namespace -o jsonpath="{ range .items[?(.metadata.annotations['cnrm\.cloud\.google\.com/project-id'])] }{.metadata.name } { end }"); do 
    ips=$(kubectl get sqlinstances.sql.cnrm.cloud.google.com --namespace "$ns" -o jsonpath="{ range .items[*].status.publicIpAddress }  {'-'} { @ }{ '/32\n' }")
    [[ -z "$ips"  ]] && echo "no databases in '$ns', skipping." && continue
    echo -e "$ns: \n$ips"
    f=$(mktemp)
cat > "$f" <<EOF 
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: databases
  namespace: $ns
spec:
  addresses:
$ips
  hosts:
  - $ns.sql.google.internal
  location: MESH_EXTERNAL
  ports:
  - name: tcp
    number: 3307
    protocol: TCP
EOF
  kubectl apply -f "$f"
  echo "$ns" -> "$f"
  done
done
