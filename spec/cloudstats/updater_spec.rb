require 'cloudstats/updater'
require 'webmock/rspec'

describe CloudStats::Updater do
  before :each do
    `rm -rf /tmp/cloudstats-agent*`
  end

  it 'should get the latest version from the server' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/cloudstats-version")
      .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.8.8'})
      .to_return(:status => 200, :body => "0.1.1", :headers => {})

    expect(CloudStats::Updater.new.send(:get_latest_version)).to eq('0.1.1')
  end

  it 'should download the file from the server' do
    file_content = 'lol'

    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/package_name").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.8.8'}).
         to_return(:status => 200, :body => file_content, :headers => {})

    CloudStats::Updater.new.send(:download, 'package_name')

    expect(File.read("/tmp/package_name")).to eq(file_content)
  end

  it 'should install the package' do
    `cp spec/fixtures/cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz /tmp`
     app_dir = '/tmp/cloudstats-agent-0.0.1.1-linux-x86_64'
     `rm -rf #{app_dir}`
     `mkdir #{app_dir}`

    c = CloudStats::Updater.new
    c.instance_variable_set :@app_dir, app_dir
    c.send(:install, 'cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz')

    expect(`ls /tmp/cloudstats-agent-0.0.1.1-linux-x86_64`).to_not eq('')
  end

  it 'should remove the archive' do
    `cp spec/fixtures/cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz /tmp`
    c = CloudStats::Updater.new
    c.send(:remove_archive, 'cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz')

    expect(`ls /tmp/cloudstats-agent-0.0.1.1-linux-x86_64.tar.gz`).to eq('')
  end

  it 'should copy the new init.d script' do
    c = CloudStats::Updater.new
    c.instance_variable_set :@app_dir, '.'
    c.instance_variable_set :@init_script, '/tmp'

    c.send(:update_init_script)

    expect(`ls /tmp/cloudstats-agent`).to eq("/tmp/cloudstats-agent\n")
  end

  it 'should update the app' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/cloudstats-version").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.8.8'}).
        to_return(:status => 200, :body => "100.0.1.1", :headers => {})

    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/cloudstats-agent-100.0.1.1-linux-x86_64.tar.gz").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.8.8'}).
         to_return(:status => 200, :body => File.read('spec/fixtures/cloudstats-agent-100.0.1.1-linux-x86_64.tar.gz'), :headers => {})

    app_dir = '/tmp/cloudstats-agent-100.0.1.1-linux-x86_64'
    `rm -rf #{app_dir}`
    `mkdir #{app_dir}`

    allow(OS).to receive(:current_os).and_return(:linux)
    allow(OS).to receive(:architecture).and_return('x86_64')

    c = CloudStats::Updater.new
    c.instance_variable_set :@app_dir, app_dir

    Config[:update_type] = :reload
    expect(c.update).to be true

    expect(`ls #{app_dir}`).to_not eq('')
  end

  it 'should send a message when using the same version' do
    stub_request(:get, "https://cloudstatsstorage.blob.core.windows.net/agent/cloudstats-version").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.8.8'}).
        to_return(:status => 200, :body => "0.0.1.1", :headers => {})

    expect(CloudStats::Updater.new.update).to be false
  end
end
