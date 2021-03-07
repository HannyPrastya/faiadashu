import 'package:fhir/r4/resource_types/clinical/diagnostics/diagnostics.dart';
import 'package:flutter/material.dart';
import 'package:widgets_on_fhir/questionnaires/questionnaires.dart';

import 'questionnaire_item_widget.dart';

class GroupItemWidget extends QuestionnaireItemWidget {
  const GroupItemWidget(
      QuestionnaireLocation location, QuestionnaireItemDecorator decorator,
      {Key? key})
      : super(location, decorator, key: key);
  @override
  State<StatefulWidget> createState() => _GroupItemState();
}

class _GroupItemState extends QuestionnaireItemState {
  _GroupItemState() : super(null);

  @override
  Widget buildBodyReadOnly(BuildContext context) {
    return const SizedBox(
      height: 16.0,
    );
  }

  @override
  QuestionnaireResponseItem createResponse() {
    // Not required for a read-only item
    throw UnimplementedError();
  }

  @override
  Widget buildBodyEditable(BuildContext context) {
    // Not required for a read-only item
    throw UnimplementedError();
  }
}