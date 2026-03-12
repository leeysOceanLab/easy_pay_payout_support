import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../controller/session_controller.dart";

class SessionActivity {
  static void mark(BuildContext context, {String source = "unknown"}) {
    context.read<SessionController>().markActivity(source: source);
  }
}
