module CloudStats
  module RabbitMQ
    def self.connection_for(vhost)
      connection = self.get_connection(vhost)
      unless connection
        connection = self.create_connection(vhost)
        self.set_connection(vhost, connection)
      end
      connection
    end

    private

    def self.get_connection(vhost)
      @@connections ||= {}
      @@connections[vhost]
    end

    def self.set_connection(vhost, connection)
      @@connections ||= {}
      @@connections[vhost] = connection
    end

    def self.create_connection(vhost)
      conn = Bunny.new({
        vhost: "/#{vhost}",
        username: PublicConfig['key'],
        password: ''
      })
      conn.start
      conn
    end
  end
end
