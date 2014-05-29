Lightblue - Functional tests
=====================

This document aims to give an overview of the tests


How the functional tests will  be generated and placed here
-----------------------------------------------------------

You need to install http://gatling-tool.org/ in your machine and start the gatling’s recorder (which will be a simple proxy you need to inform you browser or system so the recorder will capture the HTTP(S) requests and turn them into test code). Then you can use any web tool you want (such as cURL, web browser, etc as the proxy is running and the system is configured). After recording the whole scenario, you can move it to this folder to make it available to everyone (and it is useful for Jenkins, for example)

There are some arguments you can pass to Gatling (see the Gatling.scala class below for more details so you can avoid the interative mode). 

You can also set the Jenkins Gatling plugin to make Gatling work with Jenkins so that will run after the project build and generate the Gatling reports. The last link demostrate a groovy code which can run after Gatling task to validate the Gatling log, to make sure that every request worked fine (the output and the HTTP code, for example), which is expected for functional tests.

You can use the data from https://github.com/lightblue-platform/lightblue/tree/master/docs/demo to simulate and test how the tools work and then create the official tests.


http://gatling-tool.org/

https://github.com/excilys/gatling/wiki

https://github.com/excilys/gatling/wiki/Recorder#browser-config

https://github.com/excilys/gatling/blob/1.5.X/gatling-app/src/main/scala/com/excilys/ebi/gatling/app/Gatling.scala

https://github.com/excilys/gatling/wiki/Jenkins-Plugin

https://wiki.jenkins-ci.org/display/JENKINS/Gatling+Plugin

https://github.com/jumarko/gatling-sample-project/blob/master/ConvertGatlingToXunit.groovy
