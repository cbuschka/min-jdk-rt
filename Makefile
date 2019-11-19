JAVA_HOME := /usr/lib/jvm/java-11-openjdk
PROJECT_DIR := $(shell pwd)

all:	clean link

clean:
	rm -rf ${PROJECT_DIR}/target/

init:
	mkdir -p ${PROJECT_DIR}/target/classes

build:	init
	cd ${PROJECT_DIR}/src \
		&& ${JAVA_HOME}/bin/javac -d ${PROJECT_DIR}/target/classes ./module-info.java \
		&& ${JAVA_HOME}/bin/javac -d ${PROJECT_DIR}/target/classes --module-path ${PROJECT_DIR}/target/classes ./hello/Hello.java

package:	build
	cd ${PROJECT_DIR}/target/classes && ${JAVA_HOME}/bin/jar cvf ${PROJECT_DIR}/target/hello.jar .

link:	build
	${JAVA_HOME}/bin/jdeps --module-path ${PROJECT_DIR}/target/classes -s --module hello
	# https://github.com/docker-library/openjdk/issues/217
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=905575
	# https://bugzilla.redhat.com/show_bug.cgi?id=1652177, --native-libs-replace 
	${JAVA_HOME}/bin/jlink --verbose --strip-debug --compress 2 --no-header-files --no-man-pages --module-path ${JAVA_HOME}/jmods/:${PROJECT_DIR}/target/classes --add-modules hello --output ${PROJECT_DIR}/target/dist/
	strip -p --strip-unneeded ${PROJECT_DIR}/target/dist/lib/server/libjvm.so
	du -sh ${JAVA_HOME}
	du -sh ${PROJECT_DIR}/target/dist
