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
    
    _storage.store({
      KEY_SPREADSHEET: spreadsheet,
      KEY_WORKSHEET: worksheet
    }).then((_) => completer.complete()).catchError((e) => completer.completeError(e));
    
    return completer.future;
  }
  
  Future<String> getWorksheetFullId(){
    var completer = new Completer();
    if(_worksheetId == null){
      _storage.restore({
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
      completer.complete(_worksheetId);
    }
    return completer.future;
  }
  
  Future checkConfirmation(String no){
    
    //https://spreadsheets.google.com/feeds/list/ID/KEY/public/full?alt=json&sq=confirmation%3D123
    return _buildQueryUrl(no)
    .then((String url) => _sendQuery(url))
    .then((r) => _parseQueryResponse(r))
    .then((data) => data);
  }
  
  
  Future<String> _buildQueryUrl(String query){
    return getWorksheetFullId().then((String id){
      
      String searchField = _normalizeColumnName("ConfirmationCode");
      var sq = Uri.encodeQueryComponent("$searchField=$query");
      
      return "$_SERVICE_BASE_URL/list/$id/public/full?alt=json&sq=$sq";
    });
  }
  
  
  Future _sendQuery(String url){
    return _http.get(url).then((HttpResponse r) => r.data).catchError((e) => throw "Connection error");
  }
  
  Map _parseQueryResponse(Map data){
    if(data == null) {
      throw "Data not available (#1)";
    }
    if(!data.containsKey(r'feed')){
      throw "Invalid response (#2)";
    }
    Map feed = data['feed'];
    if(!feed.containsKey(r'openSearch$totalResults')){
      throw "Invalid response (#3)";
    }
    var _c = feed[r'openSearch$totalResults'][r'$t'];
    int results;
    try{
      results = int.parse(_c);
    } catch (e){
      throw "Invalid response (#4)";
    }
    if(results != 1){
      return null;
    }
    
    if(!feed.containsKey(r'entry')){
      throw "Invalid response (#5)";
    }
    Map entry = feed['entry'][0];
    
    var completer = new Completer();
    getColumnsMapping().then((List mapping){
      
      if(mapping == null){
        throw "App is not set up.";
      }
      
      List toPrint = [];
      String confirmationId = null;
      
      //[{key: CONFIRMATION_NUMBER, name: Confirmation number, value: ConfirmationCode, col: 11}, {key: NAME, name: Name, value: Imię i nazwisko, col: 2}, {key: null, name: Company, value: Firma / uczelnia, col: 3}] 
      for(var i=0, len=mapping.length; i<len; i++){
        Map _m = mapping[i];
        if(_m.containsKey('key') && _m['key'] == 'CONFIRMATION_NUMBER'){
          var confirmationId_col = _normalizeColumnName(_m['value']);
          confirmationId = entry['gsx\$$confirmationId_col'][r'$t'];
        } else {
          var colName = _normalizeColumnName(_m['value']);
          print('colName: gsx\$$colName');
          if(!entry.containsKey('gsx\$$colName')){
            print('Column does not exists');
            continue;
          }
          
          toPrint.add({
            'name': _m['name'],
            'value': entry['gsx\$$colName'][r'$t']
          });
        }
      }
      
      completer.complete({
        'cid': confirmationId,
        'data': toPrint
      });
      
    });
    
    
    return completer.future;
  }
  
  
  String _normalizeColumnName(String name){
    name = name.replaceAll(new RegExp(r"[:;\(\)\[\] \./\?<>'!@#\$\%\^\&\*_]", caseSensitive: true, multiLine: true), '');
    name = name.toLowerCase();
    return name;
  }
  
  
  
  Future saveColumnMapping(List mapping){
    var encoded = JSON.encode(mapping);
    return _storage.store({
      KEY_MAPPING: encoded
    });
  }
  
  Future getColumnsMapping(){
    return _storage.restore({
      KEY_MAPPING: null
    })
    .then((Map data) => data[KEY_MAPPING] == null ? null : JSON.decode(data[KEY_MAPPING]));
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