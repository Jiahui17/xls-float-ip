# Determine the url of the latest release tarball.
LATEST_XLS_RELEASE_TARBALL_URL=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/google/xls/releases | \
  grep -m 1 -o 'https://.*/releases/download/.*\.tar\.gz')

# Download the tarball and unpack it, observe the version numbers for each of the included tools.
curl -O -L ${LATEST_XLS_RELEASE_TARBALL_URL}
tar -xf xls-*.tar.gz
