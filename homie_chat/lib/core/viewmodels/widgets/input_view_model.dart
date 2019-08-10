
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homie_chat/core/models/message.dart';
import 'package:homie_chat/core/models/user.dart';
import 'package:homie_chat/core/services/message_service.dart';
import 'package:homie_chat/core/viewmodels/base_model.dart';

class InputViewModel extends BaseModel {
  MessageService _messageService;

  InputViewModel({
    MessageService messageService
  }) : _messageService = messageService;

  Future<bool> sendMessage(User user, String content) async {
    setBusy(true);

    var payload = {
      "userId": user.id,
      "content": content
    };

    var result = await _messageService.sendMessage(json.encode(payload));

    setBusy(false);

    return result;
  }

}