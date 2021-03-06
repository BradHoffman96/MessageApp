
import 'dart:convert';
import 'dart:io';

import 'package:homies/models/user.dart';
import 'package:homies/services/persistence_service.dart';
import 'package:homies/services/web_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../service_locator.dart';

class UserService {
  final WebService _webService = locator<WebService>();
  final PersistenceService _persistenceService = locator<PersistenceService>();

  User _user;

  User get currentUser => _user;

  Future<bool> registerUser({String email, String password, String displayName, File image}) async {
    var registerResponse = await _webService.register(
      email: email, 
      password: password,
      displayName: displayName,
      image: image);

    if (!registerResponse.hasError) {
      var result = json.decode(registerResponse.body);
      print(result['token']);

      if (result != null && result['success']) {
        print("SUCCESS");
        print(result['user']);

        //TODO: Save token to shared preferences here
        _persistenceService.storeKey("LOGGED_IN", true);
        _persistenceService.storeKey("TOKEN", result['token']);
        _persistenceService.storeKey("USER", result['user']);
      } else {
        _persistenceService.storeKey("LOGGED_IN", false);
        print("No SUCCESS");
      }
    }

    return !registerResponse.hasError;
  }

  Future<bool> loginUser({String email, String password}) async {
    var loginResponse = await _webService.login(email: email, password: password);

    if (!loginResponse.hasError) {
      var result = json.decode(loginResponse.body);

      if (result != null && result['success']) {
        print(result['token']);

        //TODO: Save token to shared preferences here
        _persistenceService.storeKey("LOGGED_IN", true);
        _persistenceService.storeKey("TOKEN", result['token']);

        //TODO: Get user data next
      } else {
        _persistenceService.storeKey("LOGGED_IN", false);
      }
    }

    return !loginResponse.hasError;
  }

  Future<bool> logoutUser() async {
    var logoutResponse = await _webService.logout();

    if (!logoutResponse.hasError) {
      var result = json.decode(logoutResponse.body);
      print(result);

      if (result != null && result['success']) {
        _persistenceService.storeKey("LOGGED_IN", false);
        _persistenceService.deleteKey("TOKEN");
        _persistenceService.deleteKey("USER");

        _user.image.deleteSync();
      }
    } else {
      print(logoutResponse.body);
    }

    return !logoutResponse.hasError;
  }

  Future<bool> getUser() async {
    var getUserResponse = await _webService.getUser();

    if (!getUserResponse.hasError) {
      var result = json.decode(getUserResponse.body);

      if (result != null && result['success']) {
        print(result['user']);
        var userFromLogin = User.fromJson(result['user']);
        
        if (userFromLogin != null) {
          _user = userFromLogin;

          _persistenceService.storeKey("USER", userFromLogin);
        }
      }
    } else {
      print(getUserResponse.body);
    }

    return !getUserResponse.hasError;
  }

  Future<bool> getUserImage() async {
    var getImageResponse = await _webService.getUserImage();

    if (!getImageResponse.hasError) {
      var documentDir = await getApplicationDocumentsDirectory();

      var path = join(documentDir.path, '${_user.id}-profile.png');
      print(path);

      File file = new File(path);

      if (file.existsSync()) {
        file.deleteSync();
      }

      file.writeAsBytesSync(getImageResponse.bodyBytes);
      _user.image = file;
    } else {
      print("GET IMAGE");
      print(getImageResponse.body);
    }


    return !getImageResponse.hasError;
  }

  Future<bool> updateProfile() async {
    var updateProfileResponse = await _webService.updateProfile(_user.displayName, _user.image);

    if (!updateProfileResponse.hasError) {
      print(updateProfileResponse.body);
    } else {
      print("UPDATE PROFILE: ${updateProfileResponse.body}");
      //TOOD: cache request for later upload when network is better
    }

    return !updateProfileResponse.hasError;
  }

  /*Future<bool> getImageFromGallery() async {

    if (image == null) return false;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = appDocDir.path;
    final File profileImage = await image.copy('$path/profile.png');

    _persistenceService.storeKey("PROFILE_IMAGE_PATH", profileImage.path);

    return true;
  }*/

  Future<bool> checkForUser() async {
    //TODO: check for user in persistence service
    //if null, return false, else, return true

    return true;
  }
}