// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter/src/event_processor/android_platform_exception_event_processor.dart';

import 'integrations/native_app_start_integration_test.dart';

void main() {
  late Fixture fixture;
  setUp(() {
    fixture = Fixture();

    PackageInfo.setMockInitialValues(
      appName: 'Sentry',
      buildNumber: '1',
      buildSignature: '',
      packageName: 'io.sentry.samples',
      version: '1.2.3',
    );
  });

  group(AndroidPlatformExceptionEventProcessor, () {
    test('exception is correctly parsed', () async {
      final exception = fixture.options.exceptionFactory
          .getSentryException(testPlatformException);

      final event = SentryEvent(
        exceptions: [exception],
        throwable: testPlatformException,
      );

      final platformExceptionEvent = await fixture.processor.apply(event);

      final exceptions = platformExceptionEvent!.exceptions!;
      expect(exceptions.length, 2);

      final platformException = exceptions[1];

      expect(platformException.type, 'IllegalArgumentException');
      expect(
        platformException.value,
        "Unsupported value: '[Ljava.lang.StackTraceElement;@ba6feed' of type 'class [Ljava.lang.StackTraceElement;'",
      );
      expect(platformException.stackTrace!.frames.length, 18);
    });

    test('does nothing if no PlatformException is there', () async {
      final exception = fixture.options.exceptionFactory
          .getSentryException(testPlatformException);

      final event = SentryEvent(
        exceptions: [exception],
        throwable: null,
      );

      final platformExceptionEvent = await fixture.processor.apply(event);

      expect(event, platformExceptionEvent);
    });

    test('does nothing if PlatformException has no stackTrace', () async {
      final exception = fixture.options.exceptionFactory
          .getSentryException(emptyPlatformException);

      final event = SentryEvent(
        exceptions: [exception],
        throwable: emptyPlatformException,
      );

      final platformExceptionEvent = await fixture.processor.apply(event);

      expect(event, platformExceptionEvent);
    });
  });
}

class Fixture {
  late AndroidPlatformExceptionEventProcessor processor =
      AndroidPlatformExceptionEventProcessor(options);

  SentryFlutterOptions options = SentryFlutterOptions(dsn: fakeDsn);
}

final testPlatformException = PlatformException(
  code: 'error',
  details:
      "Unsupported value: '[Ljava.lang.StackTraceElement;@fa902f1' of type 'class [Ljava.lang.StackTraceElement;'",
  message: null,
  stacktrace:
      """java.lang.IllegalArgumentException: Unsupported value: '[Ljava.lang.StackTraceElement;@ba6feed' of type 'class [Ljava.lang.StackTraceElement;'
	at io.flutter.plugin.common.StandardMessageCodec.writeValue(StandardMessageCodec.java:292)
	at io.flutter.plugin.common.StandardMethodCodec.encodeSuccessEnvelope(StandardMethodCodec.java:59)
	at io.flutter.plugin.common.MethodChannel\$IncomingMethodCallHandler\$1.success(MethodChannel.java:267)
	at io.sentry.samples.flutter.MainActivity.configureFlutterEngine\$lambda-0(MainActivity.kt:40)
	at io.sentry.samples.flutter.MainActivity.lambda\$TiSaAm1LIEmKLVswI4BlR_5sw5Y(Unknown Source:0)
	at io.sentry.samples.flutter.-\$\$Lambda\$MainActivity\$TiSaAm1LIEmKLVswI4BlR_5sw5Y.onMethodCall(Unknown Source:2)
	at io.flutter.plugin.common.MethodChannel\$IncomingMethodCallHandler.onMessage(MethodChannel.java:262)
	at io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:296)
	at io.flutter.embedding.engine.dart.DartMessenger.lambda\$dispatchMessageToQueue\$0\$DartMessenger(DartMessenger.java:320)
	at io.flutter.embedding.engine.dart.-\$\$Lambda\$DartMessenger\$TsixYUB5E6FpKhMtCSQVHKE89gQ.run(Unknown Source:12)
	at android.os.Handler.handleCallback(Handler.java:938)
	at android.os.Handler.dispatchMessage(Handler.java:99)
	at android.os.Looper.loopOnce(Looper.java:210)
	at android.os.Looper.loop(Looper.java:299)
	at android.app.ActivityThread.main(ActivityThread.java:8138)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit\$MethodAndArgsCaller.run(RuntimeInit.java:556)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1037)""",
);

final emptyPlatformException = PlatformException(
  code: 'error',
  details:
      "Unsupported value: '[Ljava.lang.StackTraceElement;@fa902f1' of type 'class [Ljava.lang.StackTraceElement;'",
  message: null,
  stacktrace: null,
);
