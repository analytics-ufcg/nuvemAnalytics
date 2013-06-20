var lowerBound = new Date(1950, 1, 1, 0, 0, 0, 0);
var now = new Date();
var upperBound = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);

var start_field = $("#start_date_wrapper").datepicker({
	onRender : function(date) {
		return date.valueOf() <= lowerBound.valueOf() || date.valueOf() > upperBound.valueOf() ? 'disabled' : '';
	}
}).on('changeDate', function(ev) {
	if ( ev.date.valueOf() > end_field.date.valueOf() ){
		var newDate = new Date(ev.date);
		newDate.setDate(newDate.getDate() + 1);
		end_field.setValue(newDate);
	}
}).data('datepicker');

$("#start_date_wrapper").datepicker('setValue', lowerBound);
$("#start_date").click(function() {
	$("start_date_wrapper").datepicker('show');
});

$("#start_time").timepicker({
	showMeridian : false,
	showInputs: false,
	minuteStep : 5,
	defaultTime : "00:00 AM"
});

var end_field = $("#end_date_wrapper").datepicker({
	onRender : function(date) {
		return date.valueOf() <= start_field.date.valueOf() || date.valueOf() > upperBound.valueOf() ? 'disabled' : '';
	}
}).data('datepicker');

$("#end_date_wrapper").datepicker('setValue', upperBound);
$("#end_date").click(function() {
	$("end_date_wrapper").datepicker('show');
});

$("#end_time").timepicker({
	showMeridian : false,
	showInputs: false,
	minuteStep : 5
});
