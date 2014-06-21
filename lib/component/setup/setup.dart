library gdgregistration.component.setup;

import 'package:angular/angular.dart';

import '../../service/data_service.dart';

@Component(
    selector: 'setup',
    templateUrl: 'packages/gdg_registration/component/setup/setup.html',
    publishAs: 'cmp',
    useShadowDom: false)
class SetupComponent {
  ///Entered by the user spredsheet URL 
  String spreadsheetUrl;
  String spreadsheetId;
  ///Selected by the user worksheet
  String worksheet;
  ///Error message
  String error;
  ///Flag - true if data is loading 
  bool loading = false;
  ///Downloaded worksheets data
  Map<String, String> worksheets = null;
  /// Columns definitions from spreadsheets.
  List columns = null;
  /// Final column mapping.
  List mapping = [
    {
      'key': 'CONFIRMATION_NUMBER',
      'name': 'Confirmation number',
      'value': null,
      'col': 0
    },
    {
      'key': 'NAME',
      'name': 'Name',
      'value': null,
      'col': 0
    },
    {   
      'key': null,
      'name': null,
      'value': null,
      'col': 0
    }
  ];
  DataService dataService;
  Router router;
  
  SetupComponent(DataService this.dataService, Router this.router){
    dataService.getWorksheetFullId().then((String id) {
      if(id == null) return;
      
      var parts = id.split('/');
      spreadsheetId = spreadsheetUrl = parts.first;
    });
  }
  
  
  void onAcceptSpreadsheetUrl(){
    error = null;
    if(spreadsheetUrl.trim().isEmpty) return;
    
    
    
    if(spreadsheetUrl.indexOf('/spreadsheets/d/') != -1){
      spreadsheetId = spreadsheetUrl.substring(spreadsheetUrl.indexOf('/d/')+3, spreadsheetUrl.indexOf('/', spreadsheetUrl.indexOf('/d/')+3));
    } else if(spreadsheetUrl.indexOf('id=') != -1){
      var _tmp = spreadsheetUrl.substring(spreadsheetUrl.indexOf('id=')+3);
      spreadsheetId = _tmp.split("#")[0];
      spreadsheetId = spreadsheetId.split("&")[0];
    } else {
      spreadsheetId = spreadsheetUrl; 
    }
    
    loading = true;
    
    this.dataService.getWorksheets(spreadsheetId).catchError((e){
      error = 'Unable download spreadsheet data. Check if file is publicly available.';
    }).then((Map<String, String> worksheets){
      loading = false;
      if(worksheets == null){
        return;
      }
      if(worksheets.length == 1){
        worksheet = worksheets.keys.first;
        setColumnsScreen();
        return;
      }
      this.worksheets = worksheets;
    });
    
  }
  
  void onAcceptWorksheet(){
    setColumnsScreen();
  }
  
  
  void setColumnsScreen(){
    loading = true;
    dataService.storeSpreadsheedData(spreadsheetId, worksheet);
    
    dataService.getSpreadsheetColumns(spreadsheetId, worksheet)
    .then((List columns){
      this.columns = columns;
      loading = false;
    }).catchError((_){
      error = "Couldn't get columns definitions.";
    });
    
    //router.gotoUrl('/start');
  }
  
  void onAcceptMapping(){
    loading = true;
    
    for(var i=0, len=mapping.length; i<len; i++){
      var col = mapping[i]['col'];
      if(col != null && col != "" && col != 0){
        for(var j=0, colLen=columns.length; j<colLen; j++){
          if(columns[j]['col'] == col){
            mapping[i]['value'] = columns[j]['title'];
            break;
          }
        }
      }
    }
    
    //Removing elements on iterating element will produce an error.
    var source = mapping.toList();
    for(Map mapped in source){
      if(mapped['value'] == null){
        mapping.remove(mapped);
      }
    }
    
    dataService.saveColumnMapping(mapping).then((_) => router.gotoUrl('/start'))
    .catchError((e) => error = "Error occured");
    
    
  }
  
}
//https://docs.google.com/spreadsheets/edit?id=1MZKtK9Ohq50V17ROEW_VcmCfmhRgmPR_81Tvq6G3Exw#gid=0