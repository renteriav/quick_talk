$(document).ready(function(){
  
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
  
  $('#brand_image_header').previewImage(".logo-preview");
	
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

	
	$('#brand_image_avatar').change(function(e) {
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
});  