import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_map_app/location_service.dart';

class _PlaceDetailsState extends State<PlaceDetails> {
  bool isLoading = true;
  List<Uint8List> photoDataList = [];
  dynamic placeDetail = {};
  @override
  void initState() {
    LocationService().getPlaceDetail(widget.placeId).then((detail) {
      List<dynamic> photoRefs = detail["photos"] ?? [];
      List<String> refList = [];
      for (var photoRef in photoRefs) {
        refList.add(photoRef['photo_reference'] as String);
      }
      LocationService().getPlacePhoto(refList).then((photos) {
        setState(() {
          isLoading = false;
          photoDataList = photos;
          placeDetail = detail;
        });
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Place Details"),
      // ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(children: [
        _photos,
        _placeTitle,
        _placeDescription,
      Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(onPressed: () {
        Navigator.of(context).pop();
      }, child: const Text("Back Home")),)
    ],)),);
  }

  Widget get _photos {
    if (photoDataList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Icon(Icons.broken_image),
        Text("No Images")
      ],));
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: MediaQuery.of(context).size.height * 0.6,
      child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        crossAxisCount: 2,
      ),
      itemCount: photoDataList.length,
      itemBuilder: (context, index) {
        return Image.memory(photoDataList[index]);
      },
    ),);
  }

  Widget get _placeDescription {
    TextStyle style = const TextStyle(fontSize: 10,);
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description"),
        const SizedBox(height: 2,),
        Text(placeDetail["name"] ?? "", style: style),
        const SizedBox(height: 2,),
        Text(placeDetail['formatted_address'] ?? "", style: style),
        const SizedBox(height: 2,),
        Text(placeDetail['vicinity'] ?? "", style: style),
        const SizedBox(height: 2,),
        Text(placeDetail['website'] ?? "", style: style)
      ],
    ),);
  }

  Widget get _placeTitle {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Text(placeDetail["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold))
      ],
    ),);
  }
}

class PlaceDetails extends StatefulWidget {
  final String placeId;
  
  const PlaceDetails({super.key,  required this.placeId });

  @override
  State<PlaceDetails> createState() => _PlaceDetailsState();
}