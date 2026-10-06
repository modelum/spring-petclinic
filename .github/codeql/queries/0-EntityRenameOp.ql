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

from Class oldEntity, Location usageLoc, string message, string newName
where
  oldEntity.hasName("Owner") and
  isEntity(oldEntity) and
  newName = "Customer" and
  (
    (
      usageLoc = oldEntity.getLocation() and
      message =
        "Entity '" + oldEntity.getName() +
        "' will be renamed to '" + newName + "'."
    )

    or
    // Field references in other entities
    exists(Field field |
      field.getType().getName() = oldEntity.getName() and
      hasJpaAssociationTo(field) and
      usageLoc = field.getLocation() and
      message =
        "Field '" + field.getName() +
        "' references old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or
    // Named JPQL queries referenced through @Query
    exists(Annotation nq, Annotation q, StringLiteral queryLiteral |
      isQuery(q) and
      isNamedQuery(nq) and
      isEqual(nq.getValue("name"), q.getValue("name")) and
      queryLiteral = nq.getValue("query") and
      usesOldEntity(queryLiteral, oldEntity) and
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
      usesOldEntity(queryLiteral, oldEntity) and
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
      usesOldEntity(queryLiteral, oldEntity) and
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
      usesOldEntity(queryLiteral, oldEntity) and
      usageLoc = call.getLocation() and
      message =
        "Call to createNamedQuery uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )
  )

select usageLoc, message
