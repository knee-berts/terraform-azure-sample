cd "$(dirname "$0")"

./plan.sh \
    -a tfstatenje12345 \
    -e dev \
    -f "dev.plan.summary" \
    -g tf-dev \
    -m false \
    -p "dev.local.tfplan" \
    -r "true" \
    -s "./terraform.tfvars" \
    -t "tfvaraks" \
    -v "tf-keyvault" \
    -z "-destroy"


