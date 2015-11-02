CloudStats::Sysinfo.plugin :disk do
  ATTRIBUTES = {
    1 => { name: "Raw_read_Error_Rate", read: "left16bit" },
    5 => { name: "Reallocated_Sector_Ct" },
    9 => { name: "Power_On_Hours", read: "right16bit", warn_max: 10000, crit_max: 15000 },
    10 => { name: "Spin_Retry_Count" },
    184 => { name: "End-to-End_Error" },
    187 => { name: "Reported_Uncorrect" },
    188 => { name: "Command_Timeout" },
    193 => { name: "Load_Cycle_Count", warn_max: 300000, crit_max: 600000 },
    194 => { name: "Temperature_Celsius", read: "right16bit", crit_min: 20, warn_min: 10, warn_max: 40, crit_max: 50 },
    196 => { name: "Reallocated_Event_Count" },
    197 => { name: "Current_Pending_Sector" },
    198 => { name: "Offline_Uncorrectable" },
    199 => { name: "UDMA_CRC_Error_Count" },
    201 => { name: "Unc_Soft_read_Err_Rate", read: "left16bit" },
    230 => { name: "Life_Curve_Status", crit_min: 100, warn_min: 100, warn_max: 100, crit_max: 100 }
  }

  # Get right 16 bit from raw48
  def right16bit(value)
    value & 0xffff
  end

  # Get left 16 bit from raw48
  def left16bit(value)
    value >> 32
  end

  def smartctl_query
    params = "-H -A "
    params += ATTRIBUTES.keys.map do |attr|
      "-v #{attr},raw48"
    end.join(" ")
    `smartctl #{params}`
  end

  def check_range(value, min, max)
    (min && value < min) || 
      (max && value > max)
  end

  def parse_attribute(fields, attr)
    value = fields[9].to_i
    value = send(attr[:read], value) if attr.include?(:read)
    report = {
      id: fields[0],
      name: attr[:name],
      value: value
    }
    if check_range(value, attr[:crit_min], attr[:crit_max])
      report[:type] = 'critical'
    elsif check_range(value, attr[:warn_min], attr[:warn_max])
      report[:type] = 'warning'
    else
      report[:type] = 'normal'
    end
    report
  end

  def format_message(dev, report)
    {
      type: report[:type],
      message: "#{dev} state is #{report[:type]} #{report[:id]} #{report[:name]}: #{report[:value]}"
    }
  end

  def parse_smart(dev)
    attr_ids = ATTRIBUTES.keys
    reports = smartctl_query
      .lines
      .map(&:split)
      .select { |l| l.size == 10 }
      .select { |l| l.first.to_i != 0 }
      .select { |l| attr_ids.include?(l.first.to_i) }
      .map do |fields|
        attr = ATTRIBUTES[fields.first.to_i]
        parse_attribute(fields, attr)
      end

    messages = reports.map { |r| format_message(dev, r) }
    all_passed = reports.all? { |r| r[:type] == :normal }

    { messages: messages, all_passed: all_passed }
  end

  def disks
    if OS.has?('smartctl')
      output = `smartctl --scan`
      output
        .map(&:split)
        .reject(&:empty?)
        .map(&:first)
    else
      []
    end
  end

  run do
    data = disks
      .map { |d| parse_smart(d) }
      .inject do |agg, info|
        {
          messages: agg[:messages] + info[:messages],
          all_passed: agg[:all_passed] && info[:all_passed]
        }
      end

    { 
      smart: {
        present: !data.nil?, 
        data: data 
      }
    }
  end
end
