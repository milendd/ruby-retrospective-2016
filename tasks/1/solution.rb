CELSIUS = 'C'
FAHRENHEIT = 'F'
KELVIN = 'K'

MELTING_POINTS_CELSIUS = {
  'water' => 0,
  'ethanol' => -114,
  'gold' => 1064,
  'silver' => 961.8,
  'copper' => 1085,
}

BOILING_POINTS_CELSIUS = {
  'water' => 100,
  'ethanol' => 78.37,
  'gold' => 2700,
  'silver' => 2162,
  'copper' => 2567,
}

def convert_between_temperature_units(degrees, from_unit, to_unit)
  return degrees if from_unit == to_unit
  if from_unit == CELSIUS && to_unit == FAHRENHEIT
    (degrees * 1.8) + 32
  elsif from_unit == CELSIUS && to_unit == KELVIN
    degrees + 273.15
  elsif from_unit == FAHRENHEIT && to_unit == CELSIUS
    (degrees - 32) / 1.8
  elsif from_unit == FAHRENHEIT && to_unit == KELVIN
    (degrees + 459.67) * 5 / 9
  elsif from_unit == KELVIN && to_unit == CELSIUS
    degrees - 273.15
  elsif from_unit == KELVIN && to_unit == FAHRENHEIT
    (degrees * 9 / 5) - 459.67
  end
end

def melting_point_of_substance(substance, unit)
  degrees = MELTING_POINTS_CELSIUS[substance]
  convert_between_temperature_units(degrees, CELSIUS, unit)
end

def boiling_point_of_substance(substance, unit)
  degrees = BOILING_POINTS_CELSIUS[substance]
  convert_between_temperature_units(degrees, CELSIUS, unit)
end
