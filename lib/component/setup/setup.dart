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
      return;
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
        //TODO: select worksheet automatically
        print('ONLY one worksheet');
        return;
      }
      this.worksheets = worksheets;
    });
    
  }
  
  void onAcceptWorksheet(){
    dataService.storeSpreadsheedData(spreadsheetId, worksheet);
    router.go('/start', {});
  }
  
  
}
//https://docs.google.com/spreadsheets/edit?id=1MZKtK9Ohq50V17ROEW_VcmCfmhRgmPR_81Tvq6G3Exw#gid=0