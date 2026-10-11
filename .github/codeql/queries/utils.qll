import java
import orion_java
import orion_spring
import orion_jpa

/** Persistent domain type according to the selected adapter composition. */
predicate isEntity(Class entity) {
  isJpaEntity(entity)
}

predicate frameworkEntityMetadataAnnotation(Class entity, Annotation annotation) {
  isJpaEntityMetadataAnnotation(entity, annotation)
}

predicate isFrameworkCollectionNameCall(
  MethodCall call, StringLiteral collectionName, Class entity
) {
  collectionName = call.getArgument(0) and
  entity.hasName(collectionName.getValue()) and
  call.getMethod().hasQualifiedName("orionflow.disabled", "MongoOperations", "find")
}

predicate isQuery(Annotation annotation) {
  isJpaQuery(annotation)
}

predicate isNamedQuery(Annotation annotation) {
  isJpaNamedQuery(annotation)
}

predicate isEmbeddable(Class cls) {
  isJpaEmbeddable(cls)
}

predicate isEmbeddedField(Field field) {
  isJpaEmbeddedField(field)
}

predicate usesField(Expr queryValue, Field field) {
  jpaQueryReferencesField(queryValue, field)
}

predicate frameworkQueryReferencesField(Annotation query, Field field) {
  isJpaEntity(field.getDeclaringType()) and
  isJpaQuery(query) and
  jpaQueryReferencesField(query.getValue("value"), field)
}

predicate isCreateQuery(MethodCall call) {
  isJpaCreateQuery(call)
}

predicate isCreateNamedQuery(MethodCall call) {
  isJpaCreateNamedQuery(call)
}

predicate frameworkMetadataReferencesField(Annotation annotation, Field field) {
  isJpaEntity(field.getDeclaringType()) and
  jpaMetadataReferencesField(annotation, field)
}

predicate isFrameworkFieldNameCall(
  MethodCall call, StringLiteral propertyName, Field field
) {
  propertyName = call.getArgument(0) and
  field.hasName(propertyName.getValue()) and
  call.getMethod().hasQualifiedName("orionflow.disabled", "FieldApi", "field")
}

predicate isAssociationAnnotation(Annotation annotation) {
  isJpaAssociationAnnotation(annotation)
}

predicate isReferenceMappingAnnotation(Annotation annotation, Field field) {
  isJpaReferenceMappingAnnotation(annotation, field)
}

predicate isRelationshipField(Field field) {
  isJpaRelationshipField(field)
}

predicate isRelatedField(Field relationshipField, Field mappedField) {
  isJpaRelatedField(relationshipField, mappedField)
}

predicate usesRelationship(Expr queryValue, Field relationshipField) {
  jpaRelationshipReferencedInQuery(queryValue, relationshipField)
}

predicate frameworkQueryReferencesRelationship(
  Annotation query, Expr queryValue, Field relationshipField
) {
  isJpaQuery(query) and
  jpaRelationshipReferencedInQuery(queryValue, relationshipField)
}

Field getRelationshipField(Class sourceEntity, string relationshipName) {
  result = getJpaRelationshipField(sourceEntity, relationshipName)
}

predicate getRelationshipMappingAnnotation(
  Field field, string relationshipName, Annotation mapping
) {
  getJpaRelationshipMappingAnnotation(field, relationshipName, mapping)
}

predicate isIdAnnotation(Annotation annotation) {
  isJpaAnnotation(annotation, "Id") or isJpaAnnotation(annotation, "EmbeddedId")
}

predicate isGeneratedValueAnnotation(Annotation annotation) {
  isJpaAnnotation(annotation, "GeneratedValue")
}

predicate isJoinColumnAnnotation(Annotation annotation) {
  isJpaAnnotation(annotation, "JoinColumn")
}
