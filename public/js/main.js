var app = angular.module("myApp", ["ngAnimate"]);

app.constant('key', '<Google Maps Key>');

// Ajax Service
app.service("getData", function($http) {
    this.fetchLocation = function(success, failure) {
        $http({
            method: "GET",
            url: "http://ip-api.com/json"
        }).then(function successCallback(response) {
            success(response.data);
        }, function errorCallback(response) {
            failure(response.data);
        });
    };

    this.getResults = function(url, data, success, failure) {
        $http({
            method: data != null ? "POST" : "GET",
            url: url,
            data: data
        }).then(function successCallback(response) {
            success(response.data);
        }, function errorCallback(response) {
            failure(response.data);
        });
    };
});

// Result table directive
app.directive("resultTable", function() {
    return {
        restrict: "E",
        templateUrl: "resultTable.html"
    };
});

// Particular place directive
app.directive("placeDetails", function() {
    return {
        restrict: "E",
        templateUrl: "placeDetails.html"
    };
});

// Main Controller
app.controller("myCtrl", function($scope, getData) {
    // Reset the general data
    let resetGeneralFunction = {};

    resetGeneralFunction.searchForm = function(loc) {
        $scope.data = {
            keyword: "",
            category: "default",
            distance: "",
            location: "current",
            currentLocation: loc,
            customLocation: "",
            keywordError: false,
            otherLocationError: false
        };
    };
    resetGeneralFunction.formFlags = function() {
        $scope.flags = {
            noRecords: false,
            loadBarVisible: false,
            loaderBarProgress: "0%",
            tabType: 1,
            error: false
        };
    };
    resetGeneralFunction.codePortion = function() {
        // Code portion visibility flags
        $scope.codePortionFlags = {
            placeResultsVisible: false,
            specificPlaceDetails: false
        };
    };
    resetGeneralFunction.placeResults = function(places) {
        // Places result Object
        $scope.placeResults = {
            total: places == null ? [] : places,
            next: null,
            currentActive: 0
        };
    };
    resetGeneralFunction.reviews = function(data) {
        // Review Tab flags
        $scope.reviews = {
            reviewsType: "google",
            reviewsOrder: "default",
            data: {
                "google": data
            }
        };
    };
    resetGeneralFunction.specificPlaceData = function(data) {
        $scope.specificPlace = {
            data: data,
            info: data != null ? true : false,
            photos: false,
            map: false,
            reviews: false
        };
    };
    $scope.maps = {
        viewType: true,
        from: "",
        to: "",
        mode: "driving"
    };

    let mapsServices = {
        service: null,
        display: null,
        marker: null
    };

    //Initialize the space to store the results
    let temporaryStoragePlaceResults = {};

    // Store the data values of the form
    resetGeneralFunction.searchForm(null);

    // Store the flags to various items
    resetGeneralFunction.formFlags();

    // Set the flags for the code portions or the directives
    resetGeneralFunction.codePortion();

    // Set the data container for the result-table directive
    resetGeneralFunction.placeResults();

    // Default null for a specific place details
    resetGeneralFunction.specificPlaceData(null);

    // Fetch the ip location
    getData.fetchLocation(function(data) {
        $scope.data.currentLocation = {
            lat: data.lat,
            lng: data.lon
        };
    }, function() { $scope.flags.error = true; });

    // Validation function
    $scope.validate = function(arg) {
        if (arg == 1) {
            let value = $scope.data.keyword;
            if (value.trim().length == 0) {
                $scope.data.keywordError = true;
            } else {
                $scope.data.keywordError = false;
            }
        } else if (arg == 2) {
            let value = $scope.data.customLocation;
            if (value.trim().length == 0) {
                $scope.data.otherLocationError = true;
            } else {
                $scope.data.otherLocationError = false;
            }
        }
    };

    $scope.reset = function() {
        // Store the data values of the form
        resetGeneralFunction.searchForm($scope.data.currentLocation);

        // Store the flags to various items
        resetGeneralFunction.formFlags();

        // Set the flags for the code portions or the directives
        resetGeneralFunction.codePortion();

        // Set the data container for the result-table directive
        resetGeneralFunction.placeResults();

        // Default null for a specific place details
        resetGeneralFunction.specificPlaceData(null);

        temporaryStoragePlaceResults = {};
    };

    $scope.locationTrigger = function() {
        $scope.data.otherLocationError = false;
    };

    $scope.tabChange = function(tab) {
        if ($scope.flags.tabType != tab) {
            resetGeneralFunction.formFlags();
            resetGeneralFunction.codePortion();

            if (tab == 1) {
                // Bring back the search results
                $scope.placeResults = temporaryStoragePlaceResults;

                // Check if there were any results
                if ($scope.placeResults.total.length == 0) {
                    $scope.flags.noRecords = true;
                } else {
                    $scope.codePortionFlags.placeResultsVisible = true;
                }

            } else {
                // Store the results
                temporaryStoragePlaceResults = $scope.placeResults;

                // Check if browser supports storage
                if (typeof(Storage) !== "undefined") {
                    let data = localStorage.getItem("favorite");

                    if (data != null && JSON.parse(data).length > 0) {
                        data = JSON.parse(data);

                        resetGeneralFunction.placeResults(data);
                        $scope.codePortionFlags.placeResultsVisible = true;
                    } else {
                        $scope.flags.noRecords = true;
                    }
                } else {
                    // Browser doesn't support local storage
                    resetGeneralFunction.formFlags();
                    resetGeneralFunction.codePortion();
                    $scope.flags.error = true;
                }
            }

            // Activate Tab
            $scope.flags.tabType = tab;
        } else {
            // Fall back from details page
            if ($scope.codePortionFlags.specificPlaceDetails) {
                let tab = $scope.flags.tabType;
                resetGeneralFunction.formFlags();
                $scope.flags.tabType = tab;
                resetGeneralFunction.codePortion();
                if ($scope.placeResults.total.length == 0) {
                    $scope.flags.noRecords = true;
                } else {
                    $scope.codePortionFlags.placeResultsVisible = true;
                }
            }
        }
    };

    $scope.search = function() {
        // Bring page to reset state
        resetGeneralFunction.formFlags();
        resetGeneralFunction.codePortion();

        // Make load bar visible
        $scope.flags.loadBarVisible = true;

        // Reset any previous place details data
        resetGeneralFunction.specificPlaceData(null);

        $scope.data.customLocation = document.getElementById("otherLocation").value;

        let query = "?keyword=" + encodeURI($scope.data.keyword);
        query += "&category=" + ($scope.data.category == 'default' ? '' : $scope.data.category);
        query += "&distance=" + ($scope.data.distance.trim().length == 0 ? 10 : $scope.data.distance);
        query += "&location=" + $scope.data.location;
        query += "&currentLocation[lat]=" + $scope.data.currentLocation.lat + "&currentLocation[lng]=" +$scope.data.currentLocation.lng;
        query += "&customLocation=" + encodeURI($scope.data.customLocation);

        $scope.flags.loaderBarProgress = "50%";

        getData.getResults("/search" + query, null, function(data) {
            if (data.hasOwnProperty("results")) {
                $scope.flags.loaderBarProgress = "100%";

                if (data.results.length > 0) {
                    resetGeneralFunction.placeResults(data.results);

                    if (data.hasOwnProperty("next_page_token")) {
                        $scope.placeResults.next = data.next_page_token;
                    }

                    $scope.codePortionFlags.placeResultsVisible = true;

                    // Initialize the autocomplete
                    new google.maps.places.Autocomplete(document.getElementById("mapInput"));
                } else {
                    $scope.flags.noRecords = true;
                }
            } else {
                $scope.flags.error = true;
            }

            //Reset Load Bar
            $scope.flags.loadBarVisible = false;
        }, function() {
            //Reset Load Bar
            $scope.flags.loadBarVisible = false;
            $scope.flags.error = true;
        });
    };

    $scope.page = function(count) {
        if ($scope.placeResults.total.length > ($scope.placeResults.currentActive + count) * 20) {
            $scope.placeResults.currentActive += count;
        } else {
            let query = "?next_page_token=" + $scope.placeResults.next;
            getData.getResults("/nextPage" + query, null, function(data) {
                if (data.hasOwnProperty("results")) {
                    if (data.results.length > 0) {
                        // Place new data
                        $scope.placeResults.total = $scope.placeResults.total.concat(data.results);
                        $scope.placeResults.currentActive += count;

                        if (data.hasOwnProperty("next_page_token")) {
                            $scope.placeResults.next = data.next_page_token;
                        } else {
                            $scope.placeResults.next = null;
                        }
                    } else {
                        resetGeneralFunction.codePortion();
                        $scope.flags.error = true;
                    }
                } else {
                    resetGeneralFunction.codePortion();
                    $scope.flags.error = true;
                }
            }, function() {
                resetGeneralFunction.formFlags();
                resetGeneralFunction.codePortion();
                $scope.flags.error = true;
            });
        }
    }

    $scope.fetchPlaceDetails = function(placeObject) {
        // Switch on the details view
        resetGeneralFunction.codePortion();

        // If its already highlighted
        if ($scope.specificPlace.data == null || placeObject.place_id != $scope.specificPlace.data.place_id) {
            $scope.specificPlace.data = null;

            var map = new google.maps.Map(document.getElementById('map'), {
                center: { lat: placeObject.geometry.location.lat, lng: placeObject.geometry.location.lng },
                zoom: 15
            });

            var service = new google.maps.places.PlacesService(map);

            service.getDetails({
                placeId: placeObject.place_id
            }, function(place, status) {
                if (status === google.maps.places.PlacesServiceStatus.OK) {
                    var marker = new google.maps.Marker({
                        map: map,
                        position: place.geometry.location
                    });

                    $scope.$apply(function() {
                        resetGeneralFunction.specificPlaceData(place);

                        $scope.maps.viewType = true;
                        $scope.maps.from = $scope.data.location == "current" ? "Your location" : $scope.data.customLocation;
                        $scope.maps.to = $scope.specificPlace.data.name + ", " + $scope.specificPlace.data.formatted_address;
                        $scope.maps.mode = "DRIVING";
                        mapsServices.service = new google.maps.DirectionsService;
                        mapsServices.display = new google.maps.DirectionsRenderer({
                            map: map,
                            panel: document.getElementById('directionInstructions')
                        });
                        mapsServices.marker = marker;

                        // Initialize the reviews
                        resetGeneralFunction.reviews(place.hasOwnProperty("reviews") ? place.reviews : []);

                        // Clear the directions container
                        document.getElementById("directionInstructions").innerHTML = "";

                        $scope.codePortionFlags.specificPlaceDetails = true;
                    });
                }
            });
        } else {
            $scope.codePortionFlags.specificPlaceDetails = true;

            if($scope.specificPlace.photos && !$scope.specificPlace.data.hasOwnProperty("photos")) {
                $scope.flags.noRecords = true;
            } else if ($scope.specificPlace.reviews && $scope.reviews.data[$scope.reviews.reviewsType].length==0) {
                $scope.flags.noRecords = true;
            }
        }
    };

    $scope.showRecentDetails = function() {
        // Switch on the details view
        $scope.codePortionFlags.placeResultsVisible = false;
        $scope.codePortionFlags.specificPlaceDetails = true;

        if($scope.specificPlace.photos && !$scope.specificPlace.data.hasOwnProperty("photos")) {
            $scope.flags.noRecords = true;
        } else if ($scope.specificPlace.reviews && $scope.reviews.data[$scope.reviews.reviewsType].length==0) {
            $scope.flags.noRecords = true;
        }
    };

    $scope.getArrayCollection = function(number) {
        return new Array(Math.ceil(number));
    };

    $scope.getWidth = function(index, rating) {
        let width = 13.34;
        if (index > parseInt(rating)) {
            width = width * (rating - index + 1);
        }
        return { "width": width + "px" };
    };

    $scope.returnList = function() {
        // Switch on the details view
        $scope.tabChange($scope.flags.tabType);
    };

    $scope.getSRC = function(imageObj) {
        if (imageObj != undefined) {
            return imageObj.getUrl({ 'maxWidth': 2000, 'maxHeight': 2000 });
        } else {
            return "";
        }
    };

    $scope.detailsTab = function(key) {
        if ($scope.specificPlace[key] != true) {
            $scope.specificPlace.info = false;
            $scope.specificPlace.photos = false;
            $scope.specificPlace.map = false;
            $scope.specificPlace.reviews = false;

            if ((key == "photos" || key == "reviews") && !$scope.specificPlace.data.hasOwnProperty(key)) {
                $scope.flags.noRecords = true;
            } else if(key == "reviews" && $scope.reviews.data[$scope.reviews.reviewsType].length==0){
                $scope.flags.noRecords = true;
            } else {
                $scope.flags.noRecords = false;
            }

            $scope.specificPlace[key] = true;
            $scope.flags.error = false;
        }
    }

    // Trigger storing and removing of the favorites
    $scope.store = function(object) {
        if (typeof(Storage) !== "undefined") {
            let data = localStorage.getItem("favorite");
            let keys = localStorage.getItem("keys");

            if (data != null) {
                data = JSON.parse(data);
                keys = JSON.parse(keys);

                // Check insertion or deletion
                if (keys.hasOwnProperty(object.place_id)) {
                    delete keys[object.place_id];

                    for (i = 0; i < data.length; i++) {
                        let obj = data[i];
                        if (obj.place_id == object.place_id) {
                            data.splice(i, 1);
                        }
                    }

                    // Update the page only when Favorite Tab is on
                    if ($scope.flags.tabType == 2) {
                        // Update the list of the favorites
                        $scope.placeResults.total = data;
                        if (data.length == 0 && !$scope.codePortionFlags.specificPlaceDetails) {
                            $scope.flags.noRecords = true;
                            resetGeneralFunction.codePortion();
                        }
                    }

                } else {
                    // Storage
                    data.push(object);
                    keys[object.place_id] = true;
                }

            } else {
                //New entry
                data = [object];
                keys = {};
                keys[object.place_id] = true;
            }

            localStorage.setItem("favorite", JSON.stringify(data));
            localStorage.setItem("keys", JSON.stringify(keys));
        } else {
            resetGeneralFunction.formFlags();
            resetGeneralFunction.codePortion();
            $scope.flags.error = true;
        }
    };

    $scope.checkFavIcon = function(object) {
        if (object != null && object != undefined) {
            if ($scope.flags.tabType == 2 && !$scope.codePortionFlags.specificPlaceDetails) {
                return "fas fa-trash-alt black";
            } else {
                let keys = localStorage.getItem("keys");

                if (keys != null) {
                    keys = JSON.parse(keys);

                    // Check insertion or deletion
                    if (keys.hasOwnProperty(object.place_id)) {
                        return "fas fa-star yellow";
                    }
                }

                return "far fa-star black";
            }
        }
        return "";
    };

    $scope.getTweetUrl = function() {
        let obj = $scope.specificPlace.data;
        if (obj != null && obj != undefined) {
            let content = "Check out " + obj.name + " located at " + obj.formatted_address + ". Website: "
            if (obj.hasOwnProperty('website')) {
                content += "&url=" + obj.website;
            } else {
                content += "&url=" + obj.url;
            }
            content += "&hashtags=TravelAndEntertainmentSearch";

            return "https://twitter.com/intent/tweet?text=" + encodeURI(content);
        }
        return "";
    };

    $scope.getFormattedTime = function(arg) {
        return moment().format("YYYY-MM-DD HH:mm:ss");
    };

    $scope.getWeekDayIndex = function(offset) {
        offset = (offset==null || offset==undefined)?0:offset;
        offset = moment().utcOffset() - offset;

        if (offset < 16 && offset > -16) {
            offset /= 60;
        }

        return (moment().utcOffset(-offset).weekday() + 6) % 7;
    };

    $scope.getTodayHours = function(object) {
        let offset = 0;

        if (object.hasOwnProperty("utc_offset")) {
            offset = object.utc_offset;
        }

        let text = object.opening_hours.weekday_text[$scope.getWeekDayIndex(offset)];

        return text.slice(text.indexOf(":") + 1);

    };

    $scope.getOrder = function(review) {
        switch ($scope.reviews.reviewsOrder) {
            case "highest":
                return parseInt(review.rating);
            case "lowest":
                return parseInt(review.rating);
            case "most":
                return parseInt(review.time);
            case "least":
                return parseInt(review.time);
            default:
                return null;
        }
    };

    $scope.changeReviews = function() {
        if ($scope.reviews.reviewsType == "yelp" && !$scope.reviews.data.hasOwnProperty("yelp")) {
            let address = $scope.specificPlace.data.vicinity;
            let addArray = $scope.specificPlace.data.address_components;
            let addArrayLength = addArray.length-1;

            let post = addArray[addArrayLength].types[0]=="postal_code"?addArray[addArrayLength].short_name: addArray[--addArrayLength].short_name;
            addArrayLength--;
            let country = addArray[addArrayLength--].short_name;
            let state = addArray[addArrayLength--].short_name;
            let city = addArray[addArrayLength--].short_name;

            let query = "?name=" + encodeURI($scope.specificPlace.data.name);
            query += "&address=" + encodeURI(address);
            query += "&city=" + encodeURI(city);
            query += "&state=" + encodeURI(state);
            query += "&country=" + encodeURI(country);
            query += "&lat=" + $scope.specificPlace.data.geometry.location.lat();
            query += "&lng=" + $scope.specificPlace.data.geometry.location.lng();
            query += "&post=" + post;

            getData.getResults("/yelp" + query, null, function(data) {
                if (data instanceof Array) {
                    $scope.reviews.data.yelp = data;
                    if ($scope.reviews.data.yelp.length == 0) {
                        $scope.flags.noRecords = true;
                    } else {
                        $scope.flags.noRecords = false;
                    }
                } else {
                    $scope.flags.error = true;
                }
            }, function() {
                $scope.flags.error = true;
            });
        } else if($scope.reviews.data[$scope.reviews.reviewsType].length==0) {
            $scope.flags.noRecords = true;
            $scope.flags.error = false;
        } else {
            $scope.flags.noRecords = false;
            $scope.flags.error = false;
        }
    };

    $scope.renderPhoto = function(rem) {
        return function(imgObject) {
            let i = $scope.specificPlace.data.photos.indexOf(imgObject);
            if (i % 4 == rem) {
                return true;
            }
            return false;
        }
    };

    $scope.viewType = function() {
        if ($scope.maps.viewType) {
            return "./images/Pegman.png";
        } else {
            return "./images/Map.png"
        }
    };

    $scope.changeMapView = function() {
        $scope.maps.viewType = !$scope.maps.viewType;

        let position = { lat: $scope.specificPlace.data.geometry.location.lat(), lng: $scope.specificPlace.data.geometry.location.lng() };

        if ($scope.maps.viewType) {
            let map = new google.maps.Map(document.getElementById('map'), {
                center: position,
                zoom: 15
            });

            mapsServices.display = new google.maps.DirectionsRenderer({
                map: map,
                panel: document.getElementById('directionInstructions')
            });

            let marker = new google.maps.Marker({
                map: map,
                position: position
            });

            mapsServices.marker = marker;
        } else {
            new google.maps.StreetViewPanorama(document.getElementById('map'), {
                position: position,
                pov: {
                    heading: 0,
                    pitch: 5
                }
            });
        }
    };

    $scope.getDirections = function() {
        //Patch to link up the auto complete
        $scope.maps.from = document.getElementById("mapInput").value;
        let origin = ($scope.maps.from.trim().toLowerCase()=="your location" || $scope.maps.from.trim().toLowerCase()=="my location")?$scope.data.currentLocation:$scope.maps.from.trim();

        if(!$scope.maps.viewType){
            $scope.changeMapView();
        }

        mapsServices.service.route({
            origin: origin,
            destination: {lat: $scope.specificPlace.data.geometry.location.lat(), lng: $scope.specificPlace.data.geometry.location.lng()},
            provideRouteAlternatives: true,
            travelMode: $scope.maps.mode,
        }, function(response, status) {
            if (status === 'OK') {
                document.getElementById("directionInstructions").innerHTML = "";
                mapsServices.display.setDirections(response);
                mapsServices.marker.setMap(null);
            } else {
                $scope.flags.error = true;
            }
        });
    };

});

function initMap() {
    new google.maps.places.Autocomplete(document.getElementById("otherLocation"));
}