
require_relative 'pinout';


# allow for testing on a windows file system without gpio
PinOut.override_gpio_sysfs_base_path('c:/usr/test/sys/class/gpio');

pin_set = { 'alfa' => 0,
            'bravo' => 1,
            'charlie' => 6,
            'delta' => 7,
            'echo' => 8,
            'foxtrot' => 12,
            'golf' => 13,
            'hotel' => 14,
            'india' => 18,
            'kilo' => 19,
            'lima' => 20,
            'mike' => 21,
            'november' => 23,
            'oscar' => 26,
          };

controller = PinOut.new(pin_set);

controller.export;

controller.set_pin('bravo', PinOut::GPIO_PIN_VALUE_HIGH);
controller.set_pin(6, PinOut::GPIO_PIN_VALUE_HIGH);

pin_set.each do |tag, pin|
  puts("pin #{pin.to_s} (#{tag}) " +
       "<#{controller.get_pin_direction(tag).to_s}> = " +
       "#{controller.get_pin_value(tag).to_s}");
end

controller.unexport;
