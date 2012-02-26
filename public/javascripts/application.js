// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function custom_ajax_before(event){
  var element = event.findElement(),
      inputs = element.select("input[type=submit][data-disable-with]");
  inputs.each(function(input) {
    input.value = input.readAttribute('data-disable-with');
    input.disabled = true;
  });
}

function custom_ajax_after(event, element){
  //Do nothing 
}