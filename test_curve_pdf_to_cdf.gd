extends ColorRect

func _init():
	var my_curve := load("res://test_curve_pdf_to_cdf.tres")
	var max_test = 50000
	var found = 0
	for i in max_test:
		var x = my_curve.randf_cdf()
		if x > 0.995:
			found+=1
	print("There is ", float(found)/max_test * 100, "% of item with 100% quality")
