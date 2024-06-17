# How-to
## Initialize repo from template
1. Create a repo from the template. Make sure to copy main and gh-pages branches.
2. Replace <$chart-name> with your chart name in the main and gh-pages branches.
3. Place your chart in ./charts/<$chart-name> directory.
   1. Modify Chart.yaml accordingly!!!
4. Place custom values for the chart tests in ./charts/<$chart-name>/ci/<$bla>-values.yaml.
5. **Important**: If your chart contains custom resources, make sure CRDs or any other dependencies are installed in Kind cluster created in the `helm-lint-test.yaml` workflow.
6. If you want to use [helm-docs](https://github.com/norwoodj/helm-docs) to generate your Helm chart documentation, modify the contents of ./charts/<$chart-name>/README.md.gotmpl file. helm-docs will use the file to generate ./charts/<$chart-name>/README.md.
Otherwise, remove helm-docs from pre-commit and you can modify the root README.md or chart README.md by hand.

## Releasing a chart
1. Install pre-commit.
2. Commit and create a PR. Make sure the Chart version is updated appropriately in Chart.yaml
3. Wait for actions to succeed and approval.
4. Merge PR.
5. The chart will be released on the `https://lablabs.github.io/<$repo-name>/` GitHub page.

## Integrate with Artifacthub
1. After the chart is published in Github pages for the first time, create an Artifacthub repo https://leeyoongti.medium.com/helm-in-kubernetes-part-4-publish-helm-chart-to-artifact-hub-using-github-pages-ab7f55904faa
2. All following releases will be automatically pushed to Artifacthub.
3. When the Artifacthub repo is created, copy its ID to artifacthub-repo.yaml in gh-pages branch. This will mark the repo as verified.
