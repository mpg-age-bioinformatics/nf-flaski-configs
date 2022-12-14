# Usage

```
LATEST_RELEASE=$(  curl --silent "https://api.github.com/repos/mpg-age-bioinformatics/nf-flaski-configs/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' )
nextflow run mpg-age-bioinformatics/nf-flaski-configs -r ${LATEST_RELEASE} --raw ~/test_input --json ~/Downloads/20221213.160401.jesq89x2.RNAseq.json --out ~/test_output_flaski -profile local && \
```
___ 

## Contributing

Make a commit, check the last tag, add a new one, push it and make a release:
```
git add -A . && git commit -m "<message>" && git push
git describe --abbrev=0 --tags
git tag -e -a <tag> HEAD
git push origin --tags
gh release create <tag> 
```