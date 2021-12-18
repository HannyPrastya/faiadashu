import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4/r4.dart';
import 'package:flutter/material.dart';

/// Filler for an individual [QuestionnaireResponseAnswer].
abstract class QuestionnaireAnswerFiller extends StatefulWidget {
  final QuestionResponseItemFillerState responseFillerState;
  final AnswerModel answerModel;
  final QuestionnaireItemModel questionnaireItemModel;
  final QuestionItemModel responseItemModel;
  final QuestionnaireTheme questionnaireTheme;

  QuestionnaireAnswerFiller(
    this.responseFillerState,
    this.answerModel, {
    Key? key,
  })  : responseItemModel = responseFillerState.questionResponseItemModel,
        questionnaireItemModel =
            responseFillerState.responseItemModel.questionnaireItemModel,
        questionnaireTheme = responseFillerState.questionnaireTheme,
        super(key: key);
}

abstract class QuestionnaireAnswerFillerState<
    V,
    W extends QuestionnaireAnswerFiller,
    M extends AnswerModel<Object, V>> extends State<W> {
  static final _abstractLogger = Logger(QuestionnaireAnswerFillerState);
  M get answerModel => widget.answerModel as M;

  late final Object? answerModelError;

  late final FocusNode firstFocusNode;
  bool _isFocusHookedUp = false;

  QuestionnaireItem get qi => widget.questionnaireItemModel.questionnaireItem;
  Locale get locale =>
      widget.responseItemModel.questionnaireResponseModel.locale;
  QuestionnaireItemModel get itemModel => widget.questionnaireItemModel;

  QuestionnaireTheme get questionnaireTheme =>
      widget.responseFillerState.questionnaireTheme;

  QuestionnaireAnswerFillerState();

  @override
  void initState() {
    super.initState();

    try {
      answerModelError = null;

      firstFocusNode = FocusNode(
        debugLabel:
            'AnswerFiller firstFocusNode: ${widget.responseItemModel.nodeUid}',
      );

      widget.responseItemModel.questionnaireResponseModel
          .addListener(_forceRebuild);

      postInitState();
    } catch (exception) {
      _abstractLogger.warn(
        'Could not initialize model for ${itemModel.linkId}',
        error: exception,
      );
      answerModelError = exception;
    }
  }

  /// Initialize the filler after the model has been successfully finished.
  ///
  /// Do not place initialization code into [initState], but place it here.
  ///
  /// Guarantees a properly initialized [answerModel].
  void postInitState();

  @override
  void dispose() {
    widget.responseItemModel.questionnaireResponseModel
        .removeListener(_forceRebuild);

    firstFocusNode.dispose();
    super.dispose();
  }

  // OPTIMIZE: Should everything listen to the central model on the top?
  // Or do something more hierarchical?

  /// Triggers a repaint of the filler.
  ///
  /// Required for visual updates on enablement changes.
  void _forceRebuild() {
    _abstractLogger.trace('_forceRebuild()');
    setState(() {
      // Just repaint.
    });
  }

  Widget _guardedBuildInputControl(BuildContext context) {
    if (answerModelError != null) {
      return BrokenQuestionnaireItem.fromException(answerModelError!);
    }

    // OPTIMIZE: Is there a more elegant solution? Do I have to unregister the listener?
    // Listen to the parent FocusNode and become focussed when it does.
    if (!_isFocusHookedUp) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        // Focus.of could otherwise fail with: Looking up a deactivated widget's ancestor is unsafe.
        if (mounted) {
          Focus.maybeOf(context)?.addListener(_focusHasChanged);
        }
      });
      _isFocusHookedUp = true;
    }

    return buildInputControl(context);
  }

  void _focusHasChanged() {
    if ((firstFocusNode.parent?.hasPrimaryFocus ?? false) &&
        !firstFocusNode.hasPrimaryFocus) {
      firstFocusNode.requestFocus();
    }
  }

  Widget buildInputControl(BuildContext context);

  set value(V? newValue) {
    if (mounted) {
      setState(() {
        // Updating an answer resets its error marker
        widget.responseItemModel.errorText = null;
        answerModel.value = newValue;
      });
    }
  }

  V? get value => answerModel.value;

  @override
  Widget build(BuildContext context) {
    return _guardedBuildInputControl(context);
  }
}
