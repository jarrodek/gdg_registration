library gdgregistration.registration;

import 'package:angular/angular.dart';

import 'service/data_service.dart';

@Controller(selector: '[registration-app]', publishAs: 'ctrl')
class RegistrationController {

  //Just to initialize service. 
  DataService dataService;
  
  RegistrationController(DataService this.dataService);
}