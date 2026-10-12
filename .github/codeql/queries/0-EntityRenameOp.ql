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

/** Check if entity Visit is used in a selected framework query. */
predicate usesOldEntity(Expr queryValue) {
  exists(string queryText |
    compileTimeStringValue(queryValue, queryText) and
    (
  queryText.regexpMatch(
    "(?i).*\\b(FROM|UPDATE|DELETE\\s+FROM)\\s+Visit\\b.*"
  )
  or
  queryText.regexpMatch(
    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?Visit\\b.*"
  )
    )
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
    exists(Constructor constructor |
      declaresEntityConstructor(constructor, oldEntity) and
      usageLoc = constructor.getLocation() and
      message =
        "Explicit constructor of entity '" + oldEntity.getName() +
        "' must use the new name '" + newName + "'."
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
    exists(Annotation metadata |
      frameworkEntityRenameMetadataAnnotation(oldEntity, metadata) and
      usageLoc = metadata.getLocation() and
      message = "Explicit logical entity name '" + oldEntity.getName() +
        "' must be reviewed for rename to '" + newName + "'."
    )

    or
    exists(MethodCall call, StringLiteral collectionName |
      isFrameworkCollectionNameCall(call, collectionName, oldEntity) and
      usageLoc = collectionName.getLocation() and
      message = "Persistence call references the stored collection for entity '" +
        oldEntity.getName() + "' which will be renamed to '" + newName + "'."
    )

    or
    // A declared JPA named query is itself a schema dependency.
    exists(Annotation nq, Expr queryValue |
      isNamedQuery(nq) and
      queryValue = nq.getValue("query") and
      usesOldEntity(queryValue) and
      usageLoc = nq.getLocation() and
      message =
        "Named query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // JPQL queries in @Query
    exists(Annotation q, Expr queryValue |
      isQuery(q) and
      queryValue = q.getValue("value") and
      usesOldEntity(queryValue) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // EntityManager.createQuery(...)
    exists(MethodCall call, Expr queryValue |
      isCreateQuery(call) and
      queryValue = call.getArgument(0) and
      usesOldEntity(queryValue) and
      usageLoc = call.getLocation() and
      message =
        "Call to createQuery uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // EntityManager.createNamedQuery(...)
    exists(MethodCall call, StringLiteral nameArg,
           Annotation nq, Expr queryValue |
      isCreateNamedQuery(call) and
      nameArg = call.getArgument(0) and
      isNamedQuery(nq) and
      "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
      queryValue = nq.getValue("query") and
      usesOldEntity(queryValue) and
      usageLoc = call.getLocation() and
      message =
        "Call to createNamedQuery uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )
  )

select usageLoc, message
