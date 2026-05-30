import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/controller/support/support_controller.dart';
import 'package:esim/data/model/authorization/authorization_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/support/support_ticket_view_response_model.dart';
import 'package:esim/data/repo/support/support_repo.dart';
import 'package:esim/environment.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../core/utils/my_color.dart';

class TicketDetailsController extends GetxController {
  SupportRepo repo;
  final String ticketId;
  String username = '';
  bool isRtl = false;

  TicketDetailsController({required this.repo, required this.ticketId});

  Future<void> loadData() async {
    isLoading = true;
    update();
    String languageCode = repo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.languageCode) ?? 'eng';
    if (languageCode == 'ar') {
      isRtl = true;
    }
    loadUserName();
    await loadTicketDetailsData();
    isLoading = false;
    update();
  }

  void loadUserName() {
    username = repo.apiClient.getCurrencyOrUsername(isCurrency: false);
  }

  bool isLoading = false;

  final TextEditingController replyController = TextEditingController();

  MyTickets? receivedTicketModel;
  List<File> attachmentList = [];

  String noFileChosen = MyStrings.noFileChosen;
  String chooseFile = MyStrings.chooseFile;

  String ticketImagePath = "";

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx']);
    if (result == null) return;

    attachmentList.add(File(result.files.single.path!));

    update();
  }

  bool isImage(String path) {
    if (path.contains('.jpg')) {
      return true;
    }
    if (path.contains('.png')) {
      return true;
    }
    if (path.contains('.jpeg')) {
      return true;
    }
    return false;
  }

  bool isXlsx(String path) {
    if (path.contains('.xlsx')) {
      return true;
    }
    if (path.contains('.xls')) {
      return true;
    }
    if (path.contains('.xlx')) {
      return true;
    }
    return false;
  }

  bool isDoc(String path) {
    if (path.contains('.doc')) {
      return true;
    }
    if (path.contains('.docs')) {
      return true;
    }
    return false;
  }

  void removeAttachmentFromList(int index) {
    if (attachmentList.length > index) {
      attachmentList.removeAt(index);
      update();
    }
  }

  SupportTicketViewResponseModel model = SupportTicketViewResponseModel();
  List<SupportMessage> messageList = [];
  String ticket = '';
  String subject = '';
  String status = '-1';
  String ticketName = '';

  Future<void> loadTicketDetailsData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;
    update();
    ResponseModel response = await repo.getSingleTicket(ticketId);

    if (response.statusCode == 200) {
      model = SupportTicketViewResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        ticket = model.data?.myTickets?.ticket ?? '';
        subject = model.data?.myTickets?.subject ?? '';
        status = model.data?.myTickets?.status ?? '';
        ticketName = model.data?.myTickets?.name ?? '';
        receivedTicketModel = model.data?.myTickets;
        List<SupportMessage>? tempTicketList = model.data?.myMessages;
        if (tempTicketList != null && tempTicketList.isNotEmpty) {
          messageList.clear();
          messageList.addAll(tempTicketList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isLoading = false;
    update();
  }

  bool submitLoading = false;
  Future<void> uploadTicketViewReply() async {
    if (replyController.text.toString().isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.replyTicketEmptyMsg]);
      return;
    }
    submitLoading = true;
    update();

    try {
      bool b = await repo.replyTicket(replyController.text, attachmentList, receivedTicketModel?.id.toString() ?? "-1");

      if (b) {
        await loadTicketDetailsData(shouldLoad: false);
        CustomSnackBar.success(successList: [MyStrings.repliedSuccessfully]);
        replyController.text = '';
        refreshAttachmentList();
      }
    } catch (e) {
      submitLoading = false;
      update();
    } finally {
      submitLoading = false;
      update();
    }
  }

  void setTicketModel(MyTickets? ticketModel) {
    receivedTicketModel = ticketModel;
    update();
  }

  void clearAllData() {
    refreshAttachmentList();
    replyController.clear();
    messageList.clear();
  }

  void refreshAttachmentList() {
    attachmentList.clear();
    update();
  }

  bool closeLoading = false;
  void closeTicket(String supportTicketID) async {
    closeLoading = true;
    update();
    ResponseModel responseModel = await repo.closeTicket(supportTicketID);
    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        clearAllData();
        Get.back();
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
        Get.find<SupportController>().loadData();
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    closeLoading = false;
    update();
  }

  String getStatusText(String priority, {bool isPriority = false, bool isStatus = false}) {
    String text = '';
    text = priority == '0'
        ? MyStrings.open.tr
        : priority == '1'
            ? MyStrings.answered.tr
            : priority == '2'
                ? MyStrings.replied.tr
                : priority == '3'
                    ? MyStrings.closed.tr
                    : '';
    return text;
  }

  Color getStatusColor(String status, {bool isPriority = false}) {
    late Color output;
    if (isPriority) {
      output = status == '1'
          ? MyColor.pendingColor
          : status == '2'
              ? MyColor.greenSuccessColor
              : status == '3'
                  ? MyColor.redCancelTextColor
                  : MyColor.pendingColor;
    } else {
      output = status == '1'
          ? MyColor.textFieldDisableBorderColor
          : status == '2'
              ? MyColor.highPriorityPurpleColor
              : status == '3'
                  ? MyColor.redCancelTextColor
                  : MyColor.greenSuccessColor;
    }

    return output;
  }

  //download pdf
  TargetPlatform? platform;
  String _localPath = '';
  String downLoadId = "";

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      } else {
        return (await getExternalStorageDirectory())?.path ?? "";
      }
    } else if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return null;
    }
  }

  bool isSubmitLoading = false;
  int selectedIndex = -1;
  Future<void> downloadAttachment(String url, int index, String extension) async {
    selectedIndex = index;
    isSubmitLoading = true;
    update();

    await _prepareSaveDir();

    final headers = {
      'Authorization': "Bearer ${repo.apiClient.token}",
      'content-type': "application/$extension",
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Get the path for the download folder and save the file there
      String downloadPath = await _getDownloadDirectory();

      // Save and open the file from the download path
      await saveAndOpenFile(bytes, '$downloadPath/${Environment.appName} ${DateTime.now()}.$extension', extension);
    } else {
      try {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.body));
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      } catch (e) {
        CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
      }
    }
    selectedIndex = -1;
    isSubmitLoading = false;
    update();
  }

  Future<String> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      }
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveAndOpenFile(List<int> bytes, String path, String extension) async {
    final file = File(path);

    // Save the file to the device
    var d = await file.writeAsBytes(bytes);
    printX(d);
    // Open the file based on its extension
    if (extension == 'pdf') {
      await openPDF(path);
    } else {
      await openFile(path);
    }
  }

  Future<void> openPDF(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        CustomSnackBar.success(successList: [MyStrings.fileDownloadedSuccess]);
        // CustomSnackBar.error(errorList: ["No App Found For open this pdf file"]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }

  Future<void> openFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      printX("${result.type}");
      if (result.type != ResultType.done) {
        // CustomSnackBar.error(errorList: ["No App Found For open this file"]);
        CustomSnackBar.success(successList: [MyStrings.fileDownloadedSuccess]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }
}
