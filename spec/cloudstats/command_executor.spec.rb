require 'cloudstats/server/command_executor'

describe CloudStats::CommandExecutor do
  let :executor do
    CloudStats::CommandExecutor.new(timeout: 2)
  end

  it 'should run process normally' do
    executor.execute!('echo "hi"')

    expect(executor.fulfilled).to be true
    expect(executor.exit_code).to eq(0)
    expect(executor.stdout).to eql("hi\n")
    expect(executor.stderr).to be_empty
  end

  it 'should halt process with timeout' do
    executor.execute!('sleep 5')

    expect(executor.fulfilled).to be false
    expect(executor.exit_code).to eq(-1)
    expect(executor.stdout).to be_empty
    expect(executor.stderr).to be_empty
  end

  it 'should read stderr' do
    executor.execute!('echo hi >&2')

    expect(executor.fulfilled).to be true
    expect(executor.exit_code).to eq(0)
    expect(executor.stdout).to be_empty
    expect(executor.stderr).to eql("hi\n")
  end
end
