# POC for custom jdk 11 runtime

### Prerequesites
* docker
* make

### Usage

```
make
```

### Result

* Reduction from 308MB to 29MB

```
conni@herbie:~/work/conni/github/cbuschka/min-jdk11-rt [master]$ make
*****************************
* cleaning...
*****************************
rm -rf /home/conni/work/conni/github/cbuschka/min-jdk11-rt/target/
*****************************
* building build container...
*****************************
docker build -t min-jdk11-rt /home/conni/work/conni/github/cbuschka/min-jdk11-rt \
	&& docker run -v /home/conni/work/conni/github/cbuschka/min-jdk11-rt:/work -u 1000:1001 min-jdk11-rt make clean link
Sending build context to Docker daemon  118.3kB
Step 1/4 : FROM openjdk:11-jdk
 ---> a7e47afa852b
Step 2/4 : RUN export DEBIAN_FRONTEND=noninteractive; 	apt-get update 	&& apt-get install make binutils         && apt-get autoremove -y         && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 3a5c4acd884b
Step 3/4 : RUN mkdir -p /work
 ---> Running in 501acfa74ffe
Removing intermediate container 501acfa74ffe
 ---> b37df903448f
Step 4/4 : WORKDIR /work
 ---> Running in 81fbc50857c1
Removing intermediate container 81fbc50857c1
 ---> f9357e587e15
Successfully built f9357e587e15
Successfully tagged min-jdk11-rt:latest
*****************************
* cleaning...
*****************************
rm -rf /work/target/
*****************************
* compiling...
*****************************
cd /work/src \
	&& /usr/local/openjdk-11/bin/javac -d /work/target/classes ./module-info.java \
	&& /usr/local/openjdk-11/bin/javac -d /work/target/classes --module-path /work/target/classes ./hello/Hello.java
*****************************
* packaging...
*****************************
cd /work/target/classes && /usr/local/openjdk-11/bin/jar cvf /work/target/hello.jar .
added manifest
added module-info: module-info.class
adding: hello/(in = 0) (out= 0)(stored 0%)
adding: hello/Hello.class(in = 422) (out= 291)(deflated 31%)
*****************************
* linking runtime...
*****************************
/usr/local/openjdk-11/bin/jdeps --module-path /work/target/classes -s --module hello
hello -> java.base
# https://github.com/docker-library/openjdk/issues/217
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=905575
# https://bugzilla.redhat.com/show_bug.cgi?id=1652177, --native-libs-replace 
/usr/local/openjdk-11/bin/jlink --verbose --strip-debug --compress 2 --no-header-files --no-man-pages --module-path /usr/local/openjdk-11/jmods/:/work/target/classes --add-modules hello --output /work/target/dist/
hello file:///work/target/classes/
java.base file:///usr/local/openjdk-11/jmods/java.base.jmod

Providers:
  java.base provides java.nio.file.spi.FileSystemProvider used by java.base
strip -p --strip-unneeded /work/target/dist/lib/server/libjvm.so
du -sh /usr/local/openjdk-11
308M	/usr/local/openjdk-11
du -sh /work/target/dist
29M	/work/target/dist
*****************************
* running...
*****************************
times ./target/dist/bin/java -cp target/hello.jar hello.Hello
0m0.002s 0m0.001s
0m0.000s 0m0.000s
```

## License
[MIT](./license.txt)
