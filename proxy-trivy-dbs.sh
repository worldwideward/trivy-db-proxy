#!/bin/bash
#

TMP_DIR="/tmp/oras"
DEBUG="False"

ARTIFACTS=(
"trivy-db:2"
"trivy-java-db:1"
)

MEDIA_TYPES=(
"application/vnd.aquasec.trivy.db.layer.v1.tar+gzip"
"application/vnd.aquasec.trivy.javadb.layer.v1.tar+gzip"
)

SOURCE_REPOSITORY="ghcr.io/aquasecurity"

DESTINATION_REPOSITORY="$ORAS_REGISTRY_HOST/aquasecurity"

check_oras_install() {

	which oras >> /dev/null
	result=$?

	if [ "$result" != 0 ]; then
		echo "[ERROR] Please install the oras CLI tool before executing this script"
		echo "[ERROR] See ORAS release page https://github.com/oras-project/oras/releases"
		exit 1
	fi
}

authenticate_private_registry() {

	registry=$1

	echo "$ORAS_REGISTRY_PASSWORD" | oras login $ORAS_REGISTRY_HOST --username $ORAS_REGISTRY_USERNAME --password-stdin >> /dev/null
	result=$?

	if [ "$result" != 0 ]; then
		echo "[ERROR] Registry hostname (env ORAS_REGISTRY_HOST): $ORAS_REGISTRY_HOST"
		echo "[ERROR] Registry username (env ORAS_REGISTRY_USERNAME): $ORAS_REGISTRY_USERNAME"
		echo "[ERROR] Registry password (env ORAS_REGISTRY_PASSWORD): $ORAS_REGISTRY_PASSWORD"
		echo "[ERROR] Failed to authenticate to OCI registry, exiting"
		exit 1
	fi
}

download_artifact() {

	artifact=$1

	oras pull $artifact
	result=$?

	retries=0
	wait_seconds=3

	while [ "$result" != 0 ]; do
		sleep $wait_seconds
		echo "[ERROR] Failed to download artifact '$artifact', retrying in $wait_seconds seconds"
		oras pull $artifact 

		result=$?
		retries=$(expr $retries + 1)

		if [ "$retries" == 3 ]; then
			wait_seconds=$(expr $wait_seconds \* 2)
			echo "[ERROR] Increasing retry frequency to $wait_seconds seconds"
		fi
		if [ "$retries" == 6 ]; then
			wait_seconds=$(expr $wait_seconds \* 2)
			echo "[ERROR] Increasing retry frequency to $wait_seconds seconds"
		fi
		if [ "$retries" == 10 ]; then
			echo "[ERROR] Retries exhausted"
			exit 1
		fi
	done

}

upload_artifacts() {

	destination=$1
	artifact=$2

	oras push $destination $artifact
}

main() {

	check_oras_install

	authenticate_private_registry

	mkdir -p $TMP_DIR
	cd $TMP_DIR

	for index in ${!ARTIFACTS[@]}; do

		if [ "$DEBUG" == "True" ]; then
			echo "Artifact ID: $index"
			echo "Database: $db_name"
			echo "Destination: $DESTINATION_REPOSITORY"
			echo "Artifact: ${ARTIFACTS[$index]}"
			echo "Media type: ${MEDIA_TYPES[$index]}"
		fi

		download_artifact "$SOURCE_REPOSITORY/${ARTIFACTS[$index]}"

		db_name=$(ls -th $TMP_DIR | head -1)

		upload_artifacts "$DESTINATION_REPOSITORY/${ARTIFACTS[$index]}" "$db_name:${MEDIA_TYPES[$index]}"
	done
}

main
