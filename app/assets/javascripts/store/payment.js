$(function(){
	$('.cards a').click(function(e){
		var card = $(this).data('card');
		var option = $('#payment option:contains('+ card +')');
		option.attr('selected', true);
		e.preventDefault();
	});
});
