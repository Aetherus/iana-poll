#!/bin/sh

trusted_gpg_key="ED97E90E62AA7E34"
tmp_asc_url="https://data.iana.org/time-zones/tzdata-latest.tar.gz.asc"
tmp_asc_path="/tmp/tzdata-latest.tar.gz.asc"
tmp_tarball_url="https://data.iana.org/time-zones/tzdata-latest.tar.gz"
tmp_tarball_path="/tmp/tzdata-latest.tar.gz"
publish_dir="${PUBLISH_DIR:-.}"

download() {
  echo "Downloading tzdata-latest.tar.gz.asc ..."
  curl --silent --location -o "$tmp_asc_path" "$tmp_asc_url"

  if [ "$?" -ne "0" ]; then
    echo -e "\e[31mFailed to downloading tzdata-latest.tar.gz.asc\e[0m" >&2
    return 1
  fi

  echo "Downloading tzdata-latest.tar.gz ..."
  curl --silent --location -o "$tmp_tarball_path" "$tmp_tarball_url"

  if [ "$?" -ne "0" ]; then
    echo -e "\e[31mFailed to downloading tzdata-latest.tar.gz\e[0m" >&2
    return 1
  fi

  echo "Verifying integrity of tzdata-latest.tar.gz ..."
  gpg --trusted-key="$trusted_gpg_key" --verify "$tmp_asc_path" "$tmp_tarball_path"

  if [ "$?" -ne "0" ]; then
    echo -e "\e[31mtzdata-latest.tar.gz is corrupted.\e[0m" >&2
    return 1
  fi
}

publish() {
  version="$(tar -O -xf "$tmp_tarball_path" version)"
  echo "Latest version: $version"
  echo "Publishing tzdata-latest.tar.gz ..."
  published_tarball_path="$publish_dir/tzdata-$version.tar.gz"
  cp "$tmp_tarball_path" "$published_tarball_path"
  ln -f "$published_tarball_path" "$publish_dir/tzdata-latest.tar.gz"
  echo "Tzdata is successfully published."
}

cleanup() {
  echo "Cleanup ..."
  rm -f "$tmp_tarball_path"
  rm -f "$tmp_asc_path"
  echo "Done cleanup."
}

download && publish
cleanup

