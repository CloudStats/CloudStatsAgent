module OS
  def self.match?(os)
    self.set_marks
    case os
    when :windows then @@windows
    when :osx     then @@mac
    when :unix    then @@unix
    when :linux   then @@linux
    else (os =~ RUBY_PLATFORM) != nil
    end
  end

  def self.current_os
    self.set_marks
    if    @@windows then :windows
    elsif @@mac     then :osx
    elsif @@linux   then :linux
    elsif @@unix    then :unix
    end
  end

  def self.architecture
    arch = `uname -m`.tr("\n", '')
    arch == 'i686' ? 'x86' : arch
  end

  private

  def self.set_marks
    @@windows ||= (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    @@mac     ||= (/darwin/ =~ RUBY_PLATFORM) != nil
    @@unix    ||= !@@windows
    @@linux   ||= @@unix && !@@mac
  end
end
