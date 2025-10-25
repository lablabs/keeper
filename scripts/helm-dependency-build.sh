#!/usr/bin/env sh

process_chart() {
  dir="$1"
  if yq -e '.dependencies[] | select(.repository | match("https://"))' "$dir/Chart.yaml"; then
     yq -r '.repositories[] | "helm repo add \(.name) \(.url)"' $dir/helm-repositories.yaml | sh
    helm dependency build "$dir" --repository-config "$dir/helm-repositories.yaml"
  else
    helm dependency build "$dir" --skip-refresh
  fi
}

if [ $# -eq 1 ]; then
  process_chart "charts/$1"
else
  for dir in charts/*; do
    process_chart "$dir"
  done
fi
