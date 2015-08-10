require 'cloudstats/updater'
require 'webmock/rspec'

describe CloudStats::Updater do
  before :each do
    `rm -r /tmp/cloudstats-agent*`
  end

  it 'should check the current version' do
    expect(CloudStats::Updater.new.current_version).to eq('0.2.0')
  end

  it 'should get the architecture' do
    expect(CloudStats::Updater.new.architecture).to eq('x86_64')
  end

  it 'should get the latest version from the server' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/version").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "0.1.1", :headers => {})

    expect(CloudStats::Updater.new.get_latest_version).to eq('0.1.1')
  end

  it 'should download the file from the server' do
    file_content = 'lol'
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/package_name").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => file_content, :headers => {})


    CloudStats::Updater.new.download('package_name')

    expect(File.read("/tmp/package_name")).to eq(file_content)
  end

  it 'should install the package' do
    `cp spec/fixtures/cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz /tmp`
     app_dir = '/tmp/cloudstats-agent-0.0.1.1-linux-x86_64'
     `rm -rf #{app_dir}`
     `mkdir #{app_dir}`

    c = CloudStats::Updater.new
    c.instance_variable_set :@app_dir, app_dir
    c.install('cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz')

    expect(`ls /tmp/cloudstats-agent-0.0.1.1-linux-x86_64`).to_not eq('')
  end

  it 'should update the app' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/version").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "100.0.1.1", :headers => {})

    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/cloudstats-agent-100.0.1.1-linux-x86_64.tar.gz").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read('spec/fixtures/cloudstats-agent-100.0.1.1-linux-x86_64.tar.gz'), :headers => {})

    app_dir = '/tmp/cloudstats-agent-100.0.1.1-linux-x86_64'
    `rm -rf #{app_dir}`
    `mkdir #{app_dir}`

    c = CloudStats::Updater.new
    c.instance_variable_set :@app_dir, app_dir

    c.update

    expect(`ls #{app_dir}`).to_not eq('')
  end

  it 'should send a message when using the same version' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/version").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "0.0.1.1", :headers => {})

    expect(CloudStats::Updater.new.update).to eq('Already using the latest version')
  end
end
