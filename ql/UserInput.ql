import java

from Parameter p, Annotation ann, AnnotationType anntp
where
  p.getAnAnnotation() = ann and
  ann.getType() = anntp and
  anntp.getName() in ["RequestHeader", "RequestBody", "RequestParam", "PathVariable"] and
  not anntp.hasName("Nullable")
select p, ann
