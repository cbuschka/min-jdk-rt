JAVA_HOME := /usr/lib/jvm/java-11-openjdk

all:	link

clean:
	rm -rf ${PWD}/target/

init:
	mkdir -p ${PWD}/target/classes

build:	init
	cd ${PWD}/src \
		&& ${JAVA_HOME}/bin/javac -d ${PWD}/target/classes ./module-info.java \
		&& ${JAVA_HOME}/bin/javac -d ${PWD}/target/classes --module-path ${PWD}/target/classes ./hello/Hello.java

#package:	build
#	cd ${PWD}/src && ${JAVA_HOME}/bin/jar cvf ${PWD}/target/hello.jar hello/Hello.class  module-info.class

link:	build
	${JAVA_HOME}/bin/jdeps --module-path ${PWD}/target/classes -s --module hello
	# https://github.com/docker-library/openjdk/issues/217
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=905575
	# https://bugzilla.redhat.com/show_bug.cgi?id=1652177, --native-libs-replace 
	${JAVA_HOME}/bin/jlink --verbose --strip-debug --compress 2 --no-header-files --no-man-pages --module-path ${JAVA_HOME}/jmods/:${PWD}/target/classes --add-modules hello --output ${PWD}/target/dist/
	strip -p --strip-unneeded ${PWD}/target/dist/lib/server/libjvm.so
	du -sh ${JAVA_HOME}
	du -sh ${PWD}/target/dist
