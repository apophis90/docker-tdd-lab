# Introduction: Test Driven Development for Docker images

## Why?

Many open source projects build Docker images as an essential part of their continuous integration (CI) pipelines and make them available in public repositories like Docker Hub. Maybe you do the same thing every day at your job. But how can you know your Docker image and the containers launched from it behave exactly as you expect it to be? There's plenty of things that might go wrong: Missing dependencies, incorrect permissions etc.

Usually, we recognize such problems when we first launch a container on our test or, even worse, on our production systems. If you're honest with yourself, this is not how we want to build Docker images. If an image does not behave as we intend it to do, we want the build to break instead of publishing an inoperable image.   

How can we tell if a Docker image actually "works" and meets our demands? 

## How?

First, let's take a look at how we achieve this goal for our application code. A powerful means to verify the behavior of our code base is unit testing,which gets even more powerful if we combine it with the discipline of Test Driven Development (TTD). In a nutshell, TDD is a technique which defines that the only motivation to write any production code is a failing unit test. Once the code to make a test pass has been written, it undergoes a phase of restructuring, also called _refactoring_. This process is also called the _Red/Green/Refactor_ cycle of TDD.

<p align="center">
<img src="http://marcabraham.files.wordpress.com/2012/04/06_red_green_refactor.jpg" alt="whoopsie"><br/>
<span>(Source: http://marcabraham.files.wordpress.com/2012/04/06_red_green_refactor.jpg)</span>
</p>

In order to verify our Docker image builds, we can also apply this cycle to our Dockerfiles. By means of the Ruby libraries [RSpec](http://rspec.info/) and [Serverspec](http://serverspec.org/), we can implement unit tests for our Dockerfiles, which allows us to instantly probe the current state of a Docker image against specifications that define its desired behavior. 

<br/>

## About RSpec and Serverspec

RSpec is a Ruby library which simplifies TDD by allowing to implement test in a way so that they are not only easy to write, but also easy to read. It offers a high-level API letting developes define desired behavior almost like grammatical correct sentences, for example:

```ruby
 it "sums up to integers" do
    result = add(2, 3)
    expect(result).to eq 5
 end
```

For more detailed information about RSpec, please jump to the official [documentation](http://rspec.info/documentation/).


Serverspec is another Ruby library which extends RSpec to drive unit tests against servers and their configurations. It uses third-party APIs, like the Docker API, to execute commands in a VM or Docker container to check the current state and compare it to a user-defined condition. You can consider Serverspec tests _RSpec tests on steroids_. A sample test executed against a Docker container could look like this:

```ruby
 it "runs on Ubuntu Xenial" do
    expect(command('lsb_release -a').stdout).to include('Ubuntu 16')
 end
```

Serverspec can operate on various resources like files, directories, network interfaces and the user database. For a comprehensive list of all supported resource types, go to the [documentation](http://serverspec.org/resource_types.html).


