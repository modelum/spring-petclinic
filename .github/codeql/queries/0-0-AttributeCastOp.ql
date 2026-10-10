/**
 * This is an automatically generated file
 *
 * @name Attribute Casted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/attribute-casted/0/0
 */
 
import java
import utils

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

  )
select usageLoc, message
