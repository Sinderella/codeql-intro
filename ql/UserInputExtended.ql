import java

predicate getUserInput(Parameter p, Annotation ann, AnnotationType anntp, Method m) {
  m.hasChildElement(p) and
  p.getAnAnnotation() = ann and
  ann.getType() = anntp and
  anntp.getName() in ["RequestHeader", "RequestBody", "RequestParam", "PathVariable"] and
  not anntp.hasName("Nullable")
}

predicate getEndpoints(Annotation ann, AnnotationType anntp, Method m, Class c) {
  c.hasChildElement(m) and
  ann = m.getAnAnnotation() and
  anntp = ann.getType() and
  anntp.hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping")
}

from
  Annotation ann_endpoint, AnnotationType anntp_endpoint, Annotation ann_user,
  AnnotationType anntp_user, Method m, Class c, Parameter p
where getEndpoints(ann_endpoint, anntp_endpoint, m, c) and getUserInput(p, ann_user, anntp_user, m)
select c, m, ann_endpoint.getValue("method"), ann_endpoint.getValue("value"),
  ann_endpoint.getValue("produces"), p
