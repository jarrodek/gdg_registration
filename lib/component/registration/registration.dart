library gdgregistration.component.registration;

import 'dart:html';

import 'package:angular/angular.dart';

import '../../service/data_service.dart';

@Component(
    selector: 'registration',
    templateUrl: 'packages/gdg_registration/component/registration/registration.html',
    publishAs: 'cmp',
    useShadowDom: false)
class RegistrationComponent {
  
  DataService _dataService;
  String confirmationNumber = "WzX8T";
  bool loading = false;
  bool printing = false;
  int width = 304;
  int height = 400;
  var logoImg = new ImageElement()..src="img/io.png";
  List printData;
  
  RegistrationComponent(DataService this._dataService);
  
  void onEnterValue(){
    loading = true;
    
    _dataService.checkConfirmation(confirmationNumber)
    .then((Map data){
      loading = false;
      
      if(data == null){
        //TODO: error reporting
        return;
      }
      
      var cid = data['cid'];
      if(cid != confirmationNumber){
        //TODO: report error
        return;
      }
      
      
      //Has atendee data. Can print badge.
      printData = data['data'];
      //printing = true;
      _drawCanvas();
    })
    .catchError((Error e){
      loading = false;
      if(e is String){
        print("ERROR: e");
      } else {
        print("ERROR: e");
      }
    });
  }
  
  void _drawCanvas(){
    CanvasElement canvas = document.querySelector('canvas#previewCanvas');
    var ctx = canvas.getContext("2d");
    var lines = printData.length;
    
    ctx.fillStyle = "#fff";
    ctx.fillRect(0, 0, height, width);
    ctx.fillStyle = "#000";
    
    var scale = 1;
    if (logoImg.height > width) {
      scale = width / logoImg.height;
    }
    var y = 0;
    if (logoImg.height < width) {
      y = (width - logoImg.height) / 2;
    }
    ctx.font = "64px sans-serif";
    
    var startX = (width/2 - logoImg.width/2);
    var startY = 20;
    
    ctx.drawImage(logoImg, startX, startY);
    
    startY += logoImg.height + 20; //image height + 20 pix min padding
    
    
    for(var i=0, len = printData.length; i<len; i++){
      if(i==0){
        ctx.font = "24px sans-serif";
        ctx.fillText(printData[i]['value'], 20, startY);
        startY += 26;
      } else {
        ctx.font = "18px sans-serif";
        ctx.fillText(printData[i]['value'], 20, startY);
        startY += 20;
      }
    }
  }
  
  
}