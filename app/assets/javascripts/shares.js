$(document).ready(function(){
  
  $('#share-form input').tooltipster({ 
        trigger: 'custom',
        onlyOne: false,
        position: 'top-left',
        theme: 'tooltipster-shadow'
  });
    
  $( "#share-form" ).validate({
    rules:{
      'share[phone]':{
        phoneUS:true,
        required:true
      }
    },
    onkeyup: false,
    errorPlacement: function (error, element) {
            $(element).tooltipster('update', $(error).text());
            $(element).tooltipster('show');
    },
    success: function (label, element) {
          $(element).tooltipster('hide');     
    }
    
  });
  
  //$('#submit').click(function(){
  //  if ($('#share-form').valid()){
  //    alert('valid');
  //    $('#share-form input').tooltipster('hide');
   // }
  //});
   
});