
require 'serverspec'
require 'docker'

describe "Dockerfile" do
    before(:all) do
        @image = Docker::Image.build_from_dir('.')

        set :os, family: :alpine
        set :backend, :docker 
        set :docker_image, @image.id
    end

   
    it "should have Go installed" do
        expect(file('/usr/local/go')).to exist
    end
   

    it "has app directory" do
        expect(file('/app')).to exist
        expect(file('/app')).to be_directory
    end

    it "has app binary" do
        expect(file('/app/copycat')).to exist
        expect(file('/app/copycat')).to be_file
    end

    it "has PORT env variable set" do
        expect(@image.json['Config']['Env']).to include(/^PORT=[0-9]{4,}/)
    end

    it "starts Copycat process" do
        expect(process('./copycat')).to be_running
        expect(port(2000)).to be_listening
    end

    after(:all) do
        system("docker rm -f $(docker ps -a -q -f 'ancestor=#{@image.id}') > /dev/null")
        @image.remove(:force => true)
    end
end