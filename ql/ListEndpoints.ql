import java

from Annotation ann, AnnotationType anntp, Method m, Class c
where
  c.hasChildElement(m) and
  ann = m.getAnAnnotation() and
  anntp = ann.getType() and
  anntp.hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping")
select c, m, ann.getValue("method"), ann.getValue("value"), ann.getValue("produces")
