ARG IMAGE=containers.intersystems.com/intersystems/iris-community:latest-em
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
USER ${ISC_PACKAGE_MGRUSER}

#COPY  Installer.cls .
COPY src src
COPY Installer.cls Installer.cls
COPY module.xml module.xml
COPY iris.script /tmp/iris.script

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly

ENV PIP_DEFAULT_TIMEOUT=60 \
    PIP_RETRIES=10 \
    PIP_TRUSTED_HOST=registry.intersystems.com

RUN python3 -m pip install --no-cache-dir --index-url https://registry.intersystems.com/pypi/simple --target /usr/irissys/mgr/python intersystems-iris-automl
