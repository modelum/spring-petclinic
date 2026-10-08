/**
 * This is an automatically generated file
 *
 * @name Feature Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-renamed/0
 */
 
import java
import utils

/**
 * Check if the field birthDate from entity Pet is used in a JPQL query
 */
predicate usesField(Expr queryValue) {
  // Reference using the fully qualified entity name
  queryValue.toString().regexpMatch(
    "(?i).*\\bPet\\s*\\.\\s*birthDate\\b.*"
  )
  or
  // Reference using an alias defined in the query
  exists(string declaredAlias, string usedAlias |
    declaredAlias = queryValue.toString().regexpCapture(
      "(?i).*(FROM|JOIN)\\s+Pet\\s+([a-zA-Z0-9_]+).*", 2
    ) and
    usedAlias = queryValue.toString().regexpCapture(
      "(?i).*\\b([a-zA-Z0-9_]+)\\s*\\.\\s*birthDate\\b.*", 1
    ) and
    declaredAlias = usedAlias
  )
  or
  // Implicit reference in a WHERE clause
  exists(string whereQuery |
    whereQuery = queryValue.toString() and
    whereQuery.regexpMatch("(?i).*FROM\\s+Pet\\b.*") and
    whereQuery.regexpMatch("(?i).*\\bWHERE\\b.*\\bbirthDate\\b.*")
  )
}

from
  Class entity, Field featureField, Location usageLoc, string oldName, string newName,
  string message
where
  isEntity(entity) and
  entity.hasName("Pet") and // Name entity with the field
  featureField = entity.getAField() and
  featureField.hasName("birthDate") and // Last field name

  oldName = featureField.getName() and
  newName = "dateOfBirth" and 
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
      containerField.getType() = embeddedClass and
      exists(Annotation embedded |
        embedded = containerField.getAnAnnotation() and
        embedded.getType().hasQualifiedName("jakarta.persistence", "Embedded")
      ) and
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
    // direct access to the feature
    exists(FieldAccess access |
      access.getField() = featureField and
      usageLoc = access.getLocation() and
      message = "Direct access to feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // query annotations
    exists(Annotation nq, Annotation q |
      (
        // NamedQuery
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesField(nq.getValue("query")) and
        usageLoc = q.getLocation() and
        message = "Named query uses feature '" + oldName + "' which will be renamed to '" + newName + "'.")
        or

        // Query
        (isQuery(q) and
        usesField(q.getValue("value")) and
        usageLoc = q.getLocation() and
        message = "Query uses feature '" + oldName + "' which will be renamed to '" + newName + "'.")
      )
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        (isCreateQuery(call) and
        exists(StringLiteral queryLiteral |
          queryLiteral = call.getArgument(0) and
          usesField(queryLiteral)
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
