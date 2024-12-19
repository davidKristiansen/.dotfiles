
if [ -d /opt/python/bin ]; then
	export PATH=/opt/python/bin:$PATH
fi

if [ -d /opt/arm/armcc/bin ]; then
	export PATH=/opt/arm/armcc/bin:$PATH
fi

if [ -d /opt/arm/armds/bin ]; then
	export PATH=/opt/arm/armds/bin:$PATH
fi

if [ -d "${GOPATH}"/bin ]; then
	export PATH="${GOPATH}"/bin:$PATH
fi
