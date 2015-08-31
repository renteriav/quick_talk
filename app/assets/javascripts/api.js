$(document).ready(function(){  
    
    $("#submit").click(function(){
      var login = $("#email").val();
      var password = $("#password").val();
      var companyName = $("#company-name").val();
      var first = $("#first").val();
      var last = $("#last").val();
      var phone = $("#phone").val();
      var token = $("#token").val();
      var data =  "email="+login+"&phone="+phone+"&password="+password+"&company_name="+companyName+"&first="+first+"&last="+last+"&token="+token
      $.ajax({
          type: "POST",
          url: "/api/v1/accountants",

          data: data,
          dataType: "json",
          success: function(json){
            var output =
             '';
            for (var entry in json) {
              output += 'key: ' + entry + ' | value: ' + json[entry] + '\n';
            }
            alert(output);
          },
          failure: function(errMsg) {
              alert(errMsg);
          }
      });
      
    });
    
});