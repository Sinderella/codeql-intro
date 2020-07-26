import java

predicate getUserEndpoint(Annotation anno, AnnotationType annot, Class c, Method m) {
  anno.getType() = annot and
  annot.getName() = "RequestMapping" and
  c.hasChildElement(m) and
  m.getAnAnnotation() = anno
}

predicate getAuthMethod(Method m) {
  exists(Class c |
    m.hasName("assertAuth") and
    c.hasChildElement(m) and
    c.hasQualifiedName("com.scalesec.vulnado", "User")
  )
}

predicate getUserInput(Parameter p, AnnotationType annot) {
  exists(Annotation anno |
    anno.getType() = annot and
    p.getAnAnnotation() = anno and
    annot.toString() in ["RequestHeader", "PathVariable", "RequestBody", "RequestParam"]
  )
}

predicate isPublicEndpoint(string s) { s in ["/login"] }

from Annotation anno, AnnotationType annot, Class c, Method m_endpoint, Method m_auth
where
  getUserEndpoint(anno, annot, c, m_endpoint) and
  getAuthMethod(m_auth) and
  not m_endpoint.calls(m_auth) and
  not isPublicEndpoint(anno.getValue("value").toString().splitAt("\""))
select c, m_endpoint, anno.getValue("value")
