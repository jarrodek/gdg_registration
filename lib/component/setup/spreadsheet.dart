library gdgregistration.component.setup.spreadsheet;

import 'package:angular/angular.dart';

@Component(
    selector: '[spreadsheet]',
    templateUrl: 'packages/gdg_registration/component/setup/spreadsheet.html',
    publishAs: 'cmp',
    map: const {
      'value': '<=>spreadsheetUrl',
      'on-accept-value': '&onEnterValue'
    },
    useShadowDom: false)
class AddSpreadsheetComponent {
  
  String spreadsheetUrl;
  dynamic onEnterValue;
}