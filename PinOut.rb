
require 'fileutils';


class PinOut

  GPIO_PIN_VALUE_LOW = 0;
  GPIO_PIN_VALUE_HIGH = 1;
  GPIO_PIN_DIRECTION_IN = 'in';
  GPIO_PIN_DIRECTION_OUT = 'out';

  
  @@gpio_sysfs_base_path = '/sys/class/gpio';
  @@gpio_sysfs_subsystem = 'gpiochip0/subsystem';
  @@gpio_sysfs_pin_prefix = 'gpio';
  @@gpio_sysfs_export_suffix = 'export';
  @@gpio_sysfs_unexport_suffix = 'unexport';
  @@gpio_sysfs_direction_suffix = 'direction';
  @@gpio_sysfs_value_suffix = 'value';

  def self.ensure_gpio_sysfs_path(path)
    if ! File.exists?(path) then
      FileUtils::mkdir_p(path);
    end
  end
    
  def self.override_gpio_sysfs_base_path(path)
    @@gpio_sysfs_base_path = path;
    ensure_gpio_sysfs_path(path);
    return (self);
  end

  def self.override_gpio_sysfs_subsystem(suffix)
    @@gpio_sysfs_subsystem = suffix;
    sysfs_subsystem_path = "#{@@gpio_sysfs_base_path}/" +
                           "#{@@gpio_sysfs_subsystem}";
    ensure_gpio_sysfs_path(sysfs_subsystem_path);
    return (self);
  end
  
  
  def initialize(pins)
    if pins.is_a?(Array) then
      # make allowance for just an array of pin numbers, generate labels
      # that are text representations of the pin numbers
      pin_hash = Hash.new;
      pins.each do |pin|
        pin_hash[pin.to_s] = pin;
      end
      @pins = pin_hash;
    elsif pins.is_a?(Hash) then
      # use input hash as-is
      @pins = pins;
    else
      # complain
    end
    sysfs_pin_path = "#{@@gpio_sysfs_base_path}/#{@@gpio_sysfs_pin_prefix}";
    @pins.values.each do |pin|
      sysfs_pin_dir = "#{sysfs_pin_path}#{pin.to_s}";
      if ! File.exists?(sysfs_pin_dir) then
        Dir.mkdir(sysfs_pin_dir);
      end
    end
    return (self);
  end

  def export
    sysfs_subsystem_path = "#{@@gpio_sysfs_base_path}/" +
                           "#{@@gpio_sysfs_subsystem}";
    PinOut.ensure_gpio_sysfs_path(sysfs_subsystem_path);
    @pins.each do |tag, number|
      sysfs_write("#{@@gpio_sysfs_subsystem}/" +
                  "#{@@gpio_sysfs_export_suffix}",
                  number.to_s);
    end
    return (self);
  end

  def unexport
    sysfs_subsystem_path = "#{@@gpio_sysfs_base_path}/" +
                           "#{@@gpio_sysfs_subsystem}";
    PinOut.ensure_gpio_sysfs_path(sysfs_subsystem_path);
    @pins.each do |tag, number|
      sysfs_write("#{@@gpio_sysfs_subsystem}/" +
                  "#{@@gpio_sysfs_unexport_suffix}",
                  number.to_s);
    end
    return (self);
  end

  
  def pin_direction?(pin_id)
    result = nil;
    pin_num = pin_number(pin_id);
    if pin_num then
      result = sysfs_read("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                          "#{@@gpio_sysfs_direction_suffix}");
    end
    return (result);
  end

  def get_pin_direction(pin_id)
    result = nil;
    pin_num = pin_number(pin_id);
    if pin_num then
      result = sysfs_read("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                          "#{@@gpio_sysfs_direction_suffix}");
    end
    return (result);
  end

  def get_pin_value(pin_id)
    result = nil;
    pin_num = pin_number(pin_id);
    if pin_num then
      sysfs_write("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                  "#{@@gpio_sysfs_direction_suffix}",
                  GPIO_PIN_DIRECTION_IN);
      result = sysfs_read("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                          "#{@@gpio_sysfs_value_suffix}").to_i;
    end
    return (result);
  end

  def set_pin(pin_id, value)
    pin_num = pin_number(pin_id);
    if pin_num then
      sysfs_write("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                  "#{@@gpio_sysfs_direction_suffix}",
                  GPIO_PIN_DIRECTION_OUT);
      sysfs_write("#{@@gpio_sysfs_pin_prefix}#{pin_num.to_s}/" +
                  "#{@@gpio_sysfs_value_suffix}",
                  value);
    end
    return (self)
  end
  
  
  def add_pin(pin)
    if pin.is_a?(Hash) then
      @pins[pin.key] = pin.value;
      sysfs_write(@@gpio_sysfs_export_suffix, pin.value.to_s);
    elsif pin.is_a?(Integer) then
      @pins[pin.to_s] = pin;
      sysfs_write(@@gpio_sysfs_export_suffix, pin.to_s);
    else
      # complain
    end
    return (self);
  end

  def remove_pin(pin_id)
    pin_num = pin_number(pin_id);
    if pin_num then
      sysfs_write(@@gpio_sysfs_unexport_suffix, pin_num.to_s);
      @pins.delete(pin_id.to_s);
    end
  end

  def pin_number(pin_id)
    result = nil;
    if pin_id.is_a?(Integer) then
      result = pin_id;
    elsif pin_id.is_a?(String) then
      if @pins.has_key?(pin_id) then
        result = @pins[pin_id];
      end
    end
    return (result);
  end

  
  def sysfs_write(suffix, value)
    File.open("#{@@gpio_sysfs_base_path}/#{suffix}", 'w') do |file|
      file.write(value);
    end
    return (self);
  end

  def sysfs_read(suffix)
    result = nil;
    sysfs_node = "#{@@gpio_sysfs_base_path}/#{suffix}";
    if File.exists?(sysfs_node) then
      result = File.read(sysfs_node);
    end
    return (result);
  end


end
