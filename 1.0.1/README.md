# Supported tags and respective `Dockerfile` links

* `0.9.6` [(0.9.6/Dockerfile)](https://github.com/31z4/storm-docker/blob/master/0.9.6/Dockerfile)
* `0.10.1` [(0.10.1/Dockerfile)](https://github.com/31z4/storm-docker/blob/master/0.10.1/Dockerfile)
* `1.0.1`, `latest` [(1.0.1/Dockerfile)](https://github.com/31z4/storm-docker/blob/master/1.0.1/Dockerfile)


# How to use this image

## How to build Image

```
$ docker build -t ogre/storm-docker:1.0.1 .
```


## Setting up a minimal Storm cluster

1.	[Apache Zookeeper](https://zookeeper.apache.org/) is a must for running a Storm cluster. Start it first. Since the Zookeeper "fails fast" it's better to always restart it.

		$ docker run -d --restart always --name zookeeper 31z4/zookeeper:3.4.8

2.	The Nimbus daemon has to be connected with the Zookeeper. It's also a "fail fast" system.
	```
	$ docker run -ti --rm  --dns 192.168.33.20 \ 
          -e "SERVICE_NAME=nimbus" \ 
          -e "NIMBUS_SERVICE_NAME=nimbus.service.consul" \
          -e "ZK_SERVICE_NAME=zk.service.consul" \ 
          ogre/storm-docker:1.0.1 --daemon nimbus
	```

3.	Start a single Supervisor node and logviewer. It will talk to the Nimbus and Zookeeper.
	```
	$ docker run -ti --rm --dns 192.168.33.20  \
	  -e "SERVICE_NAME=supervisor" \ 
          -e "NIMBUS_SERVICE_NAME=nimbus.service.consul" \ 
          -e "ZK_SERVICE_NAME=zk.service.consul" \ 
          ogre/storm-docker:1.0.1 --daemon supervisor logviewer
	```

4.	Start Storm UI.
	```
	$ docker run   -ti  --rm --dns 192.168.33.20 \ 
          -e "SERVICE_NAME=ui" \ 
          -e "NIMBUS_SERVICE_NAME=nimbus.service.consul" \ 
          -e "ZK_SERVICE_NAME=zk.service.consul" \ 
          ogre/storm-docker:1.0.1 --daemon ui
	```

5.	Now we can submit a topology to our cluster.
	```
	$ docker run -it  --rm  --dns 192.168.33.20 --entrypoint storm \ 
          -v /home/hadoop/storm-starter-topologies-1.0.1.jar:/topology.jar ogre/storm-docker:1.0.1 \
          -c nimbus.host=nimbus.service.consul  
          jar /topology.jar org.apache.storm.starter.WordCountTopology topology
	```
