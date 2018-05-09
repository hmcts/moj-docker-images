#!/usr/bin/env bash

BUILDROOT="${PWD}/buildroot/"
BUILDDATE=$(date +%Y%m%d)
BUILDDEST="docker.artifactory.reform.hmcts.net"
REQBINARY=( jq virtualbox curl )

for Binary in "${REQBINARY[@]}"; do
    TEST=$(which ${Binary} 2>/dev/null)
    if [ ${?} -gt 0 ]; then
	    echo "Missing binary for ${Binary}. Exiting."
	    exit 1
    fi
done

if [ ! -d "${BUILDROOT}" ]; then mkdir "${BUILDROOT}"; fi

vagrant status |grep "running (virtualbox)" > /dev/null 2>&1
RES=${?}
if [ ${RES} -eq 0 ]; then vagrant destroy --force; fi

vagrant up --provision
RES=${?}

if [ ${RES} -eq 0 ]; then
    for Build in $(jq -r '.build_versions[]' ${PWD}/provisioning/files/build_versions.json); do
	mkdir -p "${BUILDROOT}"/centos-"${Build}"/"${BUILDDATE}"/
	curl --silent http://localhost:8888/centos-"${Build}"-docker.tar.xz -o "${BUILDROOT}"/centos-"${Build}"/"${BUILDDATE}"/centos-"${Build}"-docker.tar.xz
	cat <<-EOF > "$BUILDROOT"/centos-"${Build}"/"${BUILDDATE}"/Dockerfile
		FROM scratch
		ADD centos-${Build}-docker.tar.xz /
		MAINTAINER dcd-devops-support@hmcts.net
		LABEL name="CentOS Docker Container" \
		      vendor="Ministry Of Justice - Reform Project" \
		      description="Base OS container for MoJ (Reform) Projects" \
		      license="MIT" \
		      build-date="${BUILDDATE}"
		VOLUME [ "/sys/fs/cgroup" ]
		CMD ["/usr/sbin/init"]
		EOF
	pushd "$BUILDROOT"/centos-"${Build}"/"${BUILDDATE}" >/dev/null
	sudo docker build -t "${BUILDDEST}"/devops/centos:"${Build}"-"${BUILDDATE}" . 1>/dev/null 2>&1
	if [ "${Build}" == "7.4.edge" ]; then
	    sudo docker tag "${BUILDDEST}"/devops/centos:"${Build}"-"${BUILDDATE}" "${BUILDDEST}"/devops/centos:latest
	fi
	popd >/dev/null
    done
fi

vagrant destroy --force
