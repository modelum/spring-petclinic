/**
 * This is an automatically generated file
 *
 * @name Renamed Entity
 * @kind alert
 * @problem.severity warning
 * @id java/orion/entity-renamed/0
 */
 
import java
import utils

/** Check if entity Visit is used in a static JPQL query. */
predicate usesOldEntity(StringLiteral queryValue) {
  queryValue.getValue().regexpMatch(
    "(?i).*\\b(FROM|UPDATE|DELETE\\s+FROM)\\s+Visit\\b.*"
  )
  or
  queryValue.getValue().regexpMatch(
    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?Visit\\b.*"
  )
}

from Class oldEntity, Location usageLoc, string message, string newName
where
  oldEntity.hasName("Visit") and
  isEntity(oldEntity) and
  newName = "Consultation" and
  (
    (
      usageLoc = oldEntity.getLocation() and
      message =
        "Entity '" + oldEntity.getName() +
        "' will be renamed to '" + newName + "'."
    )

    or
    // Any source type reference resolved to the affected entity.
    exists(TypeAccess typeReference |
      referencesEntityType(typeReference, oldEntity) and
      not exists(ClassInstanceExpr creation |
        creation.getTypeName() = typeReference
      ) and
      usageLoc = typeReference.getLocation() and
      message =
        "Resolved type reference to entity '" + oldEntity.getName() +
        "' must be renamed to '" + newName + "'."
    )

    or
    exists(ClassInstanceExpr creation |
      constructsEntity(creation, oldEntity) and
      usageLoc = creation.getLocation() and
      message =
        "Construction of entity '" + oldEntity.getName() +
        "' must use the new name '" + newName + "'."
    )

    or
    // Named JPQL queries referenced through @Query
    exists(Annotation nq, Annotation q, StringLiteral queryLiteral |
      isQuery(q) and
      isNamedQuery(nq) and
      isEqual(nq.getValue("name"), q.getValue("name")) and
      queryLiteral = nq.getValue("query") and
      usesOldEntity(queryLiteral) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Named query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // JPQL queries in @Query
    exists(Annotation q, StringLiteral queryLiteral |
      isQuery(q) and
      queryLiteral = q.getValue("value") and
      usesOldEntity(queryLiteral) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // EntityManager.createQuery(...)
    exists(MethodCall call, StringLiteral queryLiteral |
      isCreateQuery(call) and
      queryLiteral = call.getArgument(0) and
      usesOldEntity(queryLiteral) and
      usageLoc = call.getLocation() and
      message =
        "Call to createQuery uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // EntityManager.createNamedQuery(...)
    exists(MethodCall call, StringLiteral nameArg,
           Annotation nq, StringLiteral queryLiteral |
      isCreateNamedQuery(call) and
      nameArg = call.getArgument(0) and
      isNamedQuery(nq) and
      "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
      queryLiteral = nq.getValue("query") and
      usesOldEntity(queryLiteral) and
      usageLoc = call.getLocation() and
      message =
        "Call to createNamedQuery uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )
  )

select usageLoc, message
