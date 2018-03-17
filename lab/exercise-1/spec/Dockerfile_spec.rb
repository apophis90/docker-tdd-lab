
require 'serverspec'
require 'docker'

describe "Dockerfile" do
    before(:all) do
        @image = Docker::Image.build_from_dir('.')

        set :os, family: :alpine
        set :backend, :docker 
        set :docker_image, @image.id
    end

   
    it "should be built upon Alpine Linux" do
        expect(file('/etc/alpine-release')).to exist
    end

    it "must have Node.js installed" do
        expect(file('/usr/local/bin/node')).to exist
        expect(command('node --version').stdout).to include('v9.8.0')
    end

    it "must have app.js in file system" do
        expect(file("/app/app.js")).to exist
    end

    it "must have package.json in file system" do
        expect(file("/app/package.json")).to exist
    end

    it "must have 'express' node module installed" do
        expect(command('npm list | grep express').stdout).to include('express')
    end

    it "runs the Node.js application" do
        expect(process('node')).to be_running
    end

    it "runs the Node.js application on the expected port" do
        expect(port(8080)).to be_listening  
    end
    

    after(:all) do
        system("docker rm -f $(docker ps -a -q -f 'ancestor=#{@image.id}') > /dev/null")
        @image.remove(:force => true)
    end
end