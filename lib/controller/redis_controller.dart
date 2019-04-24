import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'package:dartis/dartis.dart';

class RedisController extends ResourceController {
  Future<Commands<String, String>> main() async {
    final client = await Client.connect('redis://127.0.0.1:6379');

    final commands = client.asCommands<String, String>();

    return commands;
  }

  @Operation.get()
  Future<Response> getAll() async {
    final commands = await main();

    final Map<String, String> values = await commands.hgetall('test');

    return Response.ok("Got All "+ values.toString());
  }

  @Operation.get('id')
  Future<Response> getOne(@Bind.path('id') String id) async {
    final commands = await main();

    final Map<String, String> validator = await commands.hgetall('test');

    if (validator.containsKey(id)){
      final String values = await commands.hget('test', id);

      return Response.ok("Got One - " + id + ": " + values);
    }

    return Response.notFound();
  }

  @Operation.post()
  Future<Response> createNew() async {
    final Map<String, dynamic> body = await request.body.decode();

    var key = body.keys.toString();
    key = key.replaceAll("(", "").replaceAll(")", "");

    var value = body.values.toString();
    value = value.replaceAll("(", "").replaceAll(")", "");

    final commands = await main();
    final int values = await commands.hset('test', key, value);

    return Response.ok("Created one: " + key);
  }

  @Operation.put('id')
  Future<Response> updateOne(@Bind.path('id') String id) async {
    final commands = await main();

    final Map<String, String> validator = await commands.hgetall('test');

    if (validator.containsKey(id)) {
      final String body = await request.body.decode();

      final int values = await commands.hset('test', id, body);

      if(values == 0){
        return Response.ok("Updated one: "+ id);
      }
      return Response.badRequest();
    }

    return Response.notFound();
  }

  @Operation.delete('id')
  Future<Response> deleteOne(@Bind.path('id') String id) async {
    final commands = await main();

    final Map<String, String> validator = await commands.hgetall('test');

    if (validator.containsKey(id)) {
      final int values = await commands.hdel('test', field: id);
      return Response.ok("Deleted one: " + id);
    }
    return Response.notFound();
  }
}