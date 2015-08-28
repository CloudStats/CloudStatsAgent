require 'backup'

module CloudStats
  class Backup
    def initialize
      ::Backup::Config.load(root_path: "#{File.expand_path(File.dirname(__FILE__))}/../../Backup")
    end

    def perform
      ::Backup::Logger.start!

      ::Backup::Model.find_by_trigger('cloudstats_backup').first.perform!
    end
  end
end
