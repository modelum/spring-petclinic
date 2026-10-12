/**
 * This is an automatically generated file
 *
 * @name Deleted Entity
 * @kind alert
 * @problem.severity warning
 * @id java/orion/entity-deleted/0
 */
 
import java
import utils

/** Check if entity PetType is used in a selected framework query. */
predicate usesOldEntity(Expr queryValue) {
  exists(string queryText |
    compileTimeStringValue(queryValue, queryText) and
    (
  queryText.regexpMatch(
    "(?i).*\\b(FROM|UPDATE|DELETE\\s+FROM)\\s+PetType\\b.*"
  )
  or
  queryText.regexpMatch(
    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?PetType\\b.*"
  )
    )
  )
}

from Class entity, Location usageLoc, string message
where
  entity.hasName("PetType") and
  isEntity(entity) and
  (
    (
      usageLoc = entity.getLocation() and
      message =
        "Entity '" + entity.getName() + "' is marked for deletion."
    )

    or
    // Explicit constructor declarations are separate rename/delete sites.
    // Compiler-provided default constructors have no source location and
    // are intentionally excluded by declaresEntityConstructor.
    exists(Constructor constructor |
      declaresEntityConstructor(constructor, entity) and
      usageLoc = constructor.getLocation() and
      message =
        "Explicit constructor of entity '" + entity.getName() +
        "' becomes invalid when the entity is deleted."
    )

    or
    // Any source type reference resolved to the affected entity. This
    // covers fields, generic arguments, parameters, returns, locals,
    // supertypes, interfaces and repository declarations.
    exists(TypeAccess typeReference |
      referencesEntityType(typeReference, entity) and
      not exists(ClassInstanceExpr creation |
        creation.getTypeName() = typeReference
      ) and
      usageLoc = typeReference.getLocation() and
      message =
        "Resolved type reference to entity '" + entity.getName() +
        "' must be removed or replaced because the entity is being deleted."
    )

    or
    // Constructor calls are reported once at the complete construction,
    // rather than again at their nested type access.
    exists(ClassInstanceExpr creation |
      constructsEntity(creation, entity) and
      usageLoc = creation.getLocation() and
      message =
        "Construction of entity '" + entity.getName() +
        "' is invalid after the entity is deleted."
    )

    or
    exists(MethodCall call, StringLiteral collectionName |
      isFrameworkCollectionNameCall(call, collectionName, entity) and
      usageLoc = collectionName.getLocation() and
      message = "Persistence call references the stored collection for entity '" +
        entity.getName() + "' which is marked for deletion."
    )

    or
    // A declared JPA named query is itself a schema dependency; it does
    // not need a separate Spring Data @Query reference to be relevant.
    exists(Annotation nq, Expr queryValue |
      isNamedQuery(nq) and
      queryValue = nq.getValue("query") and
      usesOldEntity(queryValue) and
      usageLoc = nq.getLocation() and
      message =
        "Named query uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )

    or
    // JPQL queries in @Query
    exists(Annotation q, Expr queryValue |
      isQuery(q) and
      queryValue = q.getValue("value") and
      usesOldEntity(queryValue) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Query uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )

    or
    // EntityManager.createQuery(...)
    exists(MethodCall call, Expr queryValue |
      isCreateQuery(call) and
      queryValue = call.getArgument(0) and
      usesOldEntity(queryValue) and
      usageLoc = call.getLocation() and
      message =
        "Call to createQuery uses entity '" + entity.getName() +
        "' which is marked for deletion."
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
        "Call to createNamedQuery uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )
  )

select usageLoc, message
