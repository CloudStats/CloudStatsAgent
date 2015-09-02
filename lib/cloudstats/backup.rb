require 'backup'

module CloudStats
  class Backup
    def initialize
      ::Backup::Config.load(root_path: "#{File.expand_path(File.dirname(__FILE__))}/../../Backup")
    end

    def perform
      ::Backup::Logger.start!
      ::Backup::Model.all.each do |m|
        ::Backup::Model.find_by_trigger(m.trigger).first.perform!
      end
    end
  end
end
