# Exercise 1: Fix the Dockerfile

Now that you have a basic understanding of how testing Dockerfiles and images with Serverspec works, let's get our hands dirty a little bit. In this part of the lab, you'll be faced with a Dockerfile as well as an already existing suite of tests. The purpose of the Dockerfile is to package a simple Node.js app and make it runnable as a Docker container. However, some Serverspec tests don't run green. Darn, seems like somebody messed up the Dockerfile!

Your job is to look at the rspec tests, find out what's wrong with the Dockerfile and fix things, until all tests pass. Don't worry, we'll do this together.

<br/>

## Fixing the base image

First, execute the Serverspec tests and take at look at the first error message:

```
$ bundle exec rspec spec/Dockerfile_spec.rb
.F..FFF
Failures:
  1) Dockerfile must have Node.js installed
     Failure/Error: expect(command('node --version').stdout).to include('v8.9.3')
       expected "" to include "v8.9.3"
```

As you can see in the error message above, one of the test cases checks for the presence of the Node.js package and fails, since the `node --version` command does not return anything. If you take a look at the first line in the corresponding Dockerfile, it shows that the image for our Node.js app is derived from the `alpine:3.7` base image, which doesn't come with node installed. How can we fix this?

One way to bypass that issue is to install node via Alpine's package manager. To do that, add the following line to the Dockerfile:

```
RUN apk add --no-cache nodejs
```  

Afterwards, re-run the Serverspec tests and you should see this test pass now. 

__Bonus question:__ Can you think of another solution that fixes the problem of not having Node.js installed? Try to adjust the Dockerfile and watch out if you can make the failure go away.

<br/>

## Install missing Node dependencies

The next failure message we get tells us something about a missing Node module that our app depends on, which does not seem to be installed either:

```
$ bundle exec rspec spec/Dockerfile_spec.rb
....FFF
Failures:
  1) Dockerfile must have 'express' node module installed
     Failure/Error: expect(command('npm list --depth=0 | grep express').stdout).to include('express')
       expected "" to include "express"
```

But we have `express` listed as a dependency in our package.json file haven't we? (spoiler: yes, we have). So what's missing here? What must be done to install a Node.js project's dependencies from a package.json file is running `npm install` from the project's root folder. Consequently, fixing that issue is as easy as adding the following line to the Dockerfile:

```
RUN npm install
```

__CAUTION:__ Make sure you add this line at the __end__ of your Dockerfile or at least after the _WORKDIR_ directive. Otherwise, the command won't be run in the correct directory which will cause it to fail. 

Again, re-run the tests and watch how we decreased the number of failures by yet another one.


<br/>

## Starting the Node sample app

