library gdgregistration.component.setup.worksheet;

import 'package:angular/angular.dart';

@Component(
    selector: '[worksheets]',
    templateUrl: 'packages/gdg_registration/component/setup/worksheet.html',
    publishAs: 'cmp',
    map: const {
      'worksheet': '<=>worksheet',
      'value': '<=>value',
      'on-accept-value': '&onEnterValue'
    },
    useShadowDom: false)
class SelectWorksheetComponent {
  //Selected worksheet
  String worksheet;
  Map<String, String> value;
  
  List<String> get ids => value == null ? [] : value.keys;
  
  dynamic onEnterValue;
  
  void select(String id){
    worksheet = id;
  }
}