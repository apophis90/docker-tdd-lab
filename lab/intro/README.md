# Introduction: Test Driven Development for Docker images

## Why?

Many open source projects build Docker images as an essential part of their continuous integration (CI) pipelines and make them available in public repositories like Docker Hub. Maybe you do the same thing every day at your job. But how can you know your Docker image and the containers launched from it behave exactly as you expect it to be? There's plenty of things that might go wrong: Missing dependencies, incorrect permissions etc.

Usually, we recognize such problems when we first launch a container on our test or, even worse, on our production systems. If you're honest with yourself, this is not how we want to build Docker images. If an image does not behave as we intend it to do, we want the build to break instead of publishing an inoperable image.   

How can we tell if a Docker image actually "works" and meets our demands? 

## How?

First, let's take a look at how we achieve this goal for our application code. A powerful means to verify the behavior of our code base is unit testing,which gets even more powerful if we combine it with the discipline of Test Driven Development (TTD). In a nutshell, TDD is a technique which defines that the only motivation to write any production code is a failing unit test. Once the code to make a test pass has been written, it undergoes a phase of restructuring, also called _refactoring_. This process is also called the _Red/Green/Refactor_ cycle of TDD.

<p align="center">
<img src="http://marcabraham.files.wordpress.com/2012/04/06_red_green_refactor.jpg" alt="whoopsie">
</p>

## About Rspec and Serverspec
