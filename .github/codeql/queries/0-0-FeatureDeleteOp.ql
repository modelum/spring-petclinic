/**
 * This is an automatically generated file
 *
 * @name Feature Deleted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-deleted/0/0
 */
 
import java
import utils

/** Check if field Visit.description is used in a static JPQL query. */
predicate usesField(Expr queryValue) {
  // Qualified entity reference.
  queryValue.toString().regexpMatch(
    "(?i).*\\bVisit\\s*\\.\\s*description\\b.*"
  )
  or
  // Reference through an alias declared for the affected entity.
  exists(string declaredAlias, string usedAlias |
    declaredAlias = queryValue.toString().regexpCapture(
      "(?i).*(FROM|JOIN)\\s+Visit\\s+([a-zA-Z0-9_]+).*", 2
    ) and
    usedAlias = queryValue.toString().regexpCapture(
      "(?i).*\\b([a-zA-Z0-9_]+)\\s*\\.\\s*description\\b.*", 1
    ) and
    declaredAlias = usedAlias
  )
  or
  // Unqualified property in a WHERE clause for the affected entity.
  queryValue.toString().regexpMatch("(?i).*FROM\\s+Visit\\b.*") and
  queryValue.toString().regexpMatch("(?i).*\\bWHERE\\b.*\\bdescription\\b.*")
}
/**
 * A Spring validation API argument that unambiguously names description in
 * a callable that also receives the affected entity.
 */
predicate isSpringPropertyReference(MethodCall call, StringLiteral propertyName, Class entity) {
  entity.hasName("Visit") and
  isEntity(entity) and
  propertyName = call.getArgument(0) and
  propertyName.getValue() = "description" and
  exists(Parameter entityParameter |
    entityParameter = call.getEnclosingCallable().getAParameter() and
    entityParameter.getType() = entity
  ) and
  call.getMethod().getDeclaringType().getASupertype*()
    .hasQualifiedName("org.springframework.validation", "Errors") and
  (
    call.getMethod().getName() = "rejectValue" or
    call.getMethod().getName() = "getFieldValue" or
    call.getMethod().getName() = "getFieldError" or
    call.getMethod().getName() = "hasFieldErrors"
  )
}

/** A Spring Data repository query derived from property description. */
predicate isSpringDataDerivedQuery(Method method, Class entity) {
  exists(ClassOrInterface repository, TypeAccess repositoryType |
    method.getDeclaringType() = repository and
    repository.contains(repositoryType) and
    repositoryType.getTypeArgument(0).getType() = entity and
    repositoryType.getType().(RefType).getASupertype*()
      .hasQualifiedName("org.springframework.data.repository", "Repository") and
    method.getName().regexpMatch(
      "^(find|read|get|query|search|stream|count|exists|delete|remove).*(By|And|Or)Description([A-Z0-9].*)?$"
    )
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
      jpaMetadataReferencesField(metadata, attributeField) and
      usageLoc = metadata.getLocation() and
      message = "JPA metadata references attribute '" + attributeField.getName() +
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
    // query annotations
    exists(Annotation nq, Annotation q |
      (
        // Named queries
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesField(nq.getValue("query")) and
        usageLoc = q.getTarget().getLocation() and
        message = "Named query uses attribute '" + attributeField.getName() + "' which will be deleted.")

        or
        // Regular queries
        (isQuery(q) and usesField(q.getValue("value"))) and
        usageLoc = q.getTarget().getLocation() and
        message = "Query uses attribute '" + attributeField.getName() + "' which will be deleted."
      )
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        // agrupa las dos alternativas
        (isCreateQuery(call) and
        exists(StringLiteral queryLiteral |
          queryLiteral = call.getArgument(0) and
          usesField(queryLiteral)
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
  )
select usageLoc, message
