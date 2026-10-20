/**
 * This is an automatically generated file
 *
 * @name Attribute Casted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/attribute-casted/2/0
 */
 
import java
import orion_dataflow
import utils

/** The single field selected by this generated CAST query. */
private predicate orionCastField(Field field) {
  exists(Class entity |
    isEntity(entity) and
    entity.hasName("Visit") and
    field = entity.getAField() and
    field.hasName("date")
  )
}

/** The replacement type still supports the resolved old-type operation. */
private predicate orionNewTypeSupportsCall(MethodCall consumer) {
  exists(RefType replacementType |
    replacementType.getName() = "String" and
    replacementType.getASupertype*().getSourceDeclaration() =
      consumer.getMethod().getDeclaringType().getSourceDeclaration()
  )
}

/** A method operation that genuinely requires the field's previous type. */
private predicate orionCastOldTypeSink(
  Field field, DataFlow::Node sink, MethodCall consumer
) {
  orionCastField(field) and
  isOldTypeMethodCall(consumer, field) and
  not orionNewTypeSupportsCall(consumer) and
  sink = DataFlow::exprNode(consumer.getQualifier())
}

module OrionCastGlobalConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Field field, Expr expression |
      orionCastField(field) and
      readsFieldValue(expression, field) and
      source = DataFlow::exprNode(expression)
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Field field, MethodCall consumer |
      orionCastOldTypeSink(field, sink, consumer)
    )
  }

  /** Do not re-enter an independently read affected-field source. */
  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }
}

module OrionCastGlobalFlow = DataFlow::Global<OrionCastGlobalConfig>;

/**
 * Interprocedural flow only: local paths remain the responsibility of the
 * existing lightweight predicates in orion_dataflow.qll.
 */
predicate fieldValueGloballyFlowsToOldTypeConsumer(
  Field field, Expr source, MethodCall consumer
) {
  orionCastField(field) and
  readsFieldValue(source, field) and
  orionCastOldTypeSink(
    field, DataFlow::exprNode(consumer.getQualifier()), consumer
  ) and
  OrionCastGlobalFlow::flow(
    DataFlow::exprNode(source),
    DataFlow::exprNode(consumer.getQualifier())
  ) and
  not DataFlow::localFlow(
    DataFlow::exprNode(source),
    DataFlow::exprNode(consumer.getQualifier())
  )
}

from
  Class entity, Field attributeField, Location usageLoc, string message, string oldType,
  string newType
where
  isEntity(entity) and
  entity.hasName("Visit") and 
  attributeField = entity.getAField() and
  attributeField.hasName("date") and 
  oldType = attributeField.getType().getName() and
  newType = "String" and // New type to replace the old one
  (
    // the attribute will be casted
    (usageLoc = attributeField.getLocation() and
    message = "Attribute '" + attributeField.getName() + "' in entity '" + entity.getName() + "' will change type from '" + oldType + "' to '" + newType + "'.")

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, attributeField) or isSetter(method, attributeField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' uses attribute '" + attributeField.getName() + "' with type '" + oldType + "' which will be changed to '" + newType + "'."
    )

    or
    // Calls are resolved to the exact accessor, avoiding homonymous methods.
    exists(MethodCall accessorCall |
      callsAccessor(accessorCall, attributeField) and
      usageLoc = accessorCall.getLocation() and
      message = "Call to accessor '" + accessorCall.getMethod().getName() +
        "' depends on attribute type '" + oldType + "' which will change to '" + newType + "'."
    )

    or
    // Typed persistence APIs may impose ordering/comparison semantics that
    // depend on the attribute's previous type.
    exists(MethodCall call, StringLiteral propertyName |
      isFrameworkFieldNameCall(call, propertyName, attributeField) and
      usageLoc = propertyName.getLocation() and
      message = "Persistence API uses attribute '" + attributeField.getName() +
        "' whose type will change from '" + oldType + "' to '" + newType + "'."
    )

    or
    // direct access to the attribute
    exists(Expr expr |
      usesFieldWithTypeDependency(expr, attributeField) and
      usageLoc = expr.getLocation() and
      message = "Code depends on attribute '" + attributeField.getName() + "' having type '" + oldType + "' which will be changed to '" + newType + "'."
    )

    or
    // variable declarations with used attribute
    exists(LocalVariableDeclExpr varDecl, Expr source |
      source = varDecl.getInit() and
      readsFieldValue(source, attributeField) and
      varDecl.getType().getName() = oldType and
      oldType != newType and
      usageLoc = varDecl.getLocation() and
      message = "Variable declaration expects old type '" + oldType +
        "' from attribute '" + attributeField.getName() + "', which will change to '" + newType + "'."
    )

    or
    // Assignment target still expects the old type.
    exists(Assignment assignment, Expr source |
      source = assignment.getRhs() and
      readsFieldValue(source, attributeField) and
      assignment.getDest().getType().getName() = oldType and
      oldType != newType and
      usageLoc = assignment.getLocation() and
      message = "Assignment expects old type '" + oldType +
        "' from attribute '" + attributeField.getName() + "', which will change to '" + newType + "'."
    )

    or
    // A field/getter value is passed to a parameter expecting the old type.
    exists(MethodCall call, Expr source, int i |
      source = call.getArgument(i) and
      readsFieldValue(source, attributeField) and
      call.getMethod().getParameterType(i).getName() = oldType and
      oldType != newType and
      usageLoc = call.getLocation() and
      message = "Method call expects old type '" + oldType +
        "' from attribute '" + attributeField.getName() + "', which will change to '" + newType + "'."
    )

    or
    // Experimental local flow: only affected field/getter sources and
    // method consumers declared on the old type hierarchy are considered.
    exists(Expr source, MethodCall consumer |
      readsFieldValue(source, attributeField) and
      isOldTypeMethodCall(consumer, attributeField) and
      fieldValueFlowsToOldTypeConsumer(attributeField, source, consumer) and
      usageLoc = consumer.getLocation() and
      message = "[Potential] Value from attribute '" + attributeField.getName() +
        "' flows locally to old-type operation '" + consumer.getMethod().getName() +
        "' after conversion to '" + newType + "'."
    )

    or
    // Global flow is generated specifically for this CAST field and only
    // reports old-type operations reached across method boundaries.
    exists(Expr source, MethodCall consumer |
      fieldValueGloballyFlowsToOldTypeConsumer(
        attributeField, source, consumer
      ) and
      usageLoc = consumer.getLocation() and
      message = "[Global] Value from attribute '" +
        attributeField.getName() + "' reaches old-type operation '" +
        consumer.getMethod().getName() +
        "' across method boundaries after conversion to '" + newType + "'."
    )
  )
select usageLoc, message
