id: joinr1r2
label: JoinR1R2
class: ExpressionTool
cwlVersion: v1.0
inputs:
  r1: Any
  r2: Any
outputs:
  output: Any
expression: >-
          ${
            var res = Array()
            for(var i=0; i < inputs.r1.length; i++) {
                var lst = new Array ();
                lst.push(inputs.r1[i]);
                lst.push(inputs.r2[i]);
                res.push(lst);
            }
            return {"output": res};
           }
