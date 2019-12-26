var port = process.env.PORT || 3000;
var express = require('express');
var bodyParser = require('body-parser');
var path = require('path');
var request = require('sync-request');
var urlencode = require('urlencode');
const key = "<Google api key>";
const yelpKey = "<>Yelp Fusion API Key"

var app = express();

// Body Parser Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

app.get('/search', function(req, res){
	try{
		var keyword = req.query.keyword;
		var category = req.query.category;
		var distance = req.query.distance;
		var location = req.query.location;
		var lat = req.query.currentLocation.lat;
		var lng = req.query.currentLocation.lng;
		var customLocation = req.query.customLocation;
		
		if(location=="other"){
			//Fetch the location
			data = request("GET", "https://maps.googleapis.com/maps/api/geocode/json?address=" + urlencode(customLocation) + "&key=" + key);
			response = JSON.parse(data.getBody().toString('utf8'));

			if(response.hasOwnProperty("results")){
				lat = response.results[0].geometry.location.lat;
				lng = response.results[0].geometry.location.lng;
			} else {
				console.log(1);
				console.log(response);
				res.status(400).send("Error");
			}
		}

		distance *= 1609.34;
		var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat + "," + lng + "&radius=" + distance + 
			"&keyword=" + urlencode(keyword) + "&key=" + key;
		if(category.length>0){
			url += "&type=" + category;
		}
		data = request("GET", url);
		response = JSON.parse(data.getBody().toString('utf8'));

		if(response.hasOwnProperty("results")){
			res.send(response);
		} else {
			console.log(2);
			console.log(response);
			res.status(400).send("Error");
		}
	} catch(e) {
		console.log(3);
		console.log(e);
		res.status(400).send("Error");
	}
});

app.get('/nextPage', function(req, res){
	try{
		var next_page_token = req.query.next_page_token;

		var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=" + next_page_token + "&key=" + key;
		data = request("GET", url);
		response = JSON.parse(data.getBody().toString('utf8'));

		if(response.hasOwnProperty("results")){
			res.send(response);
		} else {
			console.log(response);
			res.status(400).send("Error");
		}
	} catch(e) {
		console.log(e);
		res.status(400).send("Error");
	}
});

app.get('/yelp', function(req, res){
	try{
		var name = req.query.name;
		var address = req.query.address;
		var city = req.query.city;
		var state = req.query.state;
		var country = req.query.country;
		var lat = req.query.lat;
		var lng = req.query.lng;
		var post = req.query.post;

		var url = "https://api.yelp.com/v3/businesses/matches/best?name=" + urlencode(name) + "&address1=" + urlencode(address) + 
		"&city=" + urlencode(city) + "&state=" + urlencode(state) + "&country=" + country + "&latitude=" + lat + "&longitude=" + lng + "&postal_code=" + post;

		var header = {
			headers: {
				'Authorization': 'Bearer ' + yelpKey,
			}
		};

		data = request("GET", url, header);
		response = JSON.parse(data.getBody().toString('utf8'));

		result = [];
		console.log(data.getBody().toString('utf8'));

		if(response.hasOwnProperty("businesses") && response["businesses"].length>0) {
			var url = "https://api.yelp.com/v3/businesses/" + response.businesses[0].id + "/reviews";

			var header = {
				headers: {
					'Authorization': 'Bearer ' + yelpKey,
				}
			};

			data = request("GET", url, header);
			response = JSON.parse(data.getBody().toString('utf8'));

			console.log(data.getBody().toString('utf8'));

			if(response.hasOwnProperty("reviews")) {
				for(index in response.reviews) {
					let review = response.reviews[index];
					result.push({
						profile_photo_url: review.user.image_url,
						author_url: review.url,
						author_name: review.user.name,
						rating: review.rating,
						text: review.text,
						time: (new Date(review)).getTime()/1000
					});
				}
			} else {
				console.log(response);
				res.status(400).send("Error");		
				return;
			}
		}

		res.send(result);
	} catch(e) {
		console.log(e);
		res.status(400).send("Error");
	}
});

//Set static path
app.use(express.static(path.join(__dirname, 'public')));


app.listen(port, function(){
	console.log("server started on port " + port);
});