module CloudStats
  module RabbitMQ
    def self.create_connection(vhost)
      conn = Bunny.new({
        host: Config[:rabbitmq_server],
        vhost: "/#{vhost}",
        username: PublicConfig['key'],
        password: ''
      })
      conn.start
      conn
    end
  end
end
