$(document).ready(function(){
  
  $('.brand_editor .editable').hover(function(){
    $(this).addClass('grey-border glow');
  });
  $('.brand_editor .editable').mouseleave(function(){
    $(this).removeClass('glow grey-border');
  });
  
  $('.brand_editor #phone-demo-title').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#misc-text-modal').modal('show');
  });
  $('#misc-text-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.brand_editor .logo-preview').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#logo-modal').modal('show');
  });
  $('.brand_editor #logo-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.brand_editor .avatar-preview').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#avatar-modal').modal('show');
  });
  $('#avatar-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.brand_editor #phone-demo-website').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#website-modal').modal('show');
  });
  $('#website-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.brand_editor #phone-demo-phone').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#phone-modal').modal('show');
  });
  $('#phone-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.brand_editor #phone-demo-email').click(function(){
    $('#phone-demo-container').tooltipster('disable');
    $('#email-modal').modal('show');
  });
  $('#email-modal').on('hidden.bs.modal', function () {
      $('#phone-demo-container').tooltipster('enable');
  })
  
  $('.done').click(function(){
    $('.modal').modal('hide');
  });
    
  //Onboarding
  
  $('#email-onboard-form .company-name, #email-onboard-form .logo-image').hover(function(){
    $('.logo-preview').addClass('grey-border glow');
  });
  $('#email-onboard-form .company-name, #email-onboard-form .logo-image').mouseleave(function(){
    $('.logo-preview').removeClass('glow grey-border');
  });
  
  $('#email-onboard-form .profile-image').hover(function(){
    $('.avatar-preview').addClass('grey-border glow');
  });
  $('#email-onboard-form .profile-image').mouseleave(function(){
    $('.avatar-preview').removeClass('glow grey-border');
  });
  
  $('#email-onboard-form .company-website').hover(function(){
    $('#phone-demo-website').addClass('grey-border glow');
  });
  $('#email-onboard-form .company-website').mouseleave(function(){
    $('#phone-demo-website').removeClass('glow grey-border');
  });
  
  $('#email-onboard-form .company-phone').hover(function(){
    $('#phone-demo-phone').addClass('grey-border glow');
  });
  $('#email-onboard-form .company-phone').mouseleave(function(){
    $('#phone-demo-phone').removeClass('glow grey-border');
  });
  
  $('#email-onboard-form .company-email').hover(function(){
    $('#phone-demo-email').addClass('grey-border glow');
  });
  $('#email-onboard-form .company-email').mouseleave(function(){
    $('#phone-demo-email').removeClass('glow grey-border');
  });
  
  $('#email-onboard-form .header-line').hover(function(){
    $('#phone-demo-title').addClass('grey-border glow');
  });
  $('#email-onboard-form .header-line').mouseleave(function(){
    $('#phone-demo-title').removeClass('glow grey-border');
  });
  
  
	$('#brand_line_one').keypress(function(e){
    var c = String.fromCharCode(e.which)
    if(c.match(/[ -~]/)){
      
      if($('#phone-preview-line-one').width() >= 133 ){
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
      
      if($('#phone-preview-line-two').width() >= 133 ){
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
    $('.brand_editor ').tooltipster({
      content: $('<center class="lead" style="padding:20px;">Click on any branding item to edit it.</center>'),
      theme: 'tooltipster-shadow',
      arrow: false,
      offsetY: -260,
      maxWidth: 250,
      timer: 3000
    });
    
    $('.brand_editor').tooltipster('show');
    
    $('.brand_editor').mouseleave(function(){
      $('.brand_editor').tooltipster('show');
    });
    
    $('.brand_editor').mouseenter(function(){
      $('.brand_editor').tooltipster('hide');
    });
    
    //validation
    
    $('#email-onboard-form input').tooltipster({ 
          trigger: 'custom',
          onlyOne: false,
          position: 'right',
          theme: 'tooltipster-shadow'
    });
  
    $('#email-onboard-form input').keyup(function(){
      if($(this).val() == ""){
        $(this).tooltipster('hide');
      } 
      });
    
    $( "#brand-form, #on-board, #email-onboard-form" ).validate({
      rules:{
        'onboard_phone':{
          phoneUS:true,
          required:false
        },
      
        'brand[brand_phone]':{
          phoneUS:true,
          required:false
        },
        'brand[brand_email]':{
          email:true,
          required:false
        },
        'brand[brand_web_site]':{
          required:false
        },
      },
      messages: {
        'brand[brand_web_site]': {
          url: 'Please enter a valid URL including "http:// or https://"'
        }
      },
      errorPlacement: function (error, element) {
              $(element).tooltipster('update', $(error).text());
              $(element).tooltipster('show');
          },
      success: function (label, element) {
            $(element).tooltipster('hide');     
         }
     });
   
     $('#email-onboard-submit').click(function(){
       if ($('#email-onboard-form').valid()){
         $('#email-onboard-form input').tooltipster('hide');
        $('#email-onboard-modal').modal('show'); 
        //$('#email-onboard-form').submit();
       }
       else{
         return false;
       }
     });
     
     $('#email-onboard-continue').click(function(){
   		$('#wrapper').waitMe({
   			effect: 'roundBounce',
   			text: 'Please wait...',
   			bg: 'rgba(255,255,255,0.7)',
   			color:'#0f0f0f',
   			sizeW:'',
   			sizeH:'',
   			//source: 'img.svg'
   		});
       $('#email-onboard-form').submit();
     });
});  