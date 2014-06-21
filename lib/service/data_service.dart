library gdgregistration.service.dataservice;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:chrome/chrome_app.dart' as chrome;
import 'package:angular/angular.dart';

import 'storage.dart';

@Injectable()
class DataService {

  final Http _http;
  final StorageService _storage;
  
  static final String _SERVICE_BASE_URL = "https://spreadsheets.google.com/feeds";
  static final String KEY_SPREADSHEET = 'spr';
  static final String KEY_WORKSHEET = 'wor';
  static final String KEY_MAPPING = 'map';
  
  /// Full worksheet ID: spreadsheetId/worksheetId
  String _worksheetId;
  
  

  DataService(Http this._http, StorageService this._storage);
  
  ///Get worksheets for spredsheet idetified by [spreadsheetId]
  Future getWorksheets(String spreadsheetId){
    String url = '$_SERVICE_BASE_URL/worksheets/$spreadsheetId/public/basic?alt=json';
    
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
  
  /**
   * Get columns definitions for spreadsheet identified by a [key] and worksheet identified by [id].
   * This assuming that first row contains columns definitions.
   */
  Future<List> getSpreadsheetColumns(String key, String id){
    String url = "$_SERVICE_BASE_URL/cells/$key/$id/public/full?alt=json&min-row=1&max-row=1";
    var completer = new Completer<List>();
    
    _http.get(url).then((HttpResponse r){
      List<Map<String, dynamic>> data = r.data['feed']['entry'];
      
      if(data.length == 0){
        completer.complete([]);
        return;
      }
      
      var result = [];
      for(var i=0, len=data.length; i<len; i++){
        var entry = data[i];
        String title, row, col;
        
        title = entry['content'][r'$t'];
        row = entry['gs\$cell']['row'];
        col = entry['gs\$cell']['col'];
        result.add({
          "title": title,
          "row": row,
          "col": col
        });
      }
      completer.complete(result);
    });
    
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
  
  Future checkConfirmation(String no){
    
    //https://spreadsheets.google.com/feeds/list/1MZKtK9Ohq50V17ROEW_VcmCfmhRgmPR_81Tvq6G3Exw/od6/public/full?alt=json&sq=confirmation%3D123
    _buildQueryUrl(no).then((String url) => _sendQuery(url));
    
  }
  
  
  Future<String> _buildQueryUrl(String query){
    return getWorksheetFullId().then((String id){
      
      String searchField = _normalizeColumnName("ConfirmationCode");
      var sq = Uri.encodeQueryComponent("$searchField=$query");
      
      return "$_SERVICE_BASE_URL/list/$id/public/full?alt=json&sq=$sq";
    });
  }
  
  
  Future _sendQuery(String url){
    print("SENDING $url");
    
    return _http.get(url);
  }
  
  
  String _normalizeColumnName(String name){
    name = name.toLowerCase();
    name = name.replaceAll(r'\s', '');
    name = name.replaceAll(r'[_-]', '');
    return name;
  }
  
  
  
  Future saveColumnMapping(List mapping){
    var encoded = JSON.encode(mapping);
    return _storage.store({
      KEY_MAPPING: encoded
    });
  }
  
}


/**
 * Class used for mapping spreadsheet's columns to names used by the app.
 * While setup the user must map spreadsheet's columns to:
 * - confirmation number
 * - name
 * - company
 * Each column may appear on printed ticket. If so [ticket] flag must be set to true.
 */
class SpreadsheetColumn {
  String name;
  String value;
  bool ticket;
  Map<String, dynamic> cell = {
    "row": null,
    "col": null
  };
  SpreadsheetColumn(this.name, this.value, this.ticket);
}