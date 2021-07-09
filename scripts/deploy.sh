#!/usr/bin/env bash

set -e

./scripts/setup-kubectl-for-gcloud.sh

echo "--- Update kubectl config file us-east-1 region"
aws eks update-kubeconfig --name fpff-nonprod-use1-b --region us-east-1
chmod 600 ~/.kube/config

echo "--- Deployment for EngDev04 us-east-1 region"
kubectl config use-context arn:aws:eks:us-east-1:238801556584:cluster/fpff-nonprod-use1-b
namespace=devx-helloworld-springboot-x9iea-$([ "$ENV" == "pr" ] && git rev-parse --short HEAD || echo "$ENV")
serving_slot=$(helm -n $namespace get values devx-helloworld-springboot-x9iea --output json | jq -r '.config.servingSlot // empty')
serving_slot=${serving_slot:-blue}
non_serving_slot=$([ "$serving_slot" == "blue" ] && echo "green" || echo "blue")
helm upgrade --install --atomic devx-helloworld-springboot-x9iea src/main/helm -f src/main/helm/values.yaml -n $namespace \
    --create-namespace --set config.servingSlot=$serving_slot --set config.nonServingSlot=$non_serving_slot \
    --set "config.enabled={$serving_slot,$non_serving_slot}" --set config.image.tag=$TAG

echo "--- Post-deploy validation"
test_exit=0
helm test -n $namespace devx-helloworld-springboot-x9iea || test_exit=1

if [ $ENV != "dev" ]; then
    kubectl delete ns $namespace
    exit $test_exit
fi

serving_slot=$([ "$test_exit" -eq 0 ] && echo $non_serving_slot || echo $serving_slot)
helm upgrade --install --atomic devx-helloworld-springboot-x9iea src/main/helm -f src/main/helm/values.yaml -n $namespace \
    --set config.servingSlot=$serving_slot --set "config.enabled={$serving_slot}" --set config.image.tag=$TAG
exit $test_exit
