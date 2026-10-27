import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String cppChannelName = 'dart_bridge';

const String _badArgumentsCode = 'bad_arguments';
const String _badArgumentsMessage = 'expected a List or null argument';
const String _handlerExceptionCode = 'handler_exception';

typedef CppHandler = void Function(List<Object?> args, CppReply reply);

final CppBridge cpp = CppBridge._();

final class CppBridge {
  CppBridge._();

  final MethodChannel _channel = MethodChannel(cppChannelName);
  final Map<String, CppHandler> _handlers = <String, CppHandler>{};
  final Map<String, _CppFieldRecord<dynamic>> _fields = <String, _CppFieldRecord<dynamic>>{};

  bool _dispatchInstalled = false;

  void method(String name, CppHandler handler) {
    _ensureDispatch();
    _handlers[name] = handler;
  }

  _CppFieldRecord<T> _fieldRecord<T>(String name, T initial) {
    final _CppFieldRecord<dynamic>? existing = _fields[name];
    if (existing != null) {
      if (existing.runtimeType != _CppFieldRecord<T>) {
        throw ArgumentError(
          'field "$name" is already registered as ${existing.runtimeType}; '
          'a Field<$T> needs a record of $T',
        );
      }
      return existing as _CppFieldRecord<T>;
    }

    final _CppFieldRecord<T> record = _CppFieldRecord<T>(initial, name);
    _connectNotifier<T>(name, record);
    _fields[name] = record;
    return record;
  }

  void _connectNotifier<T>(String name, _CppFieldRecord<T> record) {
    method('notifier_$name', (args, reply) {
      try {
        final Object? incoming = args.isEmpty ? null : args.first;
        if (incoming is T) {
          record.value = incoming;
        }
      } on Object catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: cppChannelName,
            context: ErrorDescription('while publishing the value C++ pushed to field "$name"'),
            silent: true,
          ),
        );
      } finally {
        reply.success();
      }
    });
  }

  Future<T> invoke<T>(String name, List<Object?> args) async {
    _ensureDispatch();
    final Object? result = await _channel.invokeMethod<Object?>(name, args);
    if (result is! T) {
      throw StateError(
        'cpp.invoke<$T>("$name") returned ${result.runtimeType}, '
        'expected $T',
      );
    }
    return result;
  }

  void _ensureDispatch() {
    if (_dispatchInstalled) {
      return;
    }
    _channel.setMethodCallHandler(_dispatch);
    _dispatchInstalled = true;
  }

  Future<Object?> _dispatch(MethodCall call) async {
    final CppHandler? handler = _handlers[call.method];
    if (handler == null) {
      throw MissingPluginException('No Dart handler for "${call.method}" on channel $cppChannelName');
    }

    final CppReply reply = CppReply._(call.method);
    try {
      _deliver(handler, call.arguments, reply);
    } catch (error) {
      reply.error(_handlerExceptionCode, error.toString());
    }
    return reply._resolve();
  }

  void _deliver(CppHandler handler, Object? arguments, CppReply reply) {
    final List<Object?> args;
    if (arguments == null) {
      args = const <Object?>[];
    } else if (arguments is List<Object?>) {
      args = arguments;
    } else {
      reply.error(_badArgumentsCode, _badArgumentsMessage);
      return;
    }

    final dynamic loose = handler;
    if (loose(args, reply) is Future) {
      throw StateError(
        'the handler for "${reply._method}" returned a Future: a CppHandler '
        'must be synchronous and answer before it returns',
      );
    }
  }
}

final class CppEndpoint {
  CppEndpoint._(this._name);

  final String _name;

  Future<T> invoke<T>([List<Object?> args = const <Object?>[]]) => cpp.invoke<T>(_name, args);

  void method(CppHandler handler) => cpp.method(_name, handler);
}

extension CppEndpointLiteral on String {
  CppEndpoint get cpp => CppEndpoint._(this);
}

final class CppReply {
  CppReply._(this._method);

  final String _method;

  Object? _value;
  String? _errorCode;
  String? _errorMessage;
  bool _notImplemented = false;
  bool _claimed = false;

  void success([Object? value]) {
    if (_claim()) {
      _value = value;
    }
  }

  void error(String code, String message) {
    if (_claim()) {
      _errorCode = code;
      _errorMessage = message;
    }
  }

  void notImplemented() {
    if (_claim()) {
      _notImplemented = true;
    }
  }

  bool _claim() {
    if (_claimed) {
      return false;
    }
    _claimed = true;
    return true;
  }

  Object? _resolve() {
    if (_notImplemented) {
      throw MissingPluginException('No Dart handler for "$_method" on channel $cppChannelName');
    }
    final String? code = _errorCode;
    if (code != null) {
      throw PlatformException(code: code, message: _errorMessage);
    }
    if (!_claimed) {
      throw PlatformException(code: _handlerExceptionCode, message: 'handler did not reply');
    }
    return _value;
  }
}

final class _CppFieldRecord<T> extends ValueNotifier<T> {
  _CppFieldRecord(super.value, this.name);

  final String name;

  @override
  // ignore: must_call_super
  void dispose() {}

  Future<void> refresh() async {
    value = await cpp.invoke<T>('get_$name', const <Object?>[]);
  }

  Future<void> write(T v) async {
    value = v;
    await cpp.invoke<void>('set_$name', <Object?>[v]);
  }
}

final class Field<T> {
  Field(this.name, T initial) : _record = cpp._fieldRecord<T>(name, initial);

  final String name;
  final _CppFieldRecord<T> _record;

  ValueListenable<T> get notifier => _record;

  T get value => _record.value;

  set value(T v) => _record.value = v;

  Future<void> refresh() => _record.refresh();

  Future<void> write(T v) => _record.write(v);

  void dispose() {}
}
