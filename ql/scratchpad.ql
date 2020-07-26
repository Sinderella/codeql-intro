import java

predicate getAuthMethod(Method m) {
  exists(Class c |
    c.hasQualifiedName("com.scalesec.vulnado", "User") and
    c.hasChildElement(m) and
    m.getName() = "assertAuth"
  )
}

predicate getAllowEndpoint(string s) { s in ["/login"] }

predicate getUserInput(Annotation anno, AnnotationType annot, Parameter p) {
  anno.getType() = annot and
  p.getAnAnnotation() = anno and
  annot.getName().matches("Request%")
}

from Annotation anno, AnnotationType annot, Class c, Method m_endpoint
where
  anno.getType() = annot and
  annot.hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping") and
  m_endpoint.getAnAnnotation() = anno and
  c.hasChildElement(m_endpoint)
select c, m_endpoint, anno.getValue("value")
