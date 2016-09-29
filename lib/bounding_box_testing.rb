require 'rgeo/geo_json'
require 'rgeo'
require 'pry'

# final_bounding_boxes
	# map_zoom (one per level)
		#average box area
		#boxes (array of hashes)		
			# box area
			# coordinates
			# intersections array (empty)


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




# # Process Input, Delivers Final Product 
# def bounding_box_builder(bounding_boxes = {}, zoom_level)
# 	final_bounding_boxes = {}
# 	puts bounding_boxes[zoom_level]
# 	# for key, boxes in bounding_boxes[zoom_level]
# 	# 	if key == zoom_level
# 	# 		final_bounding_boxes[key] = {}
# 	# 		final_bounding_boxes[key]['boxes'] = []
# 	# 		all_areas = []
# 	# 		boxes.each.with_index(1) do |box, index|
# 	# 			box_hash = {}
# 	# 			box_hash['intersections'] = []
# 	# 			rgeo_conversion = convert_bbox(box)
# 	# 			box_hash['rgeo_box'] = rgeo_conversion
# 	# 			box_area = rgeo_conversion.area
# 	# 			box_hash['rgeo_box_area'] = box_area
# 	# 			all_areas << box_area
# 	# 			final_bounding_boxes[key]['boxes'] << box_hash
# 	# 		end
# 	# 		final_bounding_boxes[key]['average_area'] = average(all_areas)
# 	# 	end
# 	# end
# 	final_bounding_boxes
# end





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



















# TEST OUTPUT STRUCTURE
# zoom_level
# 	payload
# 		average_length
# 		max_length
# 	ratios (hash)
# 		fill : (minimum area/average bbox area)

# Tests for Payload Size,
def bbox_test_output(bboxes = {}, zoom_hash = {})
	test_output = {}
	zoom_hash.each do |zoom_level, zoom_params|
		for zoom_level in zoom_params['map_zoom']
			test_output[zoom_level] = {}
			# Getting payloads, average and max
			payload = bbox_payload_testing(bboxes[zoom_level]['boxes'])
			test_output[zoom_level]['payload'] = payload

			if zoom_params["size_fill_limits"] != nil
				test_output[zoom_level]['ratios'] = {}
				bbox_area = bboxes[zoom_level]['average_area']
				for key, value in zoom_params["size_fill_limits"]
					test_output[zoom_level]['ratios'][value] = \
						(key.to_f/bbox_area) * (10 ** 6)
				end
			end
			
		end
	end
	test_output
end


def bbox_payload_testing(boxes = [])
	payload = {}
	all_box_lengths = []
	for box in boxes
		box_length = []
		for polygon in box['intersections']
			json_poly = RGeo::GeoJSON.encode(polygon)
			# puts json_poly['coordinates']
			box_length << json_poly['coordinates']
		end
		mb_length = (box_length.to_json.length.to_f/1024)/1024
		all_box_lengths << mb_length
	end
	payload['average_length'] = average(all_box_lengths)
	payload['max_length'] = all_box_lengths.sort.max
	payload
end


	# for key, value in bbox_intersections
	# 	test_output[key] = {}
	# 	average_length = []
	# 	for box_name, box_values in value
	# 		box_length = []
	# 		for item in box_values['intersections']
	# 			cleaned_poly = RGeo::GeoJSON.encode(item)
	# 			box_length << cleaned_poly["geometries"][0]
	# 		end
	# 		mb_length = (box_length.to_json.length/1024)/1024
	# 		average_length << mb_length
	# 	end

	# 	average = average_length.inject \
	# 		{ |sum, el| sum + el }.to_f / average_length.length

	# 	test_output[key]['average_length'] = average
	# 	test_output[key]['max_length'] = average_length.max
	# end
	# test_output






# # Matches Zoom Levels to Zoom Ranges. Key is Zoom Level, Value is Boxes
# def sort_bboxes(bounding_boxes = {}, matching_hash = {})
# 	sorted_output = {}
# 	for matching_key, matching_value in matching_hash
# 		matches = bounding_boxes.select\
# 			{ |k,v| matching_value['map_zoom'].include? k}
# 		if matches.empty?
# 			next
# 		else
# 			sorted_output[matching_key] = []
# 			for key, value in matches
# 				for box in value
# 					sorted_output[matching_key] << box
# 				end
# 			end
# 		end
# 	end
# 	sorted_output
# end


# OLD BUILDER

	# for key, boxes in sorted_bboxes
	# 	final_bounding_boxes[key] = {}		
	# 	boxes.each.with_index(1) do |box, index|
	# 		final_bounding_boxes[key]["box_" + index.to_s] = {}
	# 		final_bounding_boxes[key]["box_" + index.to_s]['box'] =\
	# 			convert_bbox(box)
	# 		final_bounding_boxes[key]["box_" + index.to_s]['intersections'] = []
	# 	end
	# end
	# final_bounding_boxes













