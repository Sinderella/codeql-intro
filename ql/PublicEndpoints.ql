import java

predicate getEndpoints(Annotation ann, AnnotationType anntp, Method m, Class c) {
  c.hasChildElement(m) and
  ann = m.getAnAnnotation() and
  anntp = ann.getType() and
  anntp.hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping")
}

predicate getAuthCheckMethod(Method m) {
  m.hasName("assertAuth") and
  exists(Class c | c.hasQualifiedName("com.scalesec.vulnado", "User") and c.contains(m))
}

predicate allowList(Expr expr) { expr.toString().splitAt("\"", 1) in ["/login"] }

from Annotation ann_endpoint, AnnotationType anntp_endpoint, Method m, Method auth_m, Class c
where
  getEndpoints(ann_endpoint, anntp_endpoint, m, c) and
  getAuthCheckMethod(auth_m) and
  not allowList(ann_endpoint.getValue("value")) and
  not m.calls(auth_m)
select c, m, ann_endpoint.getValue("method"), ann_endpoint.getValue("value")
