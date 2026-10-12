/**
 * This is an automatically generated file
 *
 * @name Feature Deleted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-deleted/0/0
 */
 
import java
import orion_callgraph
import orion_dataflow
import utils

/** Check if logical field Visit.description occurs in a framework query. */
predicate usesField(Expr queryValue) {
  exists(string queryText |
    compileTimeStringValue(queryValue, queryText) and
    (
  queryText.regexpMatch(
    "(?i).*\\bVisit\\s*\\.\\s*description\\b.*"
  )
  or
  exists(string declaredAlias, string usedAlias |
    declaredAlias = queryText.regexpCapture(
      "(?i).*(FROM|JOIN)\\s+Visit\\s+([a-zA-Z0-9_]+).*", 2
    ) and
    usedAlias = queryText.regexpCapture(
      "(?i).*\\b([a-zA-Z0-9_]+)\\s*\\.\\s*description\\b.*", 1
    ) and
    declaredAlias = usedAlias
  )
  or
  queryText.regexpMatch("(?i).*FROM\\s+Visit\\b.*") and
  queryText.regexpMatch("(?i).*\\bWHERE\\b.*\\bdescription\\b.*")
    )
  )
}
/** A Spring validation API argument that unambiguously names description. */
predicate isSpringPropertyReference(
  MethodCall call, StringLiteral propertyName, Class entity
) {
  entity.hasName("Visit") and
  isEntity(entity) and
  propertyName.getValue() = "description" and
  isSpringValidationPropertyCall(call, propertyName) and
  springValidationCallTargetsEntity(call, propertyName.getValue(), entity)
}

/** A selected Spring Data repository query derived from description. */
predicate isSpringDataDerivedQuery(Method method, Class entity) {
  isSpringRepositoryMethodForEntity(method, entity) and
  method.getName().regexpMatch(
    "^(find|read|get|query|search|stream|count|exists|delete|remove).*(By|And|Or)Description([A-Z0-9].*)?$"
  )
}

from Class entity, Field attributeField, Location usageLoc, string message
where
  isEntity(entity) and
  entity.hasName("Visit") and 
  attributeField = entity.getAField() and
  attributeField.hasName("description") and // Last field name
  (
    // the field will be renamed
    (usageLoc = attributeField.getLocation() and
    message = "Attribute '" + attributeField.getName() + "' in entity '" + entity.getName() + "' will be deleted.")
    
    or
    // use the field in embedded classes
    exists(Class embeddedClass, Field embeddedField, Field containerField |
      isEmbeddable(embeddedClass) and
      embeddedField = embeddedClass.getAField() and
      embeddedField.getName() = attributeField.getName() and
      containerField.getDeclaringType() = entity and
      containerField.getType() = embeddedClass and
      isEmbeddedField(containerField) and
      usageLoc = embeddedField.getLocation() and
      message = "Embedded field '" + embeddedField.getName() + "' matches attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, attributeField) or isSetter(method, attributeField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' accesses attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    exists(MethodCall call |
      callsAccessor(call, attributeField) and
      usageLoc = call.getLocation() and
      message = "Call to accessor '" + call.getMethod().getName() +
        "' depends on attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // direct access to the attribute
    exists(FieldAccess access |
      access.getField() = attributeField and
      not isAccessInsideAccessor(access, attributeField) and
      usageLoc = access.getLocation() and
      message = "Direct access to attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    exists(Annotation metadata |
      frameworkMetadataReferencesField(metadata, attributeField) and
      usageLoc = metadata.getLocation() and
      message = "Persistence metadata references attribute '" + attributeField.getName() +
        "' which will be deleted."
    )

    or
    // Bounded call-graph propagation from methods that directly access the
    // deleted field. Only result/effect-dependent callers are reported.
    exists(
      Method impactedMethod, MethodCall evidence, string depth, string reason
    |
      fieldCallGraphImpact(
        attributeField, impactedMethod, evidence, depth, reason
      ) and
      usageLoc = impactedMethod.getLocation() and
      message = "[CallGraph depth " + depth + "] Method '" +
        impactedMethod.getName() + "' depends on deleted attribute '" +
        attributeField.getName() + "': it " + reason + "."
    )

    or
    exists(MethodCall call, StringLiteral propertyName |
      isFrameworkFieldNameCall(call, propertyName, attributeField) and
      usageLoc = propertyName.getLocation() and
      message = "Persistence API references attribute '" + attributeField.getName() +
        "' which will be deleted."
    )

    or
    exists(MethodCall call, StringLiteral propertyName |
      isSpringPropertyReference(call, propertyName, entity) and
      usageLoc = propertyName.getLocation() and
      message = "Spring API references property '" + attributeField.getName() +
        "' which will be deleted."
    )

    or
    exists(Method repositoryMethod |
      isSpringDataDerivedQuery(repositoryMethod, entity) and
      usageLoc = repositoryMethod.getLocation() and
      message = "Spring Data derived query method '" + repositoryMethod.getName() +
        "' references attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // Declared JPA named queries.
    exists(Annotation nq |
      isNamedQuery(nq) and
      usesField(nq.getValue("query")) and
      usageLoc = nq.getLocation() and
      message = "Named query uses attribute '" + attributeField.getName() +
        "' which will be deleted."
    )

    or
    // Spring Data query annotations.
    exists(Annotation q |
      isQuery(q) and usesField(q.getValue("value"))
       and
      usageLoc = q.getTarget().getLocation() and
      message = "Query uses attribute '" + attributeField.getName() +
        "' which will be deleted."
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        // agrupa las dos alternativas
        (isCreateQuery(call) and
        exists(Expr queryValue |
          queryValue = call.getArgument(0) and
          usesField(queryValue)
        ))

        or
        (isCreateNamedQuery(call) and
        exists(StringLiteral nameArg, Annotation nq |
          nameArg = call.getArgument(0) and
          isNamedQuery(nq) and
          "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
          usesField(nq.getValue("query"))
        ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query uses attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // A local alias or argument derived from the deleted field remains an
    // impact only when it reaches a concrete call site.
    exists(Expr source, MethodCall consumer |
      fieldValueFlowsToDependentCall(attributeField, source, consumer) and
      usageLoc = consumer.getLocation() and
      message = "[Potential] Value from deleted attribute '" +
        attributeField.getName() + "' flows to call '" +
        consumer.getMethod().getName() + "'."
    )
  )
select usageLoc, message
