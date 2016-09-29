This is where sample json payloads are built!

Each payload is a set of raw polygons that all intersect with a bounding box.

There are usually a few bounding boxes per zoom level.

The payloads are then used to test how much simplification and filtering is 
needed to render the payload a digestable size.