<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="pangyo party" />
    <title> simple dx_line </title>

    <link href="static/css/bootstrap.css" rel="stylesheet" />
    <!-- FONT AWESOME  CSS -->
    <link href="static/css/font-awesome.css" rel="stylesheet" />
    <!-- CUSTOM STYLE CSS -->
    <link href="static/css/style.css" rel="stylesheet" />

</head>

<!-- USING SCRIPTS BELOW TO REDUCE THE LOAD TIME -->
<!-- CORE JQUERY SCRIPTS FILE -->
<script src="static/js/jquery-1.11.1.js"></script>

<!-- CORE BOOTSTRAP SCRIPTS  FILE -->
<script src="static/js/bootstrap.js"></script>
				  
<script src="https://js.pusher.com/3.2/pusher.min.js"></script>		

<script>
	function reload_tweets(json_tweets, scroll_bottom) {
		tweets = JSON.parse(json_tweets);
		$('#tweet_div').empty();

		var i;
		for ( i=0; i<tweets.length ; i++)
		{
			$('#tweet_div')
			.append('<div class="chat-box-left"  style="padding:10px; "> '
			+ '<strong>' + tweets[i].message + '</strong>'+ ' - ' 
			+ '<small>' + tweets[i].user.ip	+ '</small>'
			+ ' </div>');	
		}
		
		if (scroll_bottom)
		{
			var out = document.getElementById("tweet_div");
			out.scrollTop = out.scrollHeight - out.clientHeight;
		}
	}

	function load_tweet() {
		$.ajax({
			type: "GET",
			url: "/tweet",
	//		data: lastSeq:, // serializes the form's elements.
			success: function(ajax_response)
			{
//				alert(data); // show response from the php script.

				if (ajax_response['isSuccessful'] == 'success')
				{
					reload_tweets(ajax_response['tweets'], true);
				}
				else {
					alert("failed to load tweets");
				}

			}
		});
	}

</script>

<body onload="load_tweet();">


    <div class="container">
        <div class="row pad-top pad-bottom">


            <div class=" col-lg-6 col-md-6 col-sm-6" style="width:90%; max-height:400px;">
                <div class="chat-box-div" style="width:90%;">
                    <div class="chat-box-head">
                        채팅
                            <div class="btn-group pull-right">
								<!--
                                <button type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <span class="fa fa-cogs"></span>
                                    <span class="sr-only">Toggle Dropdown</span>
                                </button>
								-->
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#"><span class="fa fa-map-marker"></span>&nbsp;Invisible</a></li>
                                    <li><a href="#"><span class="fa fa-comments-o"></span>&nbsp;Online</a></li>
                                    <li><a href="#"><span class="fa fa-lock"></span>&nbsp;Busy</a></li>
                                    <li class="divider"></li>
                                    <li><a href="#"><span class="fa fa-circle-o-notch"></span>&nbsp;Logout</a></li>
                                </ul>
                            </div>
                    </div>

                    <div id="tweet_div" class="panel-body chat-box-main">
		


							<!--
							<div class="chat-box-name-left">
<!--								<img src="assets/img/user.png" alt="bootstrap Chat box user image" class="img-circle" /> --

								-  Need user info
							</div>
							-->
							<!--
							<hr class="hr-clas" />
							-->

                    </div>
                    <div class="chat-box-footer">
						<form name="myForm" id="writeForm" method="POST" action="/tweet" accept-charset="UTF-8">

                        <div class="input-group">
                            <input type="text" name="message" class="form-control" placeholder="Enter Text Here...">
                            <span class="input-group-btn">
                                <button class="btn btn-info" type="submit">SEND</button>
                            </span>
                        </div>

						</form>
                    </div>

                </div>

            </div>

			<!--
            <div class="col-lg-3 col-md-3 col-sm-3">
                <div class="chat-box-online-div">
                    <div class="chat-box-online-head">
                        ONLINE USERS (120)
                    </div>
                    <div class="panel-body chat-box-online">

                        <div class="chat-box-online-left">
                            <img src="assets/img/user.png" alt="bootstrap Chat box user image" class="img-circle" />
                            -  Justine Goliyad
                            <br />
                            ( <small>Active from 3 hours</small> )
                        </div>
                        <hr class="hr-clas-low" />

                    </div>

                </div>
            </div>
			-->

        </div>
    </div>

	<script>

	// Enable pusher logging - don't include this in production
	Pusher.logToConsole = false;

	var pusher = new Pusher('37bb3952bcef157d7b44', {
		encrypted: true
	});

	var channel = pusher.subscribe('tweet');
	channel.bind('post_tweet', function(data) {
//		alert(data.message);
		console.log(data);

		$.ajax({
			type: "GET",
			url: "/tweet",
	//		data: lastSeq:, // serializes the form's elements.
			success: function(ajax_response)
			{
				reload_tweets(ajax_response['tweets'], false);
			}
		});
	});


	</script>	
	  
	  <script>
	
		$("#writeForm").submit(function(e) {
			var url = "/tweet"; // the script where you handle the form input.

			console.log($("#writeForm").serialize());

			$.ajax({
				   type: "POST",
				   url: url,
				   data: $("#writeForm").serialize(), // serializes the form's elements.
				   success: function(ajax_response)
				   {
						reload_tweets(ajax_response['tweets'], true);
						$(this).closest('form').find("input[type=text], textarea").val("");
				   }
				 });

			e.preventDefault(); // avoid to execute the actual submit of the form.
		});
	

	var out = document.getElementById("tweet_div");
	var add = setInterval(function() {
		// allow 1px inaccuracy by adding 1
		var isScrolledToBottom = out.scrollHeight - out.clientHeight <= out.scrollTop + 1;
		console.log(out.scrollHeight - out.clientHeight,  out.scrollTop + 1);
		// scroll to bottom if isScrolledToBotto
		console.log(isScrolledToBottom);
		if(isScrolledToBottom)
		  out.scrollTop = out.scrollHeight - out.clientHeight;
	}, 1000);

	</script>

</body>
</html>
