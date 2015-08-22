$(document).ready(function(){
  
  $('.editable').hover(function(){
    $(this).addClass('grey-border glow');
    //$(this).animate({boxShadow: '0 0 30px #44f'});
  });
  $('.editable').mouseleave(function(){
    $(this).removeClass('glow grey-border');
  });
  
  $('#phone-demo-title').click(function(){
    $('#misc-text-modal').modal('show');
  });
  
  $('.logo-preview').click(function(){
    $('#logo-modal').modal('show');
  });
  
  $('.avatar-preview').click(function(){
    $('#avatar-modal').modal('show');
  });
  
  $('#phone-demo-website').click(function(){
    $('#website-modal').modal('show');
  });
  
  $('#phone-demo-phone').click(function(){
    $('#phone-modal').modal('show');
  });
  
  $('#phone-demo-email').click(function(){
    $('#email-modal').modal('show');
  });
  
  $('#phone-demo-share').click(function(){
    $('#share-modal').modal('show');
  });
  
  $('.done').click(function(){
    $('.modal').modal('hide');
  });
  
	$('#brand_line_one').keypress(function(e){
    var c = String.fromCharCode(e.which)
    if(c.match(/[ -~]/)){
      
      if($('#phone-preview-line-one').width() >= 144 ){
     //alert($('#phone-preview-line-one').width());
      var numberOfChar = $(this).val().length
      //alert(numberOfChar);
      $(this).prop('maxlength', numberOfChar);
      //alert($(this).val().length);
      }
      else{
      $(this).prop('maxlength', 30);
      }
    }
	});
  
	$('#brand_line_two').keypress(function(e){
    var c = String.fromCharCode(e.which)
    if(c.match(/[ -~]/)){
      
      if($('#phone-preview-line-two').width() >= 144 ){
     //alert($('#phone-preview-line-one').width());
      var numberOfChar = $(this).val().length
      //alert(numberOfChar);
      $(this).prop('maxlength', numberOfChar);
      //alert($(this).val().length);
      }
      else{
      $(this).prop('maxlength', 40);
      }
    }
	}); 
  
  $('#brand_line_one').keyup(function(){
    $('#phone-preview-line-one').text($(this).val());
  });
  
  $('#brand_line_two').keyup(function(){
    $('#phone-preview-line-two').text($(this).val());
  });
  
  $('#brand-name-input').keyup(function(){
    $('.logo-preview > h3').text($(this).val());
  });
  
  $('.phone-mask').mask('(999) 999-9999');
  
  $.fn.previewImage = function (imgContainer) {
     	var preview = $(imgContainer);

     	    this.change(function(event){
     	       var input = $(event.currentTarget);
     	       var file = input[0].files[0];
     	       var reader = new FileReader();
     	       reader.onload = function(e){
     	           image_base64 = e.target.result;
                 $(imgContainer + " h3").hide();
                 $(imgContainer + " img").remove();
                 $(imgContainer).append('<img></img>');
     	           $(imgContainer + " img").attr("src", image_base64);
     	       };
     	       reader.readAsDataURL(file);
     	    });
  };
  
  $('#brand_logo_image').previewImage(".logo-preview");
	
	$('#on-board').fileupload({

	dataType: 'script',
		url: "",
		 add: function (e, data) {
		 	$('#submit-butt').click(function(event){
         event.preventDefault();
         data.submit();
				 $('#process-bar').modal('show');
				 
		 	});	              
		 },
	  
		done: function (e, data) {
			
		},
acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|JPG)$/i,
 progressall: function (e, data) {
			        var progress = parseInt(data.loaded / data.total * 100, 10);
			        $('#progress .bar').css(
			            'width',
			            progress + '%'
			        );
					$('.progress-indicator').text(progress + '%')
					
					if (progress == 100){
						$('#onBoardModal-2').modal('hide');
						$('#process-bar').modal('hide');
						$('#onBoardModal-3').modal('show');
					}
			    }
	    
	});
  
	$('#logo-upload-form').fileupload({
    dataType: 'script',
    replaceFileInput:true,
    //fileInput: $("input:file"),
		url: "",
		/*add: function (e, data) {
		 	$('#submit-butt').click(function(event){
         event.preventDefault();
         data.submit();
				 $('#process-bar').modal('show');
				 
		 	});	             
		 },*/
    send:  function (e, data) {
          $('#process-bar').modal('show');
      },
     done: function (e, data) {
      //$('#brand_image_header').replaceWith($("#brand_image_header").html());
     },
     autoUpload: true,
     acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|JPG)$/i,
     progressall: function (e, data) {
       var progress = parseInt(data.loaded / data.total * 100, 10);
			 $('#progress .bar').css('width',progress + '%');
			 $('.progress-indicator').text(progress + '%')

     }   
	});
  
	$('#avatar-upload-form').fileupload({

	dataType: 'script',
		url: "",
		 /*add: function (e, data) {
		 	$('#submit-butt2').click(function(event){
         event.preventDefault();
         data.submit();
				 $('#process-bar').modal('show');
				 
		 	});	              
		 },*/
     send:  function (e, data) {
           $('#process-bar').modal('show');
       },
		done: function (e, data) {
			
		},
acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|JPG)$/i,
 progressall: function (e, data) {
			        var progress = parseInt(data.loaded / data.total * 100, 10);
			        $('#progress .bar').css(
			            'width',
			            progress + '%'
			        );
					$('.progress-indicator').text(progress + '%')

			   }
	    
	});

	
	$('#brand_profile_image').change(function(e) {
		    var file = e.target.files[0];
  			var fileType = file.name.split('.').pop(), allowedTypes = 'jpeg, jpg, JPG, png, gif';
  			 if (allowedTypes.indexOf(fileType)<0){
  				 $('.avatar-preview img').hide();
  				 $('.avatar-preview p').html('<h3><strong class="text-danger">File type not allowed</strong></h3>');
  				 return false;
  			}else{
			 $('.avatar-preview img').hide();
			 $('.avatar-preview p').html('<h3> Processing...</h3>');
				
		    canvasResize(file, {
		          width: 170,
		          height: 170,
		          crop: true,
		          quality: 80,
		          //rotate: 90,
		          callback: function(data, width, height) {
                      var img = new Image();
                      img.onload = function() {
						 $('.avatar-preview img').hide();
						 $('.avatar-preview p').html('');

                         $(this).appendTo('.avatar-preview');

                      };
                      $(img).attr('src', data);
		          }
		    });
		  }
		});
    
    //Tooltipster plugin
    $('#phone-demo-container').tooltipster({
      content: $('<center class="lead" style="padding:20px;">Click on any branding item to edit it.</center>'),
      theme: 'tooltipster-shadow',
      arrow: false,
      offsetY: -260,
      maxWidth: 250,
      timer: 3000,
      functionAfter: function(origin){
        $('#phone-demo-container').tooltipster('disable');
      }
    });
    $('#phone-demo-container').tooltipster('show');
    $('#phone-demo-container').hover(function(){
      $('#phone-demo-container').tooltipster('hide');
    });
});  