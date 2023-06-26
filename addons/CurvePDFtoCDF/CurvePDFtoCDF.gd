@tool
@icon("res://addons/curve_pdf_to_cdf/chart-bell-curve-cumulative-white.svg")
extends Resource
class_name CurvePDFtoCDF

var _version = "1.0"

@export_range(2, 10000) var sample_size := 100:
	set(value):
		if sample_size != value:
			sample_size = value
			_curve_to_update()
			
@export var pdf_curve : Curve = Curve.new() : 
	set(value):
		if value != pdf_curve:
			pdf_curve = value
			pdf_curve.changed.connect(_curve_to_update)
			if not Engine.is_editor_hint() and _first_launch != true:
				_curve_to_update()
				_first_launch = false
				
			
@export var cdf_curve : Curve = Curve.new()

var _first_launch = true

signal cdf_updated

func _init():
	pdf_curve.changed.connect(_curve_to_update)
	
func _curve_to_update():
	cdf_curve = CurvePDFtoCDF.calculate_cdf_curve(pdf_curve, sample_size)
	cdf_updated.emit()

func sample_pdf(value, use_non_baked = false):
	return pdf_curve.sample(value) if use_non_baked else pdf_curve.sample_baked(value)

func sample_cdf(value, use_non_baked = false):
	return cdf_curve.sample(value) if use_non_baked else cdf_curve.sample_baked(value)
	
func randf_cdf(use_non_baked = false):
	return cdf_curve.sample(randf()) if use_non_baked else cdf_curve.sample_baked(randf())

static func calculate_cdf_curve(p_pdf_curve : Curve, p_nb_samples : int) -> Curve:
	var temp_cdf_curve: Curve = Curve.new()
	
	var cdf_current_sum = 0.0
	var total_weight = 0.0
	
	# Calcul total weight
	for i in p_nb_samples:
		total_weight += clamp(0.0, 1.0, p_pdf_curve.sample(float(i)/(p_nb_samples-1)))
	
	# Fill CDF curve 
	for i in p_nb_samples:
		cdf_current_sum += p_pdf_curve.sample(float(i)/(p_nb_samples-1))/total_weight
		temp_cdf_curve.add_point(Vector2(cdf_current_sum, float(i)/(p_nb_samples-1)))
	
	return temp_cdf_curve
