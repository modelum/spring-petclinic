/**
 * This is an automatically generated file
 *
 * @name Relationship Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/relationship-renamed/0
 */
 
import java
import utils

from
  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
  string oldTableName, string newTableName
where
  isEntity(sourceEntity) and
  oldTableName = "vet_specialties" and
  newTableName = "vet_expertise" and

  // search a field with @JoinTable annotation
  relationshipField = sourceEntity.getAField() and
  exists(Annotation joinTable |
    hasJoinTableAnnotation(relationshipField, joinTable) and
    joinTable.getValue("name").toString().replaceAll("\"", "") = oldTableName
    and
    usageLoc = joinTable.getLocation() and
    message =
      "Join table name will change from '" + oldTableName + "' to '" + newTableName + "'."
  ) 
select usageLoc, message
