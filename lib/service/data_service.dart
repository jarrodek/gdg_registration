library gdgregistration.service.dataservice;

import 'dart:async';
import 'dart:html';

import 'package:chrome/chrome_app.dart' as chrome;
import 'package:angular/angular.dart';

@Injectable()
class DataService {

  final Http _http;
  
  static final String KEY_SPREADSHEET = 'spr';
  static final String KEY_WORKSHEET = 'wor';
  /// Full worksheet ID: spreadsheetId/worksheetId
  String _worksheetId;

  DataService(Http this._http);
  
  ///Get worksheets for spredsheet idetified by [spreadsheetId]
  Future getWorksheets(String spreadsheetId){
    String url = 'https://spreadsheets.google.com/feeds/worksheets/$spreadsheetId/public/basic?alt=json';
    
    var completer = new Completer();
    
    _http.get(url).then((HttpResponse r){
      Map data = r.data;
      
      if(!data.containsKey('feed')){
        completer.completeError(null);
        return;
      }
      List entries = data['feed']['entry'];
      
      Map<String, String> result = {};
      
      for(Map entry in entries){
        String worksheetId = entry['id'][r'$t'];
        worksheetId = worksheetId.substring(worksheetId.lastIndexOf('/')+1);
        String worksheetTitle = entry['title'][r'$t'];
        
        result[worksheetId] = worksheetTitle; 
      }
      
      completer.complete(result);
      
    }).catchError((Error e) => completer.completeError(e));
    
    return completer.future;
  }

  
  void storeSpreadsheedData(String spreadsheet, String worksheet){
    var completer = new Completer();
    
    _worksheetId = "$spreadsheet/$worksheet";
    if(chrome.storage != null && chrome.storage.local != null){
      chrome.storage.local.set({
        KEY_SPREADSHEET: spreadsheet,
        KEY_WORKSHEET: worksheet
      }).then((_) => completer.complete()).catchError((e) => completer.completeError(e));
    } else {
      window.localStorage[KEY_SPREADSHEET] = spreadsheet;
      window.localStorage[KEY_WORKSHEET] = worksheet;
      completer.complete();
    }
    
    return completer.future;
  }
  
  Future<String> getWorksheetFullId(){
    var completer = new Completer();
    if(_worksheetId == null){
      if(chrome.storage != null && chrome.storage.local != null){
        chrome.storage.local.get({
          KEY_SPREADSHEET: null,
          KEY_WORKSHEET: null
        }).then((Map data){
          if(data[KEY_SPREADSHEET] == null || data[KEY_WORKSHEET] == null){
            completer.complete(null);
            return;
          }
          _worksheetId = "${data[KEY_SPREADSHEET]}/${data[KEY_WORKSHEET]}";
          completer.complete(_worksheetId);
        }).catchError((e) => completer.completeError(e));
      } else {
        String spreadsheet = window.localStorage[KEY_SPREADSHEET];
        String worksheet = window.localStorage[KEY_WORKSHEET];
        if(spreadsheet == null || worksheet == null){
          completer.complete(null);
        } else {
          _worksheetId = "${spreadsheet}/${worksheet}";
          completer.complete(_worksheetId);
        }
      }
    } else {
      completer.complete(_worksheetId);
    }
    return completer.future;
  }
  
}
