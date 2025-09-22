class_name WeightedTable


var items: Array[Dictionary] = []
var weight_sum = 0


func add_item(item, weight: int):
	items.append({"item": item, "weight": weight})
	weight_sum += weight


func remove_item(item_to_remove):
	items = items.filter(func (item): return item["item"] != item_to_remove)
	weight_sum = 0
	for item in items:
		weight_sum += item["weight"]


func pick_item(exclude: Array = []):
	#NOTE: Weighted Table Array Management
	# iterate over every element in the array
	# keep track of the sum of the weights as you itterate
	# you see if a random int that you picked is <= sum until you meet or exceed
	# that means you should pick that item
	
	# Filter : (not the most performant code)
	var adjusted_items: Array[Dictionary] = items # our items array without modification
	var adjusted_weight_sum = weight_sum # the sum of our array's weight
	if exclude.size() > 0: # if greater than 0 in the array, Recalculate the array 
		adjusted_items = [] # Empty the array
		adjusted_weight_sum = 0 # Empty the weight
		for item in items: # for each item
			if item["item"] in exclude: # if the item is in the exclude array
				continue # skip the remaining code and run the check on the next item
			adjusted_items.append(item) # Append the cleared item to the adjusted items list
			adjusted_weight_sum += item["weight"] # Adjust our weight sum to include the item weight
	
	
	var chosen_weight = randi_range(1, adjusted_weight_sum) # choose a weight between one and weight sum
	var iteration_sum = 0 # keep track of the current iteration sum
	for item in adjusted_items: 
		iteration_sum += item["weight"]
		if chosen_weight <= iteration_sum: # if our chosen weight is less than or equal to our itteration sum
			return item.item #stop and return that item
			
