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

/**
 * Check if the entity PetType is used in a JPQL query
 */
predicate usesOldEntity(StringLiteral queryValue) {
  queryValue.getValue().regexpMatch(
    "(?i).*\\b(FROM|UPDATE|DELETE\\s+FROM)\\s+PetType\\b.*"
  )
  or
  queryValue.getValue().regexpMatch(
    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?PetType\\b.*"
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
    // Relationships in other entities
    exists(Field field |
      field.getType() = entity and
      hasJpaAssociationTo(field) and
      usageLoc = field.getLocation() and
      message =
        "Field '" + field.getName() +
        "' references entity '" + entity.getName() +
        "' which is being deleted."
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
        "Named query uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )

    or
    // JPQL queries in @Query
    exists(Annotation q, StringLiteral queryLiteral |
      isQuery(q) and
      queryLiteral = q.getValue("value") and
      usesOldEntity(queryLiteral) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Query uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )

    or
    // EntityManager.createQuery(...)
    exists(MethodCall call, StringLiteral queryLiteral |
      isCreateQuery(call) and
      queryLiteral = call.getArgument(0) and
      usesOldEntity(queryLiteral) and
      usageLoc = call.getLocation() and
      message =
        "Call to createQuery uses entity '" + entity.getName() +
        "' which is marked for deletion."
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
        "Call to createNamedQuery uses entity '" + entity.getName() +
        "' which is marked for deletion."
    )
  )

select usageLoc, message
