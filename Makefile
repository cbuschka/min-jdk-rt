PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
WORK_DIR=/work

all:	clean build run

clean:
	@echo "*****************************" && \
	echo "* cleaning..." && \
	echo "*****************************"
	rm -rf ${PROJECT_DIR}/target/

init:
	@mkdir -p ${PROJECT_DIR}/target/classes

compile:
	@echo "*****************************" && \
	echo "* compiling..." && \
	echo "*****************************"
	cd ${WORK_DIR}/src \
		&& mkdir -p ${WORK_DIR}/target/classes \
		&& javac -d ${PROJECT_DIR}/target/classes ./module-info.java \
		&& javac -d ${PROJECT_DIR}/target/classes --module-path ${WORK_DIR}/target/classes ./hello/Hello.java

package:	compile
	@echo "*****************************" && \
	echo "* packaging..." && \
	echo "*****************************"
	cd ${WORK_DIR}/target/classes && jar cvf ${WORK_DIR}/target/hello.jar .

link:	package
	@echo "*****************************" && \
	echo "* linking runtime..." && \
	echo "*****************************"
	jdeps --module-path ${WORK_DIR}/target/classes -s --module hello
	# https://github.com/docker-library/openjdk/issues/217
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=905575
	# https://bugzilla.redhat.com/show_bug.cgi?id=1652177, --native-libs-replace 
	${JAVA_HOME}/bin/jlink --verbose --strip-debug --compress 2 --no-header-files --no-man-pages --module-path ${JAVA_HOME}/jmods/:${PROJECT_DIR}/target/classes --add-modules hello --output ${PROJECT_DIR}/target/dist/
	strip -p --strip-unneeded ${PROJECT_DIR}/target/dist/lib/server/libjvm.so
	du -sh ${JAVA_HOME}
	du -sh ${WORK_DIR}/target/dist

docker-image:	init
	@echo "*****************************" && \
	echo "* building build container..." && \
	echo "*****************************"
	docker build -t min-jdk-rt:local ${PROJECT_DIR}

build:	docker-image
	@echo "********************************" && \
	echo "* building in build container..." && \
	echo "********************************"
	docker run -v ${PROJECT_DIR}:/work -u $(shell id -u):$(shell id -g) min-jdk-rt:local make clean link

run:	build
	@echo "*****************************" && \
	echo "* running..." && \
	echo "*****************************"
	times ./target/dist/bin/java --module-path target/hello.jar --module hello/hello.Hello
