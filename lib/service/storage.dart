library gdgregistration.service.storageservice;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:chrome/chrome_app.dart' as chrome;
import 'package:angular/angular.dart';

@Injectable()
class StorageService {
  
  bool get hasStore => chrome.storage != null && chrome.storage.local != null;
  
  Future store(Map data){
    if(hasStore){
      return chrome.storage.local.set(data);
    } else {
      throw "Not yet implemented";
    }
  }
  
  Future restore(data){
    if(hasStore){
      return chrome.storage.local.set(data);
    } else {
      throw "Not yet implemented";
    }
  }
  
}