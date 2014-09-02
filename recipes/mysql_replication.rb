## mysql::master
ruby_block 'store_mysql_master_status' do
  block do
    node.set[:mysql][:master] = true
    m = Mysql.new('localhost', 'root', node[:mysql][:server_root_password])
    m.query('show master status') do |row|
      row.each_hash do |h|
        node.set[:mysql][:master_file] = h['File']
        node.set[:mysql][:master_position] = h['Position']
      end
    end
    Chef::Log.info "Storing database master replication status: #{node[:mysql][:master_file]} #{node[:mysql][:master_position]}"
    node.save
  end
  # only execute if mysql is running
  only_if "pgrep 'mysqld$'"
  # subscribe to mysql service to catch restarts
  subscribes :create, 'service[mysql]'
end

## mysql::slave
ruby_block 'start_replication' do
  block do
    if Chef::Config[:solo]
      Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
      return
    else
      dbmasters = search(:node, "mysql_master:true AND mysql_cluster_name:#{node[:mysql][:cluster_name]}")
    end

    if dbmasters.size != 1
      Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
    else
      dbmaster = dbmasters.first
      Chef::Log.info("Using #{dbmaster.name} as master")

      m = Mysql.new('localhost', 'root', node[:mysql][:server_root_password])
      command = %(
      CHANGE MASTER TO
        MASTER_HOST="#{dbmaster.mysql.bind_address}",
        MASTER_USER="repl",
        MASTER_PASSWORD="#{dbmaster.mysql.server_repl_password}",
        MASTER_LOG_FILE="#{dbmaster.mysql.master_file}",
        MASTER_LOG_POS=#{dbmaster.mysql.master_position};
      )
      Chef::Log.info 'Sending start replication command to mysql: '
      Chef::Log.info command

      m.query('stop slave')
      m.query(command)
      m.query('start slave')
    end
  end

  not_if do
    # TODO
    # this fails if mysql is not running - check first
    m = Mysql.new('localhost', 'root', node[:mysql][:server_root_password])
    slave_sql_running = ''
    m.query('show slave status') { |r| r.each_hash { |h| slave_sql_running = h['Slave_SQL_Running'] } }
    slave_sql_running == 'Yes'
  end

end
