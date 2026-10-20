/**
 * This is an automatically generated file
 *
 * @name Feature Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-renamed/1
 */
 
import java
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

from
  Class entity, Field featureField, Location usageLoc, string oldName, string newName,
  string message
where
  isEntity(entity) and
  entity.hasName("Visit") and // Name entity with the field
  featureField = entity.getAField() and
  featureField.hasName("description") and // Last field name

  oldName = featureField.getName() and
  newName = "notes" and 
  (
    // the field will be renamed
    (usageLoc = featureField.getLocation() and
    message = "Feature '" + oldName + "' in entity '" + entity.getName() + "' will be renamed to '" + newName + "'.")

    or
    // use the field in embedded classes
    exists(Class embeddedClass, Field embeddedField, Field containerField |
      isEmbeddable(embeddedClass) and
      embeddedField = embeddedClass.getAField() and
      embeddedField.getName() = oldName and
      containerField.getDeclaringType() = entity and
      containerField.getType() = embeddedClass and
      isEmbeddedField(containerField) and
      usageLoc = embeddedField.getLocation() and
      message = "Embedded field '" + oldName + "' matches feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, featureField) or isSetter(method, featureField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' accesses feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // resolved calls to the getter/setter, including calls from other classes
    exists(MethodCall call |
      callsAccessor(call, featureField) and
      usageLoc = call.getLocation() and
      message = "Call to accessor '" + call.getMethod().getName() +
        "' depends on feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // direct access to the feature
    exists(FieldAccess access |
      access.getField() = featureField and
      not isAccessInsideAccessor(access, featureField) and
      usageLoc = access.getLocation() and
      message = "Direct access to feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // JPA metadata whose value names the affected feature.
    exists(Annotation metadata |
      frameworkMetadataReferencesField(metadata, featureField) and
      usageLoc = metadata.getLocation() and
      message = "Persistence metadata references feature '" + oldName +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // Typed persistence APIs such as Criteria.where("field") and Update.set(...).
    exists(MethodCall call, StringLiteral propertyName |
      isFrameworkFieldNameCall(call, propertyName, featureField) and
      usageLoc = propertyName.getLocation() and
      message = "Persistence API references feature '" + oldName +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // Exact Spring validation property name in an entity-binding callable.
    exists(MethodCall call, StringLiteral propertyName |
      isSpringPropertyReference(call, propertyName, entity) and
      usageLoc = propertyName.getLocation() and
      message = "Spring API references property '" + oldName +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // Spring Data query method whose repository generic is the entity.
    exists(Method repositoryMethod |
      isSpringDataDerivedQuery(repositoryMethod, entity) and
      usageLoc = repositoryMethod.getLocation() and
      message = "Spring Data derived query method '" + repositoryMethod.getName() +
        "' references feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // Declared JPA named queries.
    exists(Annotation nq |
      isNamedQuery(nq) and
      usesField(nq.getValue("query")) and
      usageLoc = nq.getLocation() and
      message = "Named query uses feature '" + oldName +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // Spring Data query annotations.
    exists(Annotation q |
      isQuery(q) and usesField(q.getValue("value"))
       and
      usageLoc = q.getLocation() and
      message = "Query uses feature '" + oldName +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        (isCreateQuery(call) and
        exists(Expr queryValue |
          queryValue = call.getArgument(0) and
          usesField(queryValue)
        ))

        or
        (isCreateNamedQuery(call) and
        exists(StringLiteral nameArg, Annotation nq2 |
          nameArg = call.getArgument(0) and
          isNamedQuery(nq2) and
          "\"" + nameArg.getValue() + "\"" = nq2.getValue("name").toString() and
          usesField(nq2.getValue("query"))
        ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query uses feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )
  )
select usageLoc, message
