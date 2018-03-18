# Exercise 1: Fix the Dockerfile

Now that you have a basic understanding of how testing Dockerfiles and images with Serverspec works, let's get our hands dirty a little bit. In this part of the lab, you'll be faced with a Dockerfile as well as an already existing suite of tests. The purpose of the Dockerfile is to package a simple Node.js app and make it runnable as a Docker container. However, some Serverspec tests don't run green. Darn, seems like somebody messed up the Dockerfile!

Your job is to look at the rspec tests, find out what's wrong with the Dockerfile and fix things, until all tests pass. Don't worry, we'll do this together.

<br/>

## Setting up Node.js

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

## Where's the package.json file?

With a Node.js installation in place, we made a first step towards fixing the tests and running our app. Yet, according to the tests cases it seems like the package.json file, which basically describes a Node project, is missing:

```
$ bundle exec rspec spec/Dockerfile_spec.rb
.F.FFFF

Failures:

  1) Dockerfile must have package.json in file system
     Failure/Error: expect(file("/app/package.json")).to exist
       expected File "/app/package.json" to exist
```

But isn't the package.json file present in the current directory and shouldn't it, as the Dockerfile reveals, be copied into the image's `/app` directory along with the app.js file?
Admittedly, this one is a little bit mean. Take a look at the `.dockerignore` file in the current directory and you will see that it contains a single line which says "package.json". What the `.dockerignore` file does is defining the files and folders which should be excluded from the build context which gets sent to the Docker daemon when an image is built. As a consequence, the `package.json` file is simply not part of the build context and thus does not find its way into the image. 
In order to fix that, remove `package.json` from the `.dockerignore` file. 

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

We're almost done, only two more errors to go. Now, this one is the uppermost failing test:

```
$ bundle exec rspec spec/Dockerfile_spec.rb
.....FF

Failures:

  1) Dockerfile runs the Node.js application
     Failure/Error: expect(process('node')).to be_running
       expected Process "node" to be running
```

Going back to the Dockerfile, we recognize that there's indeed a `CMD` directive which however only tails `/dev/null`, which is actually nonsense and serves the only purpose of keeping the container running. To start our Node.js app instead, replace it with the following line at the end of the Dockerfile:

```
CMD ["node", "app.js"]
``` 

<br/>

## One last thing ...

Even though our Node app is now running within the container, there's still one more test which goes red:

```
$ bundle exec rspec spec/Dockerfile_spec.rb
.F.FFFF

Failures:

1) Dockerfile runs the Node.js application on the expected port
     Failure/Error: expect(port(8080)).to be_listening
       expected Port "8080" to be listening
```

Even though our app is now up and running, the server process listens on a different port than expected. Seems like there's still something missing in our Dockerfile. If you walk through the code in `app.js`, it shows that our Node app binds to port 3000 unless the `$PORT` environment variable specifies another one. From a Dockerfile, we can set an environment variable with the `ENV` directive, just like this:

```
ENV PORT=8080
```

Now, all you tests should be green. Congrats!


<br/>

## What you've learned

In this first part, you fixed an incorrect Dockerfile by making a suite of Serverspec tests pass one by one. You were demonstrated the value of unit tests for Docker image builds, which act as some sort of specification by expressing our expectations on how the final image should look like and how containers derived from that image should behave. So far, you didn't write Serverspec tests by yourself, but this will change in the next part.