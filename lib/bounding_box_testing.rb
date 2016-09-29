require 'rgeo/geo_json'
require 'rgeo'
require 'pry'

def average(array)
	average = array.inject \
			{ |sum, el| sum + el }.to_f / array.length.to_f
end


# Process Input, Delivers Final Product 
def bounding_box_builder(bounding_boxes = {}, payload_array)
	final_bounding_boxes = {}
	for key, boxes in bounding_boxes
		if payload_array.include? key
			final_bounding_boxes[key] = {}
			final_bounding_boxes[key]['boxes'] = []
			all_areas = []
			boxes.each.with_index(1) do |box, index|
				box_hash = {}
				box_hash['intersections'] = []
				rgeo_conversion = convert_bbox(box)
				box_hash['rgeo_box'] = rgeo_conversion
				box_area = rgeo_conversion.area
				box_hash['rgeo_box_area'] = box_area
				all_areas << box_area
				final_bounding_boxes[key]['boxes'] << box_hash
			end
			final_bounding_boxes[key]['average_area'] = average(all_areas)
		end
	end
	final_bounding_boxes
end


# Converts GSOJSON Box into RGEO BOX
def convert_bbox(box)
	factory = RGeo::Geographic.simple_mercator_factory(:srid => 4326)
	ring = []
	for item in box
		ring << factory.point(item[0], item[1])
	end
	linear_ring = factory.linear_ring(ring)
	polygon = factory.polygon(linear_ring)
	polygon
end
