import 'package:flutter/services.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_external_gateway.dart';

final class AndroidParentFollowUpExternalGateway
    implements ParentFollowUpExternalGateway {
  AndroidParentFollowUpExternalGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/p0_07_external_sharing';

  final MethodChannel _channel;

  @override
  Future<ParentFollowUpExternalLaunch> open(
    PreparedParentFollowUpPayload payload,
  ) async {
    final method = switch (payload.channel) {
      ParentFollowUpChannel.sms => 'openParentSms',
      ParentFollowUpChannel.whatsapp => 'openParentWhatsApp',
    };

    final raw = await _channel.invokeMethod<Object?>(method, <String, Object?>{
      'recipient': payload.recipient,
      'message': payload.message,
    });

    if (raw is! Map) {
      throw StateError(
        'Android parent follow up gateway returned invalid data.',
      );
    }

    final map = Map<String, Object?>.from(raw);

    final launched = map['launched'];
    final kind = map['kind'];
    final action = map['action'];
    final uriScheme = map['uriScheme'];
    final recipient = map['recipient'];

    if (launched is! bool ||
        kind is! String ||
        action is! String ||
        uriScheme is! String ||
        recipient is! String) {
      throw StateError(
        'Android parent follow up gateway response is incomplete.',
      );
    }

    if (kind != payload.channel.storageValue) {
      throw StateError(
        'Android gateway returned channel $kind '
        'for ${payload.channel.storageValue}.',
      );
    }

    if (recipient != payload.recipient) {
      throw StateError(
        'Android gateway recipient does not match '
        'the prepared payload.',
      );
    }

    return ParentFollowUpExternalLaunch(
      channel: payload.channel,
      launched: launched,
      action: action,
      uriScheme: uriScheme,
      recipient: recipient,
    );
  }
}
