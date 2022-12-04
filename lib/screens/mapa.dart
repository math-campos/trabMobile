import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';


class Mapa extends StatefulWidget {
  String? idLocal;
  Mapa({this.idLocal});

  @override
  State<Mapa> createState() => MapaState();
}

class MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  final CollectionReference _locais =
  FirebaseFirestore.instance.collection("locais");

  Set<Marker>  _marcadores = {};
  double _lat = 20.5937;
  double _lng = 78.9629;

  static CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 15,
  );

  _adicionaMarcador(LatLng latLng) async{
    /*    List<Placemark> listaEnderecos = await
         placemarkFromCoordinates(latLng.latitude, latLng.longitude);
     if (listaEnderecos != null && listaEnderecos.length > 0) {
       Placemark endereco = listaEnderecos[0]; // primeiro endereço
       String rua = endereco.thoroughfare!; //via pública
*/
    String rua = latLng.latitude.toString();
    Marker marcador = Marker(
        markerId: MarkerId(
            "marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: rua)
    );
    setState(() {
      _marcadores.add(marcador);
      Map<String, dynamic> local = Map();
      local["titulo"] = rua;
      local["latitude"] = latLng.latitude;
      local["longitude"] = latLng.longitude;
      _locais.add(local);
    });
    // }
  }


  getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      return;
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      return;
    } else {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _posicaoCamera = CameraPosition(target: LatLng(position.latitude,
          position.longitude), zoom: 15);
      _movimentarCamera();

    }
  }
  /*
  _addListenerLocalizacao() {
    Geolocator.getPositionStream().listen((Position position) {

      _lat = position.latitude;
      _lng = position.longitude;
      print("entrou aqui");
      LatLng latLng = LatLng(_lat, _lng);
      Marker marcador = Marker(
          markerId: MarkerId("marcador-${_lat}-${_lng}"), position: latLng);
      _marcadores.clear();
      _marcadores.add(marcador);
      _posicaoCamera = CameraPosition(target: latLng, zoom: 15);
      _movimentarCamera();
      setState(() {

      });
    });
  }
*/

  _movimentarCamera() async{
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _posicaoCamera,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                markers: _marcadores,
                onLongPress: _adicionaMarcador,
              )
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.idLocal != null){// tem local
      mostrarLocal(widget.idLocal);
    }else{
      getLocation();
    }
  }

  mostrarLocal(String? idLocal) async {
    DocumentSnapshot local = await _locais.doc(idLocal).get();
    String titulo = local.get("titulo");
    LatLng latLng = LatLng(local.get("latitude"), local.get("longitude"));
    setState(() {
      Marker marcador = Marker(
          markerId: MarkerId(
              "marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: titulo)
      );
      _marcadores.add(marcador);
      _posicaoCamera = CameraPosition(target: latLng, zoom: 15);
      _movimentarCamera();
    });
  }
}