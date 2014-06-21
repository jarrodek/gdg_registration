library gdgregistration.component.setup.columns;

import 'package:angular/angular.dart';

@Component(
    selector: '[columns-selector]',
    templateUrl: 'packages/gdg_registration/component/setup/columns.html',
    publishAs: 'cmp',
    map: const {
      'columns': '<=>columns',
      'mapping': '<=>mapping',
      'on-accept-value': '&onEnterValue'
    },
    useShadowDom: false)
class MapColumnsComponent {
  
  List columns;
  List mapping;
  dynamic onEnterValue;
  
  ///List of select's options - spreadsheet's columns names.
  List get options {
    var res = [];
    for(var i=0, len=columns.length; i<len; i++){
      res.add(columns[i]['title']);
    }
    return res;
  }
  
  
  void nameFieldChange(Map column){
    if(mapping.last == column){
      if((column['name'] as String).isEmpty){
        
      } else {
        mapping.add({   
          'key': null,
          'name': null,
          'value': null,
          'col': 0
        });
      }
    }
  }
}