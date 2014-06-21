library gdgregistration.component.registration;

import 'package:angular/angular.dart';

import '../../service/data_service.dart';

@Component(
    selector: 'registration',
    templateUrl: 'packages/gdg_registration/component/registration/registration.html',
    publishAs: 'cmp',
    useShadowDom: false)
class RegistrationComponent {
  
  DataService dataService;
  String confirmationNumber;
  bool loading = false;
  
  RegistrationComponent(DataService this.dataService);
  
  void onEnterValue(){
    loading = true;
    
    dataService.checkConfirmation(confirmationNumber);
  }
}