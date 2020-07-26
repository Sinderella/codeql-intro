import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

predicate getUserInput(Parameter p) {
  exists(Annotation ann, AnnotationType anntp |
    p.getAnAnnotation() = ann and
    ann.getType() = anntp and
    anntp.getName() in ["RequestHeader", "RequestBody", "RequestParam", "PathVariable"]
  )
}

// predicate getUnsafeFunction(Method m) {
//   exists(Class c |
//     c.getAMethod() = m and
//     c.hasQualifiedName("java.lang", "ProcessBuilder")
//   ) and
//   m.getName() = "command"
// }
// predicate getUnsafeCall(Call call) {
//   exists(Method m |
//     getUnsafeFunction(m) and
//     call.getCallee() = m
//   )
// }
class CommandCall extends Call {
  CommandCall() {
    exists(Class c, Method m |
      c.getAMethod() = m and
      c.hasQualifiedName("java.lang", "ProcessBuilder") and
      m.getName() = "command" and
      this.getCallee() = m
    )
  }
}

class InputSanitiser extends DataFlow::BarrierGuard {
  InputSanitiser() { this.(MethodAccess).getMethod().hasName("sanitise") }

  override predicate checks(Expr e, boolean branch) {
    e = this.(MethodAccess).getQualifier() and branch = false
  }
}

class TaintTrackingConfiguration extends TaintTracking::Configuration {
  TaintTrackingConfiguration() { this = "command_taint" }

  override predicate isSource(DataFlow::Node source) {
    exists(Parameter p | source.asParameter() = p and getUserInput(p))
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(CommandCall call | sink.asExpr() = call.getAnArgument())
    // exists(Call call |
    //   sink.asExpr() = call.getAnArgument() and
    //   getUnsafeCall(call)
    // )
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof InputSanitiser
  }
}

from TaintTrackingConfiguration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select source, sink
