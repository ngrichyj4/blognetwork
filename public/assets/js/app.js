/*
     $('a#runtask').bind('click',function(event){
      event.preventDefault();
     
        $.get(this.href,{},function(response){ 
              $('a#runtask').text("Sent.");
            }
            
        });  
     });
*/

$(document).ready(function(){

	$("#runtask").click(function() {
	 
		$.ajax({
		    	type: "POST",
			    url: "/task/run", 
			    data: {request: this.href},

			    success: function(data) {
					$("#runtask").text("load more...");
				
			    },  
			    dataType: "json"
			});
			event.preventDefault();
    	});
	});	