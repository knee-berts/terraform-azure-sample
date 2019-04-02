# run this locally to exec the terraform.sh script
set -e

cd "$(dirname "$0")"

./plan.sh \
    -a tfstatethgamble4g \
    -e dev \
    -f "dev.plan.summary" \
    -g tf-dev4f \
    -m false \
    -p "dev.local.tfplan" \
    -r "true" \
    -s "./terraform.tfvars" \
    -t "tfkubec4g-tg" \
    -v "tf-keyvault4g" \
    -y "tfkubes4g-tg" \
    -c "tfkubec4g-tg"

# ./plan.sh \
#     -e dev \
#     -g tf-master \
#     -a tfstatenje12345 \
#     -m false \
#     -r "true" \
#     -p "dev.local.tfplan" \
#     -f "dev.plan.summary" \
#     -s "dev" \

# ./vault-outputs.sh -n "tf-dev" -g "tf-master"
