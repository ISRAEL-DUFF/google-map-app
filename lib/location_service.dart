import "dart:typed_data";

import "package:http/http.dart" as http;
import "dart:convert" as convert;

class LocationService {
  final String key = 'AIzaSyC8bAiI8yDk5YEQS8VDzMIC-e0E5y446-s';

  Future<List<dynamic>> getPlaces(String input) async {
    String parameters = "query=$input&key=$key";
    String urlPlace = "https://maps.googleapis.com/maps/api/place/textsearch/json?$parameters";

   try {
     var response = await http.get(Uri.parse(urlPlace));

    var json = convert.jsonDecode(response.body);
  
    return json['results'];
   } catch(e) {
    print("Error: $e");
    return [];
   }
  }

  Future<Map<String, dynamic>> getPlaceDetail(String placeId) async {

    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&key=$key";

   try {
     var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    var place = json['result'] as Map<String, dynamic>;

    return place;
   } catch(e) {
    print("Error: $e");
    return {};
   }
  }

  Future<List<Uint8List>> getPlacePhoto(List<String> photoReferences) async {
    List<Uint8List> placePhotos = [];

   try {
    for(var ref in photoReferences) {
      String url = "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${ref}&maxwidth=400&maxheight=200&key=$key";

      var response = await http.get(Uri.parse(url));
      placePhotos.add(Uint8List.fromList(response.body.codeUnits));
    }
    return placePhotos;
   } catch(e) {
    print("Error: $e");
    return [];
   }
  }
}